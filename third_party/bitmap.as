
#module ;======================================================

#uselib "gdi32.dll"
#cfunc _CreateDC "CreateDCA" sptr, sptr, sptr, int
#cfunc _CreateCompatibleDC "CreateCompatibleDC" int
#cfunc _CreateCompatibleBitmap "CreateCompatibleBitmap" int, int, int
#func  _SelectObject "SelectObject" int, int
#func  _BitBlt "BitBlt" int, int, int, int, int, int, int, int, int
#func  _DeleteDC "DeleteDC" int
#func  _DeleteObject "DeleteObject" int

#define NULL 0
#define SRCCOPY     0x00CC0020

;--------------------------------------------------------------
; CreateBitmap  ディスプレイ互換DDBオブジェクト作成
;--------------------------------------------------------------
#defcfunc _CreateBitmap int px, int py, int sx, int sy

; ディスプレイのデバイスコンテキストのハンドル取得
hdcScreen = _CreateDC("DISPLAY", NULL, NULL, NULL)

; ディスプレイ互換ビットマップオブジェクト作成
hBitmap = _CreateCompatibleBitmap(hdcScreen, sx, sy)

; ディスプレイ互換デバイスコンテキスト作成
hdcMemory = _CreateCompatibleDC(hdcScreen)

; ビットマップをデバイスコンテキストに選択
_SelectObject hdcMemory, hBitmap
hOldBitmap = stat

; HSPウィンドウからビットマップにイメージをコピー
_BitBlt hdcMemory, 0, 0, sx, sy, hdc, px, py, SRCCOPY

; デバイスコンテキストの選択ビットマップを戻す
_SelectObject hdcMemory, hOldBitmap

; デバイスコンテキストを削除
_DeleteDC hdcMemory
_DeleteDC hdcScreen

; ビットマップオブジェクトのハンドルを返す
return hBitmap

;--------------------------------------------------------------
; CreateDIB  DIBセクションオブジェクト作成
;--------------------------------------------------------------
#defcfunc CreateDIB int px, int py, int sx, int sy

; DIBセクションオブジェクト作成
hBitmap = _CreateCompatibleBitmap(hdc, sx, sy)

; メモリデバイスコンテキスト作成
hdcMemory = _CreateCompatibleDC(hdc)

; ビットマップをデバイスコンテキストに選択
_SelectObject hdcMemory, hBitmap
hOldBitmap = stat

; HSPウィンドウからビットマップにイメージをコピー
_BitBlt hdcMemory, 0, 0, sx, sy, hdc, px, py, SRCCOPY

; デバイスコンテキストの選択ビットマップを戻す
_SelectObject hdcMemory, hOldBitmap

; デバイスコンテキストを削除
_DeleteDC hdcMemory

; ビットマップオブジェクト(DIBセクション)のハンドルを返す
return hBitmap

;--------------------------------------------------------------
; DeleteBitmap  ビットマップオブジェクト削除
;--------------------------------------------------------------
#deffunc DeleteBitmap int hbmp

; ビットマップオブジェクトを削除
_DeleteObject hbmp
return

#global ;======================================================