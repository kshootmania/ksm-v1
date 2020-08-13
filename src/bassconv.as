#ifndef BASSCONV_AS
#define BASSCONV_AS

#uselib "bassconv.dll"
#cfunc BASS_ChannelGetLength_ms "BASS_ChannelGetLength_ms" int
#func BASS_ChannelSetPosition_ms "BASS_ChannelSetPosition_ms" int, int
#cfunc BASS_ChannelGetPosition_ms "BASS_ChannelGetPosition_ms" int

#endif
