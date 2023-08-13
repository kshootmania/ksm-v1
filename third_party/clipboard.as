/*====================================================================
クリップボード操作をするモジュール
for HSP3.0β10          2005. 7.17
for HSP3.0                   10.29  作成途中
                        2006. 1.22  無理難題(SetClipBmpできね～)
for HSP3.0a                  11.26  難題攻略 私頑張った bmp完成
                             12. 5  text完成
for HSP3.22             2011. 4. 7  プチ整形
                                 8  勢い余って大改造。File完成
for HSP3.3                   11.14  改造：ClipB_GetFile
                                18  作成：ClipB_GetFileMode ClipB_SetEmpty
                                    改造：ClipB_SetFile
----------------------------------------------------------------------
クリップボードの文字列を取得する
    ClipB_GetText 文字列が代入される変数
        文字列がない場合には、変数に""が代入される

クリップボードに文字列を転送する
    ClipB_SetText 転送する文字列
        stat = 1(成功) or 0(失敗)

クリップボードのビットマップのサイズを取得する
    ClipB_GetBmpSize  Xsizeを得る変数 , Ysizeを得る変数
        ビットマップがない場合は、Xsize = Ysize = 0

クリップボードのビットマップをウインドウにコピーする
    ClipB_GetBmp コピー元の左上X, Y, コピーする大きさX, Y
        stat = 1(成功) or 0(失敗)
        カレントポジションにコピーする。redraw 1で画面に反映。

クリップボードに画像を転送する
    ClipB_SetBmp 転送する画像の左上X, Y, 転送する大きさX, Y

クリップボードからファイルやフォルダの一覧を取得する
    ClipB_GetFile  変数
        変数    ファイル一覧が代入される文字列型変数。
                一覧は改行区切り(メモリーノート形式)で格納される。
                ※ ファイル1つでも改行が入る。
        stat    取得したファイルの数
                0は失敗した場合か、ファイルが1つもなかった場合
        本命令を実行しても元のファイル達に影響はない。

クリップボードにファイルが乗せられた時の情報を取得する関数
    ClipB_GetFileMode()         ※パラメータなし
        戻り    以下の合計値
                 0: 失敗、または情報なし
                +1: コピーモード
                +2: 移動(切り取り)モード
                +4: リンクを確立できます？
        エクスプローラなどで"コピー"操作をした場合 = 5、"切り取り"操作の場合 = 2

クリップボードにファイルをコピーする
    ClipB_SetFile 文字列, モード
        文字列  ファイル、ディレクトリの一覧(改行区切り)
                相対パスは絶対パスに変換するが、パスが通るかのチェックはしていない。
        モード  どのような操作でクリップボードに渡すか
                2:  エクスプローラなどで"切り取り"(移動)したのと同じ効果
                5:  エクスプローラなどで"コピー"したのと同じ効果
        stat    クリップボードに転送したパスの数
        エクスプローラなどに"貼り付け"できる。
        この命令は、モジュール内でメモリーノートを使用してる。

クリップボードを空にする
    ClipB_SetEmpty

====================================================================*/
#ifndef ClipboardModuleIncluded
#define ClipboardModuleIncluded
#module ClipboardModule

#uselib "kernel32.dll"      ;★グローバルメモリ
#func GlobalAlloc   "GlobalAlloc"   int, int    ;開放必須
#func GlobalFree    "GlobalFree"    int
#func GlobalLock    "GlobalLock"    int         ;解放必須
#func GlobalUnlock  "GlobalUnlock"  int
#func GlobalSize    "GlobalSize"    int
#define GMEM_FIXED      0           ;固定メモリを確保する
#define GMEM_MOVEABLE   2           ;移動可能メモリを確保する
#define GMEM_ZEROINIT   $40         ;0で初期化する
#define GMEM_SHARE      8192        ;DDE関数かクリップボードで使用する場合指定する
#define GHND            $42         ;GMEM_MOVEABLE + GMEM_ZEROINIT

