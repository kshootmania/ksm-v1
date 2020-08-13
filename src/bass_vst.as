#ifndef BASS_VST_AS
#define BASS_VST_AS

#uselib "bass_vst.dll"
#cfunc BASS_VST_ChannelSetDSP "BASS_VST_ChannelSetDSP" int,sptr,int,int
#func BASS_VST_SetParam "BASS_VST_SetParam" int,int,float
#cfunc BASS_VST_GetParam "BASS_VST_GetParam" int,int

#module
// 本体のプレイ画面で実際に呼ばれるBASS_VST_SetParam
// (IDの存在チェック・エラー時の再試行付き)
#deffunc BASS_VST_SetParam_R int vst_a, int vst_b, double vst_c
	if (vst_a != -1) {
		// エラー時の再試行が効く場面が実際にあるのかは詳細不明
		// (何かしらの不都合があったから実装された？)
		repeat 5
			BASS_VST_SetParam@ vst_a, vst_b, vst_c
			if (BASS_ErrorGetCode@() = 0) {
				break
			}
		loop
	}
	return
#global

#endif
