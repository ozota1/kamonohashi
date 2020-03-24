#!/bin/bash
readonly DEEPOPS_VER=20.02


readonly HELP_URL="https://kamonohashi.ai/docs/install-and-update"
readonly SCRIPT_DIR=$(cd $(dirname $0); pwd)

readonly DEEPOPS_DIR=$SCRIPT_DIR/deepops
readonly HELM_DIR=$SCRIPT_DIR/kamonohashi
readonly FILES_DIR=$SCRIPT_DIR/files

# deepopsの設定ファイル
readonly INFRA_CONF_DIR=$DEEPOPS_DIR/config
readonly INVENTORY=$INFRA_CONF_DIR/inventory
readonly GROUP_VARS_DIR=$INFRA_CONF_DIR/group_vars
readonly GROUP_VARS_ALL=$GROUP_VARS_DIR/all.yml
readonly GROUP_VARS_K8S=$GROUP_VARS_DIR/k8s-cluster.yml

# KAMONOHASHI Helmの設定ファイル
readonly APP_CONF_DIR=$HELM_DIR/conf
readonly APP_CONF_FILE=$APP_CONF_DIR/settings.yml

# 関数定義

ask_node_conf(){
  echo -en "\e[33mKubernetes masterをデプロイするサーバ名: \e[m"; read KUBE_MASTER
  echo -en "\e[33mKAMONOHASHIをデプロイするサーバ名: \e[m"; read KQI_NODE
  echo -en "\e[33mStorageをデプロイするサーバ名: \e[m"; read STORAGE
  echo -en "\e[33mGPU サーバ名(,区切りで複数可): \e[m"; read GPU_NODES_COMMA
  echo -en "\e[33m各nodeにSSHする際のユーザー名: \e[m"; read SSH_USER
}

ask_proxy_conf(){
  echo -en "\e[33mプロキシを設定しますか？ [y/N]: \e[m"; read PROXY_FLAG
  case $PROXY_FLAG in
   [Yy]* ) 
     echo -en "\e[33mhttp_proxy: \e[m"; read HTTP_PROXY
     echo -en "\e[33mhttps_proxy: \e[m"; read HTTPS_PROXY
     echo -en "\e[33mno_proxy: \e[m"; read ADDITIONAL_NO_PROXY
     ;;   
   *) ;;
  esac
}

ask_conf(){
  echo "クラスタの構成情報を入力してください"
  echo "詳細は ${HELP_URL} を参照してください"

  ask_node_conf
  ask_proxy_conf
}

append_proxy_ansible_vars(){
  # 改行の挿入
  echo "" >> $GROUP_VARS_ALL
  if [ ! -z "$HTTP_PROXY" ]; then
    echo "http_proxy: $HTTP_PROXY" >> $GROUP_VARS_ALL
  fi
  if [ ! -z "$HTTPS_PROXY" ]; then
    echo "https_proxy: $HTTPS_PROXY" >> $GROUP_VARS_ALL
  fi
  # ansible側でno_proxyは組み立てる
  if [ ! -z "$ADDITIONAL_NO_PROXY" ]; then
    echo "additional_no_proxy: $ADDITIONAL_NO_PROXY" >> $GROUP_VARS_ALL
  fi
}

get_ip(){
  local IP_BY_DNS=$(host $1 | awk '/has address/ { print $4 }')
  if [ -z "$IP_BY_DNS" ]; then
    # 名前解決した結果からループバックを除き先頭のIPを選択
    # hostコマンドはhostsを見ない。getentは/etc/nsswitch.confに従って解決する
    local IP=$(getent hosts $1 | awk '{print $1}' | grep -v ^127.* | head -1)
  else
    local IP=$IP_BY_DNS
  fi
  echo $IP
}

append_proxy_helm_conf(){
  # 改行の挿入
  echo "" >> $APP_CONF_FILE
  if [ ! -z "$HTTP_PROXY" ]; then
    echo "http_proxy: '$HTTP_PROXY'" >>  $APP_CONF_FILE
  fi
  if [ ! -z "$HTTPS_PROXY" ]; then
    echo "https_proxy: '$HTTPS_PROXY'" >> $APP_CONF_FILE
  fi  
  if [ ! -z "$HTTP_PROXY" ] || [ ! -z "$HTTPS_PROXY" ]; then
    # kamonohashiコンテナに設定するNO_PROXYの生成
    KUBE_MASTER_IP=$(get_ip $KUBE_MASTER)
    STORAGE_IP=$(get_ip $STORAGE)
    NO_PROXY=$KUBE_MASTER,$KUBE_MASTER_IP,$STORAGE,$STORAGE_IP,localhost,127.0.0.1,.local
    if [ ! -z "$ADDITIONAL_NO_PROXY" ]; then
      NO_PROXY=$NO_PROXY,$ADDITIONAL_NO_PROXY
    fi
    echo "no_proxy: '$NO_PROXY'" >>  $APP_CONF_FILE
  fi
}

generate_nfs_vars(){
  echo "software_extra_packages: [nfs-common]" >> $GROUP_VARS_ALL
  cp $FILES_DIR/deepops/nfs-server.yml $GROUP_VARS_DIR
}

