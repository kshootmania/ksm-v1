#uselib "ksmcore.dll"
#cfunc CreateGameSystem "CreateGameSystem" sptr, double, int
#func DestroyGameSystem "DestroyGameSystem" int
#func UpdateGameSystem "UpdateGameSystem" int, double
#func GetCurrentCamValue_ "GetCurrentCamValue" int, int, var
#cfunc CreateKeySound "CreateKeySound" sptr, int, int
#func DestroyKeySound "DestroyKeySound" int
#func PlayKeySound "PlayKeySound" int, double

#enum CAM_ZOOM_TOP = 0
#enum CAM_ZOOM_BOTTOM
#enum CAM_ZOOM_SIDE
#enum CAM_CENTER_SPLIT
#enum CAM_MANUAL_TILT

#module
#defcfunc GetCurrentCamValue int pGameSystem, int camParam, local ret
	ret = 0.0f
	GetCurrentCamValue_@ pGameSystem, camParam, ret
	return ret
#global
