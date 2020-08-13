#ifndef BASS_AS
#define BASS_AS

#uselib "bass.dll"
#func BASS_Init "BASS_Init" int, int, int, int, int
#cfunc BASS_GetVersion "BASS_GetVersion"
#func BASS_GetCPU "BASS_GetCPU"
#func BASS_Pause "BASS_Pause"
#func BASS_Start "BASS_Start"
#cfunc BASS_GetVolume "BASS_GetVolume"
#func BASS_SetVolume "BASS_SetVolume" int
#func BASS_Free onexit "BASS_Free"

#func BASS_PluginLoad "BASS_PluginLoad" sptr,int

#cfunc BASS_StreamCreateFile "BASS_StreamCreateFile" int, sptr, int, int, int, int, int
#cfunc BASS_StreamCreateURL "BASS_StreamCreateURL" sptr, int, int, int, int, int
#func BASS_StreamFree "BASS_StreamFree" int

#cfunc BASS_SampleLoad "BASS_SampleLoad" int, sptr, int, int, int, int, int
#cfunc BASS_SampleGetChannel "BASS_SampleGetChannel" int, int
#func BASS_SampleStop "BASS_SampleStop" int
#func BASS_SampleFree "BASS_SampleFree" int

#func BASS_ChannelPlay "BASS_ChannelPlay" int, int
#func BASS_ChannelPause "BASS_ChannelPause" int
#func BASS_ChannelStop "BASS_ChannelStop" int
#func BASS_ChannelSetAttributes "BASS_ChannelSetAttributes" int, int, int, int
#func BASS_ChannelIsActive "BASS_ChannelIsActive" int
#func BASS_ChannelSetAttribute "BASS_ChannelSetAttribute" int, int, float
#func BASS_ChannelSlideAttribute "BASS_ChannelSlideAttribute" int, int, float, int
#cfunc BASS_ErrorGetCode "BASS_ErrorGetCode"
#func BASS_ChannelSetLink "BASS_ChannelSetLink" int,int
#func BASS_ChannelSetSync "BASS_ChannelSetSync" int,int

#func BASS_SetConfig "BASS_SetConfig" int,int

#cfunc BASS_ChannelSetFX "BASS_ChannelSetFX" int,int,int
#func BASS_ChannelRemoveFX "BASS_ChannelRemoveFX" int,int
#func BASS_FXReset "BASS_FXReset" int
#func BASS_FXSetParameters "BASS_FXSetParameters" int,var

#func BASS_Update "BASS_Update" int
#func BASS_ChannelUpdate "BASS_ChannelUpdate" int,int

#define BASS_SAMPLE_LOOP 4

#endif
