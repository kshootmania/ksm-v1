#module key_sound

//
// key_soundモジュールを初期化
//
//   p1: 実行ファイルがあるディレクトリのパス(dir_default)
//
#deffunc initKeySoundModule str p1
	dir_default = p1
	return

//
// 指定バージョンにおけるノートSEの最大同時発音数を取得
//
//   p1: ksh譜面の"ver"フィールドの整数部分(int型)
//
#defcfunc getKeySoundMaxForVersion int p1
	if (p1 >= 171) {
		return 1
	} else {
		return 0
	}

#global