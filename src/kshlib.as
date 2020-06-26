#ifndef KSHLIB_AS
#define KSHLIB_AS

#uselib "kshlib.dll"
#cfunc KSHLib_GetVersion "KSHLib_GetVersion"
#func KSHLib_Init "KSHLib_Init" sptr
#cfunc KSHLib_SwitchAudioOpen "KSHLib_SwitchAudioOpen" int, sptr, int
#func KSHLib_SwitchAudioFree "KSHLib_SwitchAudioFree" int
#cfunc KSHLib_BASS_VST_GetParam_Double "KSHLib_BASS_VST_GetParam_Double" int, int
#func KSHLib_GetTwitterAPIKey "KSHLib_GetTwitterAPIKey" int, int
#func KSHLib_GetHMACSHA1 "KSHLib_GetHMACSHA1" sptr, sptr, var
#cfunc KSHLib_GetTwitterStringLength "KSHLib_GetTwitterStringLength" sptr
#cfunc KSHLib_OpenChartFile "KSHLib_OpenChartFile" sptr
#func KSHLib_CloseChartFile "KSHLib_CloseChartFile" int
#cfunc KSHLib_GetChartMetaDataValueLength "KSHLib_GetChartMetaDataValueLength" int, sptr, sptr
#func KSHLib_GetChartMetaDataValue_ "KSHLib_GetChartMetaDataValue" int, sptr, var, sptr
#cfunc KSHLib_IsChartUTF8 "KSHLib_IsChartUTF8" int
#func KSHLib_GetChartMD5Hash "KSHLib_GetChartMD5Hash" sptr, var
#cfunc KSHLib_IsDirectoryUpdated "KSHLib_IsDirectoryUpdated" sptr, sptr, var
#module
#defcfunc KSHLib_GetChartMetaDataValue int pChart, str key, str defaultValue
	sdim ret, KSHLib_GetChartMetaDataValueLength@(pChart, key, defaultValue)
	KSHLib_GetChartMetaDataValue_@ pChart, key, ret, defaultValue
	return ret
#global

#endif