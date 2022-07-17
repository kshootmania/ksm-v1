#ifndef KSON_AS
#define KSON_AS

#uselib "kson.dll"
#cfunc KSON_GetVersion "KSON_GetVersion"
#func KSON_FromKSH "KSON_FromKSH" sptr, int
#func KSON_FromKSH_URLEncoded "KSON_FromKSH_URLEncoded" sptr, int

#endif