#uselib "kernel32.dll"      ;★ファイルパス変換
#func GetFullPathName "GetFullPathNameA" str, int, var, nullptr

#uselib "user32.dll"
#func OpenClipboard     "OpenClipboard"     int
#func CloseClipboard    "CloseClipboard"
#func GetClipboardData  "GetClipboardData"  int
#func SetClipboardData  "SetClipboardData"  int, int
#func EmptyClipboard    "EmptyClipboard"
#func IsClipboardFormatAvailable "IsClipboardFormatAvailable" int
#define CF_TEXT     1
#define CF_BITMAP   2
#define CF_HDROP    15
#func RegisterClipboardFormat "RegisterClipboardFormatA" str
#define CFSTR_PREFERREDDROPEFFECT   "Preferred DropEffect"
#define DROPEFFECT_NONE             0
#define DROPEFFECT_COPY             1   ;コピー操作を実行できます。
#define DROPEFFECT_MOVE             2   ;移動操作を実行できます。
#define DROPEFFECT_LINK             4   ;ドロップされたデータと元のデータとのリンクを確立できます。
#define DROPEFFECT_SCROLL   $80000000   ;ドラッグ スクロール操作を実行できることを示します。

#uselib "USER32.dll"
#func GetDC     "GetDC"     int
#func ReleaseDC "ReleaseDC" int, int

#uselib "GDI32.dll"
#func CreateCompatibleDC "CreateCompatibleDC" int
#func DeleteDC          "DeleteDC"      int
#func SelectObject      "SelectObject"  int, int
#func DeleteObject      "DeleteObject"  int
#func CreateCompatibleBitmap "CreateCompatibleBitmap" int, int, int
#func BitBlt            "BitBlt"        int, int, int, int, int, int, int, int, int
#func GetClipBox        "GetClipBox"    int, var

#uselib "shell32.dll"       ;★ドラッグ＆ドロップをするAPI
#func DragQueryFile "DragQueryFileA" int, int, var, int

#deffunc ClipB_GetText var t
    t = ""
    IsClipboardFormatAvailable CF_TEXT  : if stat == 0  : return ; テキストはない
    OpenClipboard hwnd ; クリップボード開く
    if stat {
        GetClipboardData CF_TEXT  : ib = stat   ;   グローバルメモリのハンドル取得
        GlobalSize ib  : ib(1) = stat   ;   メモリサイズ
        GlobalLock ib  : ib(2) = stat   ;   メモリロック
        dupptr dp , ib(2) , ib(1) , 2
        t = dp  ;           データを手に入れた！
        GlobalUnlock ib ;   メモリアンロック
        CloseClipboard  ;   クリップボードを閉じる
    }
    return

#deffunc ClipB_SetText str s
    GlobalAlloc GMEM_ZEROINIT | GMEM_SHARE, strlen(s) + 2 ;グローバルメモリ確保
    ib = stat                       ;グローバルメモリのハンドル
    if ib == 0  : return 0          ;シッパイ！？
    GlobalLock ib  : ib(1) = stat   ;メモリロック
    dupptr dp, ib(1), strlen(s) + 2, 2  : dp = s    ;格納。
    GlobalUnlock ib                 ;メモリアンロック
    OpenClipboard hwnd              ;クリップボードを開く
    if stat {
        EmptyClipboard              ;クリップボードを空にする
        SetClipboardData CF_TEXT, ib;グローバルメモリを渡す
        CloseClipboard              ;クリップボードを閉じる
        return 1                    ;グローバルメモリはクリップボードの管轄に。
    }
    GlobalFree ib   ;渡せなかった場合は自力で開放する。
    return 0

