#ifndef __MOD_STRLU_AS__
#define  __MOD_STRLU_AS__
#module "m_strlu"
#uselib "user32.dll"
#func CharLower@m_strlu "CharLowerA" var
#func CharUpper@m_strlu "CharUpperA" var
 
; •¶š—ñ‚ğ¬•¶š‚É•ÏŠ·
#deffunc strlower var v1
    CharLower v1
    return
 
; •¶š—ñ‚ğ‘å•¶š‚É•ÏŠ·
#deffunc strupper var v1
    CharUpper v1
    return
 
; strlower ‚ÌŠÖ””Å
#defcfunc strlowerf str s1, local l1
    l1 = s1
    strlower l1
    return l1
 
; strupper ‚ÌŠÖ””Å
#defcfunc strupperf str s1, local l1
    l1 = s1
    strupper l1
    return l1
#global
#endif  ; end of __MOD_STRLU_AS__