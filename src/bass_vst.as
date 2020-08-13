#ifndef BASS_VST_AS
#define BASS_VST_AS

#uselib "bass_vst.dll"
#cfunc BASS_VST_ChannelSetDSP "BASS_VST_ChannelSetDSP" int,sptr,int,int
#func BASS_VST_SetParam "BASS_VST_SetParam" int,int,float
#cfunc BASS_VST_GetParam "BASS_VST_GetParam" int,int

#module
// �{�̂̃v���C��ʂŎ��ۂɌĂ΂��BASS_VST_SetParam
// (ID�̑��݃`�F�b�N�E�G���[���̍Ď��s�t��)
#deffunc BASS_VST_SetParam_R int vst_a, int vst_b, double vst_c
	if (vst_a != -1) {
		// �G���[���̍Ď��s��������ʂ����ۂɂ���̂��͏ڍוs��
		// (��������̕s�s��������������������ꂽ�H)
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