#deffunc ClipB_GetBmpSize var x, var y
    x = 0  : y = 0
    IsClipboardFormatAvailable CF_BITMAP  : if stat == 0  : return  ;画像ある？
    OpenClipboard hwnd
    if stat {
        GetClipboardData CF_BITMAP
        ib = stat, 0, 0, 0, 0, 0
        SelectObject hdc, ib(0)  : ib(1) = stat ;自分でいいやっ。
        GetClipBox   hdc, ib(2)     ;これで大きさ取れる。
        SelectObject hdc, ib(1)     ;自分を取り戻す
        CloseClipboard
        x = ib(4)  : y = ib(5)      ;結果
    }
    return

#deffunc ClipB_GetBmp int x, int y, int w, int h
    IsClipboardFormatAvailable CF_BITMAP
    if stat == 0  : return 0    ;clipboardにbitmapがない

    OpenClipboard hwnd
    if stat {
        GetClipboardData CF_BITMAP  ;ビットマップのハンドルを取得
        ib = stat, 0, 0, 0, 0, 0, 0
        ;クリップボードとHSPではビットマップの形式が違う...
        CreateCompatibleDC hdc  : ib(1) = stat  ;新しいデバイスコンテキスト作成
        SelectObject ib.1, ib   : ib(2) = stat  ;BITMAP変更
        BitBlt hdc, ginfo(22), ginfo(23), w, h, ib(1), x, y, $00CC0020  ;コピー
        SelectObject ib(1), ib(2)   ;BITMAPもどす
        DeleteDC ib(1)              ;デバイスコンテキスト削除
        CloseClipboard  : return 1
    }
    return 0

#deffunc ClipB_SetBmp int x, int y, int w, int h
    // ib = HBitmap, DummyHBitmap, WorkHDC, miracleHDC
    GetDC                               : ib(3) = stat
    CreateCompatibleDC      ib(3)       : ib(2) = stat
    CreateCompatibleBitmap  ib(3), w, h : ib(0) = stat
    ReleaseDC               0, ib(3)
    SelectObject            ib(2), ib   : ib(1) = stat
    BitBlt  ib(2), 0, 0, w, h, hdc, x, y, $00CC0020
    SelectObject            ib(2), ib(1)
    DeleteDC                ib(2)

    OpenClipboard hwnd
    if stat {
        EmptyClipboard
        SetClipboardData CF_BITMAP, ib(0)
        CloseClipboard
    }
    DeleteObject ib(0)
    return

#deffunc ClipB_GetFile var t    ;クリップボードからファイルパスとってみよう
    t = ""  : sb = ""
    OpenClipboard hwnd
    if stat == 0  : return 0                ;クリップボードを開けなかった

    ib = 0, 0, 0, 0, 0      ;return値, GMhandle, GMpinter, FileCnt, temp

    IsClipboardFormatAvailable CF_HDROP             ;ファイルあるかな？
    if stat {                                       ;ファイルあったよ＼(^ ^)／
        GetClipBoardData CF_HDROP  : ib(1) = stat   ;ファイル名の詰まったGMげとー
        ;if ib(1) == 0                                  ;？有るって言ったのにっ！
        GlobalLock ib(1)  : ib(2) = stat
        DragQueryFile ib(2), -1, ib(3), 0           ;ファイル数ちぇくー
        ib(3) = stat
        repeat ib(3)
            DragQueryFile ib(2), cnt, sb, 0         ;まずは文字数だけ取得
            ib(4) = stat + 1  : memexpand sb, ib(4) ;メモリ大丈夫？
            DragQueryFile ib(2), cnt, sb, ib(4)     ;ファイル名を取得して
            t += sb + "\n"                          ;連結！
        loop
        GlobalUnlock ib(1)
        ib = ib(3)                                  ;ファイル一覧取得完了。
    }
    CloseClipboard                          ;開けたら閉めるは鉄則。
    return ib

