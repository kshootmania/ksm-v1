#module filesystem_utils

//
// ファイルが存在するかをboolで返す
// (strsizeが指定されたファイルのファイルサイズで上書きされるので注意)
//
//   p1: ファイルパスの文字列
//
#defcfunc fileExists str p1
	exist p1
	return strsize != -1

//
// ディレクトリパスが存在するかをboolで返す
// (ワイルドカードの存在は検査しないので、文字列内に"*"を含めないこと)
//
//   p1: ディレクトリパスの文字列
//
#defcfunc dirExists str p1, local path, local fileListStr
	path = p1

	// 末尾の'\'と'/'を取り除く
	path = strtrim(path, 2/*右端のみ*/, '/')
	path = strtrim(path, 2/*右端のみ*/, '\\')

	// 存在をチェック
	dirlist fileListStr, path, 5/*ディレクトリのみ*/

	return fileListStr != ""

//
// 存在チェック付きchdir
// (内部エラー12発生前にパス名の情報をダイアログ表示する多少マシなver)
//
//   p1: ディレクトリパスの文字列
//
#deffunc safeChdir str p1
	if (dirExists(p1) = 0) {
		dialog "エラー: 下記ディレクトリが開けませんでした。フォルダ名に特殊文字が含まれていないかご確認ください。\nError: Failed to open the following directory. Make sure the folder name does not contain special characters.\n\n" + p1
	}
	chdir p1
	return

//
// 存在チェック付きchdir[関数版] (chdirに失敗したかどうかをboolで返す)
//
//   p1: ディレクトリパスの文字列
//   p2: ディレクトリが存在しなかった場合に関数内で警告ダイアログを表示させるかどうか(bool, デフォルト:true)
//
#defcfunc local safeChdirC_ str p1, int p2
	if (dirExists(p1)) {
		// 成功
		chdir p1
		return 1
	} else {
		// 失敗
		if (p2) : dialog "警告: 下記ディレクトリが開けませんでした。フォルダ名に特殊文字が含まれていないかご確認ください。\nWarning: Failed to open the following directory. Make sure the folder name does not contain special characters.\n\n" + p1
		return 0
	}

// 存在チェック付きchdir[関数版]のデフォルト引数定義
#define global ctype safeChdirC(%1, %2 = 1)  safeChdirC_@filesystem_utils(%1, %2)

#global

// マクロが定義されている場合はchdirをsafeChdirに置換
#ifdef FS_UTILS_REPLACE_CHDIR_WITH_SAFE_CHDIR
#undef chdir
#define global chdir(%1) safeChdir %1
#endif