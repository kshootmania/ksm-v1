#include "third_party/alib_hash.as"
#include "src/ksmcore.as"

#module key_sound

#define ctype s_keySoundLibrary(%1) HashElem(s_keySoundLibrary, %1)

//
// key_soundモジュールを初期化
//
//   p1: 実行ファイルがあるディレクトリのパス(dir_default)
//
#deffunc initKeySoundModule str p1
	s_dirDefault = p1

	// キー音を格納しておくライブラリ
	// (キー音の名前とKeySoundへのポインタを対応付ける辞書: dict<str, KeySound*>)
	HashInitInt s_keySoundLibrary
	HashClear s_keySoundLibrary
	return

//
// キー音の名前から音声ファイルのパスを取得
// (拡張子がない場合には"se\note"ディレクトリ内のファイルを使用)
//
//   p1: キー音の名前(例:"clap")
//   p2: 譜面ファイルのディレクトリ絶対パス(末尾の\は不要)
//
#defcfunc getFilePathByKeySoundName str p1, str p2, local name
	if(getpath(p1, 2) = ""){
		return s_dirDefault + "\\se\\note\\" + p1 + ".wav"
	} else {
		return p2 + p1
	}

//
// 指定バージョンにおけるキー音の最大同時発音数を取得
//
//   p1: ksh譜面の"ver"フィールドの整数部分(int型)
//
#defcfunc local getMaxPolyphonyForVersion int p1
	if (p1 >= 171) {
		return 1
	} else {
		return 10
	}

//
// キー音をライブラリに読み込む
// (同じキー音が既に読み込まれている場合は何もしない)
//
//   p1: キー音の名前(例:"clap")
//   p2: 譜面ファイルのディレクトリ絶対パス(末尾の\は不要)
//   p3: ksh譜面の"ver"フィールドの整数部分(int型)
//
#deffunc loadKeySoundToLibrary str p1, str p2, int p3, local soundFilePath, local pKeySound
	// まだ読み込んだことがない効果音の場合は読み込む
	if (HashCheckKey(s_keySoundLibrary, p1) = 0) {
		// 音声ファイルのパスを取得して存在チェック
		soundFilePath = getFilePathByKeySoundName(p1, p2)
		exist soundFilePath
		if(strsize <= 0){
			dialog "Error: Cannot open sound \"" + soundFilePath + "\""
		}

		// KeySoundの実体を生成
		pKeySound = 0
		if (CreateKeySound@(soundFilePath, getMaxPolyphonyForVersion(p3), varptr(pKeySound))) {
			s_keySoundLibrary(p1) = pKeySound
		} else {
			dialog "Error: An error occurred while loading sound \"" + p1 + "\""
			s_keySoundLibrary(p1) = 0
		}
	}
	return

//
// キー音がライブラリに存在するかを調べる
//
//   p1: キー音の名前(例:"clap")
//
#defcfunc keySoundExistsInLibrary str p1
	return HashCheckKey(s_keySoundLibrary, p1)

//
// キー音の名前をもとにライブラリ内のKeySoundへのポインタを取得
//
//   p1: キー音の名前(例:"clap")
//
#defcfunc getKeySoundFromLibrary str p1
	if (HashCheckKey(s_keySoundLibrary, p1) = 0) {
		// ライブラリに存在しない場合はNULLを返す
		dialog "Error: Unknown keysound \"" + p1 + "\" is referenced by getKeySoundFromLibrary@key_sound"
		return 0
	}
	return s_keySoundLibrary(p1)

//
// ライブラリのキー音をクリア
//
#deffunc clearKeySoundLibrary onexit
	foreach s_keySoundLibrary_keys
  		if (s_keySoundLibrary_keys(cnt) = "") : continue
  		if (s_keySoundLibrary_values.cnt = 0) : continue
		DestroyKeySound@ s_keySoundLibrary_values.cnt
	loop
	HashClear s_keySoundLibrary
	return

#global