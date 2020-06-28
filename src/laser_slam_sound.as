#include "src/ksmcore.as"

#module laser_slam_sound

//
// laser_slam_soundモジュールを初期化
//
//   p1: 実行ファイルがあるディレクトリのパス(dir_default)
//
#deffunc initLaserSlamSoundModule str p1, local filenamesStr, local filename
	s_dirDefault = p1
	s_maxPolyphony = -1 // 最大同時発音数(譜面のバージョンごとに異なるため、プレイ開始時にloadLaserSlamSoundsで指定する)
	return

//
// 指定バージョンにおける直角音の最大同時発音数を取得
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
// 直角音の音声ファイルをロードする
//
//   p1: ksh譜面の"ver"フィールドの整数部分(int型)
//
#deffunc loadLaserSlamSounds int p1, local pKeySound
	// 前回ロード時の最大同時発音数と異なる場合はロードし直す
	if (s_maxPolyphony != getMaxPolyphonyForVersion(p1)) {
		s_maxPolyphony = getMaxPolyphonyForVersion(p1)

		// 直角音の音声ファイル名
		filenamesStr  = "chokkaku.wav\n"
		filenamesStr += "chokkaku_down.wav\n"
		filenamesStr += "chokkaku_up.wav\n"
		filenamesStr += "chokkaku_swing.wav\n"
		filenamesStr += "chokkaku_mute.wav\n"

		// 直角音のKeySoundを生成
		notesel filenamesStr
		dim s_laserSlamKeySounds, notemax
		repeat notemax
			noteget filename, cnt
			filename = s_dirDefault + "\\se\\" + filename
			
			// KeySoundの実体を生成
			pKeySound = 0
			if (CreateKeySound@(filename, s_maxPolyphony, varptr(pKeySound))) {
				s_laserSlamKeySounds.cnt = pKeySound
			} else {
				dialog "Error: An error occurred while loading sound \"" + filename + "\""
			}
		loop
	}
	return

//
// 直角音を再生する
//
//   p1: 直角音の種類のID
//   p2: 音量(0.0～1.0)
//
#deffunc playLaserSlamSound int p1, double p2
	// 種類のIDが範囲外の場合は無視する
	if (p1 < 0 || p1 >= length(s_laserSlamKeySounds)) {
		return
	}

	// 再生
	if (s_laserSlamKeySounds.p1 != 0) {
		PlayKeySound@ s_laserSlamKeySounds.p1, p2
	}
	return

#global