# kubesprayのhelmはバグでデプロイできないのでdeepopsと別でインストールする
replace_group_vars(){
  sed -i 's/helm_enabled: true/helm_enabled: false/g' $GROUP_VARS_K8S
}

generate_deepops_inventory(){
  # ,区切り => 改行
  GPU_NODES=$(echo -e "${GPU_NODES_COMMA//,/\\n}")

  ALL_NODES=$(echo -e "${KUBE_MASTER}\n${KQI_NODE}\n${STORAGE}\n${GPU_NODES}")  
  KUBE_NODES=$(echo -e "${KQI_NODE}\n${STORAGE}\n${GPU_NODES}")  
  # 重複排除
  ALL_NODES=$( IFS=$'\n' ; echo "${ALL_NODES[*]}" | sort | uniq ) 
  KUBE_NODES=$( IFS=$'\n' ; echo "${KUBE_NODES[*]}" | sort | uniq ) 

  for HOST in $ALL_NODES
  do
    NODE_IP=$(get_ip $HOST)
    ALL=$(echo -e "$HOST ansible_host=$NODE_IP\n$ALL\n")
  done

  ALL=$ALL \
  KUBE_MASTER=$KUBE_MASTER \
  ETCD=$KUBE_MASTER \
  KUBE_NODES=$KUBE_NODES \
  NFS=$STORAGE \
  SSH_USER=$SSH_USER \
  envsubst < $FILES_DIR/deepops/inventory.template > $INVENTORY
}

generate_helm_conf(){
  KQI_NODE=$KQI_NODE \
  INGRESS_NODE=$KQI_NODE \
  VIRTUAL_HOST=$KQI_NODE \
  NODES=${GPU_NODES_COMMA} \
  OBJECT_STORAGE=$STORAGE \
  OBJECT_STORAGE_PORT=9000 \
  OBJECT_STORAGE_ACCESSKEY=admin \
  NFS_STORAGE=$STORAGE \
  NFS_PATH=/var/lib/kamonohashi/nfs \
  envsubst < $FILES_DIR/kamonohashi-helm/settings.yml > $APP_CONF_FILE

  append_proxy_helm_conf
}

generate_conf(){
  generate_nfs_vars
  generate_deepops_inventory
  replace_group_vars
  generate_helm_conf
}

prepare_deepops(){
  git clone https://github.com/NVIDIA/deepops.git -b $DEEPOPS_VER
  cd $DEEPOPS_DIR
  ./scripts/setup.sh
}

# prepareでは設定ディレクトリのみ用意
prepare_helm(){
  cd $HELM_DIR
  mkdir -p kamonohashi/conf
}

prepare(){
  prepare_deepops
  prepare_helm
}

configure(){
  ask_conf
  generate_conf
}

clean(){
  case $1 in
    app)     
      cd $HELM_DIR
      ./deploy-kqi.sh clean
    ;;
    all)
      cd $DEEPOPS_DIR
      ansible-playbook kubespray/remove-node.yml --extra-vars "node=k8s-cluster" ${@:2}
    ;;
    *)
      echo "不明なcleanの引数: $1"
      exit 1
    ;;
  esac
}

deploy_nfs(){
  cd $DEEPOPS_DIR
  ansible-playbook -l nfs-server playbooks/nfs-server.yml $@
}

deploy_k8s(){
  cd $DEEPOPS_DIR
  ansible-playbook -l k8s-cluster playbooks/k8s-cluster.yml $@
}

deploy_kqi_helm(){
  cd $HELM_DIR
  if [ -z "$1" ]; then
    echo -en "Admin Passwordを入力: "; read -s PASSWORD
    echo "" # read -s は改行しないため、echoで改行
  else
    PASSWORD=$1
  fi

  ./deploy-kqi.sh prepare
  PASSWORD=$PASSWORD DB_PASSWORD=$PASSWORD STORAGE_PASSWORD=$PASSWORD ./deploy-kqi.sh credentials
  ./deploy-kqi.sh deploy
}

# 呼び出しフォーマット: deploy <sub command> <deepopsのコマンドに渡す引数群(${@:2})>
deploy(){
  case $1 in
    infra) deploy_k8s ${@:2} && deploy_nfs ;; 
    nfs) deploy_nfs ${@:2} ;;
    k8s) deploy_k8s ${@:2} ;;
    app) deploy_kqi_helm ;;
    all) 
      echo -en "Admin Passwordを入力: "; read -s PASSWORD
      echo "" # read -s は改行しないため、echoで改行
      deploy_k8s ${@:2} &&
      deploy_nfs &&
      deploy_kqi_helm $PASSWORD
      ;;
    *)
      echo "deployの引数は all, infra, nfs, k8s, app が指定可能です"
      echo "不明なdeployの引数: $1"
      exit 1
    ;;
  esac
}

main(){
  cd $SCRIPT_DIR
  set -e
  case $1 in
    prepare) prepare;;
    configure) configure ;;
    deploy) deploy ${@:2};;
    clean) clean ${@:2};;
    help) show_help ;;
    *) show_help ;;
  esac
}

main $@