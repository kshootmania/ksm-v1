#ifndef BASS_VST_AS
#define BASS_VST_AS

#uselib "bass_vst.dll"
#cfunc BASS_VST_ChannelSetDSP "BASS_VST_ChannelSetDSP" int,sptr,int,int
#func BASS_VST_SetParam "BASS_VST_SetParam" int,int,float
#cfunc BASS_VST_GetParam "BASS_VST_GetParam" int,int

#endif