#defcfunc ClipB_GetFileMode
    OpenClipboard hwnd
    if stat == 0  : return 0                        ;クリップボードを開けなかった

    ib = 0, 0, 0
    RegisterClipboardFormat CFSTR_PREFERREDDROPEFFECT
    ib(1) = stat                                    ;DragEffectの識別子入手
    if ib(1) {                                      ;失敗ってことは考えにくいけど...
        IsClipboardFormatAvailable ib(1)            ;特殊効果あるかな？
        if stat {                                   ;あった。
            GetClipBoardData ib(1)  : ib(2) = stat  ;ハンドルをもらって
            GlobalLock ib(2)                        ;資源をキャッチする
            dupptr dp, stat, 4, 4                   ;ターゲットロックオン！
            ib = dp                                 ;収集して
            GlobalUnlock ib(2)                      ;資源をリリースする
        }
    }
    CloseClipboard
    return ib

#deffunc ClipB_SetFile str s, int m, local t
    ib    = 0, 0, 0     ;hMem(path), hMem(effect), eff識別子
    ib(3) = 0, 0, 0     ;file数, file文字数nullコミ, tempo
    t = s               ;ファイルパス一覧
    sb = ""
    notesel t

    repeat noteinfo(0)              ;まずは下ごしらえ
        noteget sb, cnt
        GetFullPathName sb, 0, sb       ;ここの変数はダミー(ぬるぽ)
        ib(5) = stat                    ;フルパスの文字数(ぬるコミ)
        memexpand sb, ib(5)             ;フルパスを確実に格納できるように
        GetFullPathName sb, ib(5), sb   ;絶対パスゲトー
        noteadd sb, cnt, 1              ;絶対パスをもとの位置に戻す
        ib(4) += ib(5)                  ;ファイルパス文字数(null込)に加算
        ib(3) ++                        ;ファイル数増やす
    loop

    GlobalAlloc GMEM_ZEROINIT | GMEM_SHARE, ib(4) + 22  ;GM確保(ぜろクリ)
    ib = stat
    GlobalLock ib
    dupptr dp, stat, ib(4) + 22, 4  ;↓ゼロ(Null)分はいらないよ。
    dp    = 20          ;ファイル名までのoffset
    dp(1) = 0, 0        ;座標X,Y
    dp(3) = 0           ;場所(クライアント領域？)
    dp(4) = 0           ;パス格納方法(0:旧式 1:現代式)
    ib(5) = 20
    repeat ib(3)
        noteget sb, cnt
        memcpy dp, sb, strlen(sb) + 1, ib(5);ついでにNullも一緒に。
        ib(5) += strlen(sb) + 1
    loop
    poke dp, ib(5), 0   ;念のため、ふた(末尾のヌルヌル)する。
    GlobalUnlock ib

    noteunsel

    GlobalAlloc GMEM_ZEROINIT | GMEM_SHARE, 4   ;GM確保
    ib(1) = stat
    GlobalLock ib(1)
    dupptr dp, stat, 4, 4
    dp = m
    GlobalUnlock ib(1)

    RegisterClipboardFormat CFSTR_PREFERREDDROPEFFECT
    ib(2) = stat                    ;DragEffectの識別子入手

    OpenClipboard hwnd              ;クリップボードを開く
    if stat {
        EmptyClipboard              ;クリップボードを空にする
        SetClipboardData CF_HDROP, ib;グローバルメモリを渡す
        SetClipboardData ib(2), ib(1);グローバルメモリを渡す
        CloseClipboard              ;クリップボードを閉じる
        return ib(3)    ;グローバルメモリはクリップボードの管轄に。
    }
    GlobalFree ib       ;押し付け失敗した場合は自力で開放する。
    GlobalFree ib(1)    ;こっちも。
    return 0

#deffunc ClipB_SetEmpty
    OpenClipboard hwnd
    if stat == 0  : return 0
    EmptyClipboard
    CloseClipboard
    return 1

; http://www.tvg.ne.jp/menyukko/ ; Copyright(C) 2005-2011 衣日和 All rights reserved.
#global
#endif