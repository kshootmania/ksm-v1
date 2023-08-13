#ifndef WINAPI_AS
#define WINAPI_AS

#define ctype LOWORD(%1) (%1 & 0xFFFF)

#uselib "user32"
#func IsIconic "IsIconic" sptr
#func ShowWindow "ShowWindow" sptr,sptr
#func EnableWindow "EnableWindow" int, int
#func ScreenToClient "ScreenToClient" int, int
#func f_SetWindowPos "SetWindowPos" int , int , int , int , int , int , int
#func SetWindowTextW "SetWindowTextW" wptr,wptr
#func GetWindowTextW "GetWindowTextW" wptr,wptr,wptr
#func GetDC "GetDC" sptr
#func OpenClipboard "OpenClipboard" sptr
#func CloseClipboard "CloseClipboard"
#func SetClipboardData "SetClipboardData" sptr,sptr
#func EmptyClipboard "EmptyClipboard"
#func ReleaseDC "ReleaseDC" sptr,sptr

#func CheckMenuItem "CheckMenuItem" int,int,int
#func EnableMenuItem "EnableMenuItem" int,int,int

#func TrackPopupMenuEx   "TrackPopupMenuEx"   int,int,int,int,int,int
#func DestroyMenu        "DestroyMenu"        int
#func ClientToScreen     "ClientToScreen"     int,int

#define MF_POPUP            0x0010
#define MF_SEPARATOR        0x0800
#define WM_NOTIFY           0x004E
#define TBN_DROPDOWN          -710
#define TB_BUTTONSTRUCTSIZE 0x041E
#define TB_ADDBITMAP        0x0413
#define TB_AUTOSIZE         0x0421
#define TB_ADDBUTTONS       0x0414
#define TB_SETEXTENDEDSTYLE 0x0454
#define TB_GETRECT          0x0433
#define TBSTYLE_EX_DRAWDDARROWS  1

#uselib "kernel32"
#cfunc c_LoadLibrary "LoadLibraryA" str
#func  f_FreeLibrary "FreeLibrary" int
#define GetTempPath GetTempPathA
#func GetTempPathA "GetTempPathA" sptr,sptr
#define GetLongPathName GetLongPathNameA
#func GetLongPathNameA "GetLongPathNameA" sptr,sptr,sptr
#define DeleteFile DeleteFileA
#func DeleteFileA "DeleteFileA" sptr
#define RemoveDirectory RemoveDirectoryA
#func RemoveDirectoryA "RemoveDirectoryA" sptr
#define MoveFile MoveFileA
#func MoveFileA "MoveFileA" sptr,sptr

#uselib "gdi32"
#func CreateFontIndirect "CreateFontIndirectA" sptr
#func DeleteObject "DeleteObject" sptr
#func CreateCompatibleDC "CreateCompatibleDC" sptr
#func CreateCompatibleBitmap "CreateCompatibleBitmap" sptr,sptr,sptr
#func SelectObject "SelectObject" sptr,sptr
#func DeleteDC "DeleteDC" sptr
#func BitBlt "BitBlt" sptr,sptr,sptr,sptr,sptr,sptr,sptr,sptr,sptr

#const DT_WORDBREAK		0x00000010
#const DT_EDITCONTROL	0x00002000
// http://hsp.tv/play/pforum.php?mode=pastwch&num=41339
#const WS_CHILD			$40000000
#const WS_VISIBLE		$10000000
#const WS_BORDER		$800000
#const WS_TABSTOP		$10000
#const ES_AUTOHSCROLL	$80
#const STYLE			WS_CHILD | WS_VISIBLE | WS_TABSTOP | ES_AUTOHSCROLL
#const UNKNOWN			$200 ; HSPのインプットボックスに設定されていたEXスタイルの値
#const WM_SETFONT    	0x0030

#uselib "msvcrt"
#func ren "rename" str, str

#uselib "comctl32.dll"
#func InitCommonControls "InitCommonControls"

#endif
