﻿using System.Collections.Generic;

namespace Nssol.Platypus.ApiModels.TrainingApiModels
{
    /// <summary>
    /// TensorBoard起動モデル
    /// </summary>
    public class TensorBoardInputModel
    {
        /// <summary>
        /// コンテナの生存期間(秒)
        /// </summary>
        public int? ExpiresIn { get; set; }

        /// <summary>
        /// 追加でマウントする学習履歴ID
        /// </summary>
        public IEnumerable<long> selectedHistoryIds { get; set; }

    }
}
