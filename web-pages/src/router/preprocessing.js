// 前処理管理
import Index from '@/views/preprocessing/Index'
import Create from '@/views/preprocessing/Create'
import Edit from '@/views/preprocessing/Edit'
import Run from '@/views/preprocessing/Run'

// 前処理履歴管理
import HistoryIndex from '@/views/preprocessing/HistoryIndex'
import HistoryEdit from '@/views/preprocessing/HistoryEdit'
import Shell from '@/views/common/Shell'
import LogViewer from '@/views/common/LogViewer'

export default [
  // 前処理管理
  {
    path: '/preprocessing',
    name: 'Preprocessing',
    component: Index,
    children: [
      // 前処理作成画面
      {
        path: 'create',
        component: Create,
      },
      {
        path: 'create/:originId?',
        component: Create,
        props: true,
      },
      {
        path: ':id/edit',
        component: Edit,
        props: true,
      },
      // 作成した前処理を利用し、前処理を実行する画面
      {
        path: 'run',
        component: Run,
        props: true,
      },
    ],
  },
  // 前処理履歴管理
  {
    path: '/preprocessingHistory/:id',
    name: 'preprocessingHistory',
    component: HistoryIndex,
    props: true,
    children: [
      {
        path: ':dataId',
        component: HistoryEdit,
        props: true,
      },
      {
        path: ':dataId/shell',
        component: Shell,
        props: true,
      },
      {
        path: ':dataId/log',
        component: LogViewer,
        props: true,
      },
    ],
  },
]
