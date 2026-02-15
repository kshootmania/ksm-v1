#ifndef KSON_AS
#define KSON_AS

#uselib "kson.dll"
#cfunc KSON_GetVersion "KSON_GetVersion"
#func KSON_ToKSH "KSON_ToKSH" sptr, int
#func KSON_FromKSH "KSON_FromKSH" sptr, int, sptr, sptr
#func KSON_FromKSH_URLEncoded "KSON_FromKSH_URLEncoded" sptr, int, sptr, sptr
#func KSON_GetLastEditorDiagWarning "KSON_GetLastEditorDiagWarning" int
#func KSON_GetLastPlayerDiagWarning "KSON_GetLastPlayerDiagWarning" int

#endif