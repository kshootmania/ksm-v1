#module
#define BORDER_LOW  0x3FFF 
#define BORDER_HIGH 0xBFFF

#define global JOYERR_BASE            160
#define global MMSYSERR_NODRIVER     (MMSYSERR_BASE + 6)  /* ジョイスティックドライバが存在しません。 */
#define global MMSYSERR_INVALPARAM   (MMSYSERR_BASE + 11) /* 無効なパラメータが渡されました。 */
#define global MMSYSERR_BADDEVICEID  (MMSYSERR_BASE + 2)  /* 指定されたジョイスティック識別子は無効です。 */
#define global JOYERR_UNPLUGGED      (JOYERR_BASE+7)      /* 指定されたジョイスティックはシステムに接続されていません。 */
#define global JOYERR_NOERROR        0    ;関数が成功
 
#define global JOYERR_PARMS 165      /* 指定されたジョイスティックデバイスの識別子 uJoyID は無効です。 */
 
#uselib "winmm.dll"
 
#func _joyGetPosEx "joyGetPosEx" int, var
#func joyGetNumDevs "joyGetNumDevs"
#func _joyGetDevCaps "joyGetDevCapsA" int, int, int
;joyGetDevCapsA uJoyID, pjc, cbjc
;	uJoyID	:照会するジョイスティック
;	pjc		:JOYCAPS 構造体のアドレス
;	cbjc	:JOYCAPS 構造体のサイズをバイト単位で指定。
 
;-----------------------------------------------
;モジュールの初期化
;JStickIni
;	プログラム中で宣言する必要はありません。
#deffunc JStickIni
    dim joycaps, 404/4    ;JOYCAPS構造体(404byte)
    joyGetNumDevs    ;ジョイスティックドライバにサポートされるジョイスティック数を取得。
    JOYNUMDEV = stat    ;ドライバが存在しない場合は、0 が返ります。
    return JOYNUMDEV
 
;ジョイスティックの位置とボタンの状態を取得する命令
;joyGetPosEx int p1, var data
;	p1：パッドID
;	data.0 = 常に 52  が入ります
;	data.1 = 常に 255 が入ります
;	data.2 = 第 1 軸の状態（普通のジョイスティックの X 軸）
;	data.3 = 第 2 軸の状態（普通のジョイスティックの Y 軸）
;	data.4 = 第 3 軸の状態（スロットル等）
;	data.5 = 第 4 軸の状態
;	data.6 = 第 5 軸の状態
;	data.7 = 第 6 軸の状態
;	data.8 = ボタンの状態（最大32ボタン）
;	data.9 = 同時に押されているボタンの数
;	data.10 = POV スイッチの状態
;	data.11 = 予備情報1
;	data.12 = 予備情報2
;
;	stat = 0 であれば入力は正常です。
;	返り値					説明
;	JOYERR_NOERROR			関数が成功。ジョイスティックは接続され正常に動作しています。
;	MMSYSERR_NODRIVER		ジョイスティックドライバが存在しません。
;	MMSYSERR_INVALPARAM		無効なパラメータが渡されました。
;	MMSYSERR_BADDEVICEID	指定されたジョイスティック識別子は無効です。
;	JOYERR_UNPLUGGED		指定されたジョイスティックはシステムに接続されていません。
;	JOYERR_PARMS			指定されたジョイスティックデバイスの識別子 uJoyID は無効です。
;
;	dataはあらかじめdim data,13として配列を確保しておいてください。
/*
#deffunc joyGetPosEx int p1, array data
    data = 52,255    ;JOYINFOEX構造体:dwSize, dwFlags
    _joyGetPosEx p1, data
    return stat
*/
 
 
;-----------------------------------------------
;使用可能なジョイスティックIDを検出する関数
;	JStickSearchID startnum, joyidlist, number
;		startnum	：検出を開始するID（0～）
;		joyidlist	：検出したIDの一覧を格納する配列変数。
;					　使用可能なジョイスティックのID（0～）をすべて検出します。
;		number		：検出する個数。省略(=0)のときは全て。
;		返り値：検出したIDの個数
#deffunc JStickSearchID int _startnum, array joyidlist, int _number
    startnum = limit(_startnum, 0, JOYNUMDEV)
    if _number<=0 : number = JOYNUMDEV : else : number = _number
    joyidmax = 0
    repeat JOYNUMDEV - startnum, startnum
        joyGetPosEx data,cnt
        if stat = 0 {
            joyidlist(joyidmax) = cnt
            joyidmax++
            if joyidmax>=number : break
        }
    loop
    return joyidmax
 
 
;-----------------------------------------------
;ジョイスティックの名称を取得します。
;	name = JStickGetDevCapsPname( _uJoyID )
;		_uJoyID	：(0～)ジョイパッドのid
;		返り値	：取得したジョイパッド名
#defcfunc JStickGetDevCapsPname int _uJoyID
    if ( _uJoyID < 0 )|( _uJoyID >= JOYNUMDEV ) : return -1    ;指定されたidは使用できません。
    _joyGetDevCaps _uJoyID, varptr(joycaps), length(joycaps)*4
    if stat : return ""        ;正常に情報が取得できなかった。
    name = ""
    getstr name, joycaps, 4
    return name
 
 
;-----------------------------------------------
;ジョイスティックの性能を取得します。
;	JStickGetDevCaps _uJoyID, jinfo
;		_uJoyID	：(0～)ジョイパッドのid
;		jinfo	：取得したジョイスティックの性能値。整数型の配列変数。要素の最大は19個。
;				必ず　dim jinfo, 19　として配列を確保しておいてください。
;			jinfo(0)  = wXmin;		/* X-座標 */
;			jinfo(1)  = wXmax;		/* X-座標 */
;			jinfo(2)  = wYmin;		/* Y-座標 */
;			jinfo(3)  = wYmax;		/* Y-座標 */
;			jinfo(4)  = wZmin;		/* Z-座標 */
;			jinfo(5)  = wZmax;		/* Z-座標 */
;			jinfo(6)  = wNumButtons;/* ボタンの数 */
;			jinfo(7)  = wPeriodMin;	/* ポーリング間隔の最小値 */
;			jinfo(8)  = wPeriodMax;	/* ポーリング間隔の最大値 */
;			jinfo(9)  = wRmin;		/* r座標の最小値 */
;			jinfo(10) = wRmax;		/* r座標の最大値 */
;			jinfo(11) = wUmin;		/* u座標の最小値 */
;			jinfo(12) = wUmax;		/* u座標の最大値 */
;			jinfo(13) = wVmin;		/* v座標の最小値 */
;			jinfo(14) = wVmax;		/* v座標の最大値 */
;			jinfo(15) = wCaps;		/* 能力フラグ */
;			jinfo(16) = wMaxAxes;	/* 座標軸の最大数 */
;			jinfo(17) = wNumAxes;	/* 座標軸の数 */
;			jinfo(18) = wMaxButtons;/* ボタンの最大数 */
#deffunc JStickGetDevCaps int _uJoyID, array jinfo
    if ( _uJoyID < 0 )|( _uJoyID >= JOYNUMDEV ) : return -1    ;指定されたidは使用できません。
    uJoyID = _uJoyID        ;0～
    _joyGetDevCaps uJoyID, varptr(joycaps), length(joycaps)*4
    if stat : return stat        ;正常に情報が取得できなかった。
 
    repeat 19
        jinfo(cnt) = lpeek(joycaps, cnt*4+36)
    loop
    return
 
 
 
#global
JStickIni
;OSのジョイパッド最大認識個数
maxjoystick = stat    ;この変数には値を代入しないようにしてください。
 
;モジュールここまで
