//==================================================================================================
// alib_hash.as / 簡易ハッシュモジュール
// Version 0.04, September 25, 2008
// Copyright (C) 綾織トモエ
// mailto:ayaoritomoe@gmail.com
// http://ayaoritomoe.oiran.org/
//--------------------------------------------------------------------------------------------------
// 動作環境：Windows (Windows XP で動作確認)
// 開発環境：Hot Soup Processor 3.1
// 取扱種別：フリーソフト
//==================================================================================================

/*

このプログラムはフリーソフトです。
自己責任でご自由にお使いください。

//--------------------------------------------------------------------------------------------------
// インストール
//--------------------------------------------------------------------------------------------------
このファイルを HSP の common フォルダか、使用するスクリプトがあるフォルダにコピーしてください。
また、使用するスクリプトの文頭に #include "alib_hash.as" と記述してください。

//--------------------------------------------------------------------------------------------------
// 使い方( ハッシュ配列名が hash で、文字列型の場合 )
//--------------------------------------------------------------------------------------------------

#include "alib_hash.as"

// 初期化(※この二行は必ず必要です)
#define ctype hash(%1) HashElem( hash, %1 )
HashInitStr hash

// 代入・参照
hash("key") = "value"
mes hash("key")

// 型変換付値代入命令(マクロ)
HashSetValue hash, "π", 3.14159265358979
mes hash("π")

// 反復子を使ったキー・値取得関数(マクロ)
HashResetIter hash
while HashGetEach( hash, key, value ) != -1
  mes key + " = " + value
wend

// 配列を直接使ったキー・値取得
foreach hash_keys
  if hash_keys(cnt) == "" : continue
  mes hash_keys(cnt) + " = " + hash_values(cnt)
loop

// キー削除命令(マクロ)
HashDelKey hash, "key"

// キーチェック関数(マクロ)
if HashCheckKey( hash, "key" ) : mes hash("key")

// 値の型変換ショートカットマクロ(参照のみ可)
#define ctype hash_s(%1) str( hash(%1) )
#define ctype hash_i(%1) int( hash(%1) )
#define ctype hash_d(%1) double( hash(%1) )
mes hash_s("π")
mes hash_i("π")
mes hash_d("π")

// ハッシュ配列の命令・関数側での受け方
#module
#deffunc somefunc array hash_info, array hash_keys, array hash_values
HashResetIterF hash_info
while HashGetEachF( hash_info, hash_keys, hash_values, key, value ) != -1
  mes "somefunc: " + key + " = " + value
wend
return
#global
somefunc HashP(hash)

// ハッシュ配列引数用マクロのショートカット
#define hash_p HashP(hash)
somefunc hash_p

// ファイル入出力命令(マクロ)
HashToFile   hash, "hash.txt", "="
HashFromFile hash, "hash.txt", "="

//--------------------------------------------------------------------------------------------------
// 使用上の注意
//--------------------------------------------------------------------------------------------------

・使用するハッシュ配列の数だけ、初期化文が必要です。
  #define ctype hash1(%1) HashElem( hash1, %1 )
  HashInitStr hash1
  #define ctype hash2(%1) HashElem( hash2, %1 )
  HashInitDouble hash2

・ハッシュ配列の実体は通常の配列なので、異なった型の値の混在はできません。
  それぞれ対応した初期化命令で初期化してください。
  ( HashInitStr / HashInitInt / HashInitDouble )

・一つのハッシュ配列に対して、三つの通常の配列を自動的に使いますので、
  他の変数名とかぶらないように気をつけてください。
  ( *_info / *_keys / *_values : ハッシュ配列情報用 / キー保持用 / 値保持用
    ハッシュ配列名が hash の場合、hash_info / hash_keys / hash_values )

・キーに空文字列 "" は使用できません。キーに空文字列 "" を指定した場合は、"NULL" として扱われます。

・ハッシュ配列名は実際はマクロなので、そのまま命令や関数の引数として渡せません。
  命令・関数側では三つの配列を直接受けて、呼び出し側では三つの配列を直接指定するか、
  ハッシュ配列引数用マクロで渡す必要があります。
  ( somefunc HashP(hash) 等 )

・キー削除命令はかなり重いので、キーの削除を多用する場合は注意してください。
  同様にハッシュ配列の拡張も重いので、なるべく初期化時に使用するキーの数以上を確保しておくと良いです。

//--------------------------------------------------------------------------------------------------
// バージョン履歴
//--------------------------------------------------------------------------------------------------
Version 0.04, September 25, 2008 : HashDelKey の hash_info(HASH_INFO_NUM_KEYS) バグ修正
                                   ハッシュ配列再初期化命令追加( HashClear, HashClearF )
                                   入出力命令追加( Hash*File*, Hash*Note* )
Version 0.03,      June 15, 2008 : キー削除命令修正( HashDelKey, HashDelKeyF ) / インターフェイスは変更なし
Version 0.02,      June  3, 2008 : 公開

*/

//==================================================================================================
#ifndef ALIB_HASH_AS
#define ALIB_HASH_AS

//==================================================================================================
// ■ ハッシュ関数
//
// □ HashFunc( hash_key, hash_max )
//
//    hash_key: ハッシュキー文字列
//    hash_max: ハッシュ数
//
//    返り値  : ハッシュ値( 0 ～ hash_max-1 )
//
//==================================================================================================
#module
#defcfunc HashFunc str hash_key, int hash_max
  if hash_max < 1 : return 0
  s = hash_key : n = strlen(s) : hash_value = 0
  repeat n : hash_value = hash_value * 137 + peek(s,cnt) : loop
  return abs( hash_value \ hash_max )
#global

//==================================================================================================
// ■ ハッシュ用定数
//==================================================================================================
#enum global HASH_INFO_DIM_MAX = 0
#enum global HASH_INFO_DIM_EXT
#enum global HASH_INFO_KEY_MAX
#enum global HASH_INFO_VALUE_MAX
#enum global HASH_INFO_NUM_KEYS
#enum global HASH_INFO_ITER
#enum global HASH_INFO_MAX

#define global HASH_DEFAULT_DIM_MAX  257
#define global HASH_DEFAULT_DIM_EXT   64
#define global HASH_DEFAULT_KEY_MAX   16
#define global HASH_DEFAULT_VALUE_MAX 16

//==================================================================================================
// ■ ハッシュinfo配列ショートカットマクロ
//
// □ HashDimMax( hash_name )
// □ HashDimExt( hash_name )
// □ HashKeyMax( hash_name )
// □ HashValueMax( hash_name )
// □ HashNumKeys( hash_name )
// □ HashIter( hash_name )
//
//    hash_name: ハッシュ配列名
//
//==================================================================================================
#define global ctype HashDimMax(%1) %1_info(HASH_INFO_DIM_MAX)
#define global ctype HashDimExt(%1) %1_info(HASH_INFO_DIM_EXT)
#define global ctype HashKeyMax(%1) %1_info(HASH_INFO_KEY_MAX)
#define global ctype HashValueMax(%1) %1_info(HASH_INFO_VALUE_MAX)
#define global ctype HashNumKeys(%1) %1_info(HASH_INFO_NUM_KEYS)
#define global ctype HashIter(%1) %1_info(HASH_INFO_ITER)

//==================================================================================================
// ■ ハッシュ配列引数用マクロ
//==================================================================================================
#define global ctype HashP(%1) %1_info, %1_keys, %1_values

//==================================================================================================
// ■ ハッシュ配列初期化命令(マクロ)
//
// □ HashInitStr    hash_name, dim_max, dim_ext, key_max, value_max
// □ HashInitInt    hash_name, dim_max, dim_ext, key_max
// □ HashInitDouble hash_name, dim_max, dim_ext, key_max
//
//    hash_name: ハッシュ配列名
//    dim_max  : ハッシュ配列サイズ( 1以上, デフォルト値 = 257 )
//    dim_ext  : ハッシュ配列拡張数( 1以上, デフォルト値 =  64 )
//    key_max  : キー文字列サイズ  ( 1以上, デフォルト値 =  16 )
//    value_max: 値文字列サイズ    ( 1以上, デフォルト値 =  16 )
//
//--------------------------------------------------------------------------------------------------
// ■ ハッシュ配列初期化命令
//
// □ HashInitS hash_info, hash_keys, hash_values, dim_max, dim_ext, key_max, value_max
// □ HashInitI hash_info, hash_keys, hash_values, dim_max, dim_ext, key_max
// □ HashInitD hash_info, hash_keys, hash_values, dim_max, dim_ext, key_max
//
//==================================================================================================
#module
#deffunc HashInitS array hash_info, array hash_keys, array hash_values, int dim_max, int dim_ext, int key_max, int value_max
  dim hash_info, HASH_INFO_MAX
  hash_info(HASH_INFO_DIM_MAX)   = dim_max   : if dim_max   < 1 : hash_info(HASH_INFO_DIM_MAX)   = 1
  hash_info(HASH_INFO_DIM_EXT)   = dim_ext   : if dim_ext   < 1 : hash_info(HASH_INFO_DIM_EXT)   = 1
  hash_info(HASH_INFO_KEY_MAX)   = key_max   : if key_max   < 1 : hash_info(HASH_INFO_KEY_MAX)   = 1
  hash_info(HASH_INFO_VALUE_MAX) = value_max : if value_max < 1 : hash_info(HASH_INFO_VALUE_MAX) = 1
  hash_info(HASH_INFO_NUM_KEYS)  = 0

  sdim hash_keys  , hash_info(HASH_INFO_KEY_MAX)  , hash_info(HASH_INFO_DIM_MAX)
  sdim hash_values, hash_info(HASH_INFO_VALUE_MAX), hash_info(HASH_INFO_DIM_MAX)
  return
#global

//--------------------------------------------------------------------------------------------------
#module
#deffunc HashInitI array hash_info, array hash_keys, array hash_values, int dim_max, int dim_ext, int key_max
  dim hash_info, HASH_INFO_MAX
  hash_info(HASH_INFO_DIM_MAX)  = dim_max : if dim_max < 1 : hash_info(HASH_INFO_DIM_MAX) = 1
  hash_info(HASH_INFO_DIM_EXT)  = dim_ext : if dim_ext < 1 : hash_info(HASH_INFO_DIM_EXT) = 1
  hash_info(HASH_INFO_KEY_MAX)  = key_max : if key_max < 1 : hash_info(HASH_INFO_KEY_MAX) = 1
  hash_info(HASH_INFO_NUM_KEYS) = 0

  sdim hash_keys  , hash_info(HASH_INFO_KEY_MAX), hash_info(HASH_INFO_DIM_MAX)
   dim hash_values,                               hash_info(HASH_INFO_DIM_MAX)
  return
#global

//--------------------------------------------------------------------------------------------------
#module
#deffunc HashInitD array hash_info, array hash_keys, array hash_values, int dim_max, int dim_ext, int key_max
  dim hash_info, HASH_INFO_MAX
  hash_info(HASH_INFO_DIM_MAX)  = dim_max : if dim_max < 1 : hash_info(HASH_INFO_DIM_MAX) = 1
  hash_info(HASH_INFO_DIM_EXT)  = dim_ext : if dim_ext < 1 : hash_info(HASH_INFO_DIM_EXT) = 1
  hash_info(HASH_INFO_KEY_MAX)  = key_max : if key_max < 1 : hash_info(HASH_INFO_KEY_MAX) = 1
  hash_info(HASH_INFO_NUM_KEYS) = 0

  sdim hash_keys  , hash_info(HASH_INFO_KEY_MAX), hash_info(HASH_INFO_DIM_MAX)
  ddim hash_values,                               hash_info(HASH_INFO_DIM_MAX)
  return
#global

//--------------------------------------------------------------------------------------------------
#define global HashInitStr(%1,%2=HASH_DEFAULT_DIM_MAX,%3=HASH_DEFAULT_DIM_EXT,%4=HASH_DEFAULT_KEY_MAX,%5=HASH_DEFAULT_VALUE_MAX) HashInitS %1_info, %1_keys, %1_values, %2,%3,%4,%5
#define global HashInitInt(%1,%2=HASH_DEFAULT_DIM_MAX,%3=HASH_DEFAULT_DIM_EXT,%4=HASH_DEFAULT_KEY_MAX) HashInitI %1_info, %1_keys, %1_values, %2,%3,%4
#define global HashInitDouble(%1,%2=HASH_DEFAULT_DIM_MAX,%3=HASH_DEFAULT_DIM_EXT,%4=HASH_DEFAULT_KEY_MAX) HashInitD %1_info, %1_keys, %1_values, %2,%3,%4

//==================================================================================================
// ■ ハッシュ配列再初期化命令(マクロ)
//
// □ HashClear hash_name
//
//    hash_name: ハッシュ配列名
//
//--------------------------------------------------------------------------------------------------
// ■ ハッシュ配列再初期化命令
//
// □ HashClearF hash_info, hash_keys, hash_values
//
//==================================================================================================
#module
#deffunc HashClearF array hash_info, array hash_keys, array hash_values
  dim_max   = hash_info(HASH_INFO_DIM_MAX)
  dim_ext   = hash_info(HASH_INFO_DIM_EXT)
  key_max   = hash_info(HASH_INFO_KEY_MAX)
  value_max = hash_info(HASH_INFO_VALUE_MAX)
  switch vartype( hash_values )
  case 2: HashInitS hash_info, hash_keys, hash_values, dim_max, dim_ext, key_max, value_max : swbreak // 文字列型
  case 3: HashInitD hash_info, hash_keys, hash_values, dim_max, dim_ext, key_max            : swbreak // 実数型
  case 4: HashInitI hash_info, hash_keys, hash_values, dim_max, dim_ext, key_max            : swbreak // 整数型
  swend
  return
#global

//--------------------------------------------------------------------------------------------------
#define global HashClear(%1) HashClearF %1_info, %1_keys, %1_values

//==================================================================================================
// ■ キー追加関数(マクロ)
//
// □ HashAddKey( hash_name, key )
//
//    hash_name: ハッシュ配列名
//    key      : 追加するキー文字列( 空文字列 "" を指定した場合は、"NULL" として扱われます )
//
//    返り値   : キーに対応する配列のインデックス( キーが追加できない場合は -1 )
//
//--------------------------------------------------------------------------------------------------
// ■ キー追加関数
//
// □ HashAddKeyF( hash_info, hash_keys, key )
//
//==================================================================================================
#module
#defcfunc HashAddKeyF array hash_info, array hash_keys, str key
  hash_key = key : if hash_key == "" : hash_key = "NULL"
  hash_max = hash_info(HASH_INFO_DIM_MAX)

  h = HashFunc( hash_key, hash_max ) : full = 1
  repeat hash_max
    if hash_keys(h) == ""       { hash_keys(h) = hash_key : hash_info(HASH_INFO_NUM_KEYS)++ : full = 0 : break }
    if hash_keys(h) == hash_key {                                                             full = 0 : break }
    h = (h+1) \ hash_max
  loop
  if full { return -1 }else{ return h }
#global

//--------------------------------------------------------------------------------------------------
#define global ctype HashAddKey(%1,%2) HashAddKeyF( %1_info, %1_keys, %2 )

//==================================================================================================
// ■ ハッシュ配列拡張命令(マクロ)
//
// □ HashExt hash_name
//
//    hash_name: ハッシュ配列名
//
//--------------------------------------------------------------------------------------------------
// ■ ハッシュ配列拡張命令
//
// □ HashExtF hash_info, hash_keys, hash_values
//
//==================================================================================================
#module
#deffunc HashExtF array hash_info, array hash_keys, array hash_values
  var_type  = vartype( hash_values )
  dim_max   = hash_info(HASH_INFO_DIM_MAX)
  dim_ext   = hash_info(HASH_INFO_DIM_EXT)
  key_max   = hash_info(HASH_INFO_KEY_MAX)
  value_max = hash_info(HASH_INFO_VALUE_MAX)

  sdim tmp_keys, key_max, dim_max
  switch var_type
  case 2: sdim tmp_values, value_max, dim_max : swbreak // 文字列型
  case 3: ddim tmp_values,            dim_max : swbreak // 実数型
  case 4:  dim tmp_values,            dim_max : swbreak // 整数型
  swend
  repeat dim_max : tmp_keys(cnt) = hash_keys(cnt) : tmp_values(cnt) = hash_values(cnt) : loop

  switch var_type
  case 2: HashInitS hash_info, hash_keys, hash_values, dim_max + dim_ext, dim_ext, key_max, value_max : swbreak // 文字列型
  case 3: HashInitD hash_info, hash_keys, hash_values, dim_max + dim_ext, dim_ext, key_max            : swbreak // 実数型
  case 4: HashInitI hash_info, hash_keys, hash_values, dim_max + dim_ext, dim_ext, key_max            : swbreak // 整数型
  swend
  repeat dim_max : if tmp_keys(cnt) != "" { hash_values( HashAddKeyF( hash_info, hash_keys, tmp_keys(cnt) ) ) = tmp_values(cnt) } : loop
  tmp_keys = 0 : tmp_values = 0 : return
#global

//--------------------------------------------------------------------------------------------------
#define global HashExt(%1) HashExtF %1_info, %1_keys, %1_values

//==================================================================================================
// ■ ハッシュ配列登録用関数(マクロ)
//
//    ハッシュ配列名が __hash__ の場合、以下のように登録します。
//
//    #define ctype __hash__(%1) HashElem( __hash__, %1 )
//
// □ HashElem( hash_name, key )
//
//    hash_name: ハッシュ配列名
//    key      : キー文字列
//
//--------------------------------------------------------------------------------------------------
// ■ ハッシュ配列インデックス関数
//
//    キーに対応するインデックスを返します。
//    配列が満杯でキーが追加できない場合は、自動で配列が拡張されます。
//
// □ HashIndexF( hash_info, hash_keys, hash_values, key )
//
//    key   : 追加するキー文字列
//
//    返り値: キーに対応する配列のインデックス
//
//==================================================================================================
#module
#defcfunc HashIndexF array hash_info, array hash_keys, array hash_values, str key
  h = HashAddKeyF( hash_info, hash_keys, key )
  if h == -1 { HashExtF hash_info, hash_keys, hash_values : return HashAddKeyF( hash_info, hash_keys, key ) }else{ return h }
#global

//--------------------------------------------------------------------------------------------------
#define global ctype HashElem(%1,%2) %1_values( HashIndexF( %1_info, %1_keys, %1_values, %2 ) )

//==================================================================================================
// ■ キー削除命令(マクロ)
//
// □ HashDelKey hash_name, key
//
//    hash_name: ハッシュ配列名
//    key      : 削除するキー文字列
//
//--------------------------------------------------------------------------------------------------
// ■ キー削除命令
//
// □ HashDelKeyF hash_info, hash_keys, hash_values, key
//
//==================================================================================================
#module
#deffunc HashDelKeyF array hash_info, array hash_keys, array hash_values, str key
  h = HashAddKeyF( hash_info, hash_keys, key ) : if h == -1 : return
  hash_keys(h) = "" : hash_info(HASH_INFO_NUM_KEYS) = 0

  dim_max   = hash_info(HASH_INFO_DIM_MAX)
  key_max   = hash_info(HASH_INFO_KEY_MAX)
  value_max = hash_info(HASH_INFO_VALUE_MAX)

  sdim tmp_keys, key_max, dim_max
  switch vartype( hash_values )
  case 2: sdim tmp_values, value_max, dim_max : v = "" : swbreak // 文字列型
  case 3: ddim tmp_values,            dim_max : v = 0f : swbreak // 実数型
  case 4:  dim tmp_values,            dim_max : v = 0  : swbreak // 整数型
  swend

  repeat dim_max
    tmp_keys(cnt)   = hash_keys(cnt)   : hash_keys(cnt)   = ""
    tmp_values(cnt) = hash_values(cnt) : hash_values(cnt) = v
  loop
  repeat dim_max : if tmp_keys(cnt) != "" { hash_values( HashAddKeyF( hash_info, hash_keys, tmp_keys(cnt) ) ) = tmp_values(cnt) } : loop
  tmp_keys = 0 : tmp_values = 0 : return
#global

//--------------------------------------------------------------------------------------------------
#define global HashDelKey(%1,%2) HashDelKeyF %1_info, %1_keys, %1_values, %2

//==================================================================================================
// ■ 反復子リセット命令(マクロ)
//
// □ HashResetIter hash_name
//
//    hash_name: ハッシュ配列名
//
//--------------------------------------------------------------------------------------------------
// ■ 反復子リセット命令
//
// □ HashResetIterF hash_info
//
//==================================================================================================
#module
#deffunc HashResetIterF array hash_info
  hash_info(HASH_INFO_ITER) = -1 : return
#global

//--------------------------------------------------------------------------------------------------
#define global HashResetIter(%1) HashResetIterF %1_info

//==================================================================================================
// ■ 反復子を使ったキー・値取得関数(マクロ)
//
// □ HashGetEach( hash_name, key, value )
// □ HashGetKey( hash_name, key )
// □ HashGetValue( hash_name, value )
//
//    hash_name: ハッシュ配列名
//    key      : キーが代入される変数
//    value    : 値が代入される変数
//
//    返り値   : 現在の反復子のインデックス( 取得するキー・値がなくなった場合 -1 )
//
//--------------------------------------------------------------------------------------------------
// ■ 反復子を使ったキー・値取得関数
//
// □ HashGetEachF( hash_info, hash_keys, hash_values, key, value )
// □ HashGetKeyF( hash_info, hash_keys, key )
// □ HashGetValueF( hash_info, hash_keys, hash_values, value )
//
//==================================================================================================
#module
#defcfunc HashGetEachF array hash_info, array hash_keys, array hash_values, var key, var value
*@
  hash_info(HASH_INFO_ITER)++ : if hash_info(HASH_INFO_DIM_MAX)-1 < hash_info(HASH_INFO_ITER) : return -1
  h = hash_info(HASH_INFO_ITER) : if hash_keys(h) != "" { key = hash_keys(h) : value = hash_values(h) : return h }
goto *@b
#global

//--------------------------------------------------------------------------------------------------
#module
#defcfunc HashGetKeyF array hash_info, array hash_keys, var key
*@
  hash_info(HASH_INFO_ITER)++ : if hash_info(HASH_INFO_DIM_MAX)-1 < hash_info(HASH_INFO_ITER) : return -1
  h = hash_info(HASH_INFO_ITER) : if hash_keys(h) != "" { key = hash_keys(h) : return h }
goto *@b
#global

//--------------------------------------------------------------------------------------------------
#module
#defcfunc HashGetValueF array hash_info, array hash_keys, array hash_values, var value
*@
  hash_info(HASH_INFO_ITER)++ : if hash_info(HASH_INFO_DIM_MAX)-1 < hash_info(HASH_INFO_ITER) : return -1
  h = hash_info(HASH_INFO_ITER) : if hash_keys(h) != "" { value = hash_values(h) : return h }
goto *@b
#global

//--------------------------------------------------------------------------------------------------
#define global ctype HashGetEach(%1,%2,%3) HashGetEachF( %1_info, %1_keys, %1_values, %2, %3 )
#define global ctype HashGetKey(%1,%2) HashGetKeyF( %1_info, %1_keys, %2 )
#define global ctype HashGetValue(%1,%2) HashGetValueF( %1_info, %1_keys, %1_values, %2 )

//==================================================================================================
// ■ キーチェック関数(マクロ)
//
//    key が既に登録されていれば 1 、登録されていなければ 0 を返します。
//    key に 空文字列 "" を指定した場合、配列に空きがあれば 1 を返します。
//
// □ HashCheckKey( hash_name, key )
//
//    hash_name: ハッシュ配列名
//    key      : チェックするキー文字列
//
//    返り値   : 1 = key は登録されている / 0 = key は登録されていない
//
//--------------------------------------------------------------------------------------------------
// ■ キーチェック関数
//
// □ HashCheckKeyF( hash_info, hash_keys, key )
//
//==================================================================================================
#module
#defcfunc HashCheckKeyF array hash_info, array hash_keys, str key
  hash_key = key
  hash_max = hash_info(HASH_INFO_DIM_MAX)
  if hash_key == "" { h = 0 }else{ h = HashFunc( hash_key, hash_max ) }

  v = 0 : repeat hash_max
    if hash_keys(h) == hash_key { v = 1 : break }
    h = (h+1) \ hash_max
  loop : return v
#global

//--------------------------------------------------------------------------------------------------
#define global ctype HashCheckKey(%1,%2) HashCheckKeyF( %1_info, %1_keys, %2 )

//==================================================================================================
// ■ 型変換付値代入命令(マクロ)
//    ※このマクロは内部でマルチステートメントになっているので、if文等で使う場合は注意してください。
//
// □ HashSetValue hash_name, key, value
//
//    hash_name: ハッシュ配列名
//    key      : キー文字列
//    value    : 値
//
//--------------------------------------------------------------------------------------------------
// ■ 型変換付値代入命令
//
// □ HashSetValueF hash_info, hash_keys, hash_values, key, value
//
//    key      : キー文字列
//    value    : 値( 変数のみ可 )
//
//==================================================================================================
#module
#deffunc HashSetValueF array hash_info, array hash_keys, array hash_values, str key, var value
  switch vartype( hash_values )
  case 2: hash_values( HashIndexF( hash_info, hash_keys, hash_values, key ) ) = str(    value ) : swbreak // 文字列型
  case 3: hash_values( HashIndexF( hash_info, hash_keys, hash_values, key ) ) = double( value ) : swbreak // 実数型
  case 4: hash_values( HashIndexF( hash_info, hash_keys, hash_values, key ) ) = int(    value ) : swbreak // 整数型
  swend
  return
#global

//--------------------------------------------------------------------------------------------------
#define global HashSetValue(%1,%2,%3) HashSetValue_tmp = %3 : HashSetValueF %1_info, %1_keys, %1_values, %2, HashSetValue_tmp

//==================================================================================================
// ■ ファイル入出力命令(マクロ)
//    ※空白類は、そのままkeyとvalueに反映されるので注意してください。
//    ※改行を含むkeyとvalueを扱うことはできません。
//
// □ HashFromFile hash_name, filename, d (ファイルからkeyとvalueを読み込みます)
// □ HashAddFile  hash_name, filename, d (ファイルからkeyとvalueを読み込み追加します)
// □ HashToFile   hash_name, filename, d (ファイルへkeyとvalueを書き込みます)
//
//    hash_name: ハッシュ配列名
//    filename : ファイル名
//    d        : デリミタ( 省略可, デフォルト値 = ":" )
//
//--------------------------------------------------------------------------------------------------
// ■ ファイル入出力命令
//
// □ HashFromFileF hash_info, hash_keys, hash_values, filename, d
// □ HashAddFileF  hash_info, hash_keys, hash_values, filename, d
// □ HashToFileF   hash_info, hash_keys, hash_values, filename, d
//
//==================================================================================================
// ■ ノートパッド入出力命令(マクロ)
//    ※空白類は、そのままkeyとvalueに反映されるので注意してください。
//    ※改行を含むkeyとvalueを扱うことはできません。
//
// □ HashFromNote hash_name, note, d (ノートパッドからkeyとvalueを読み込みます)
// □ HashAddNote  hash_name, note, d (ノートパッドからkeyとvalueを読み込み追加します)
// □ HashToNote   hash_name, note, d (ノートパッドへkeyとvalueを書き込みます)
//
//    hash_name: ハッシュ配列名
//    note     : ノートパッド変数
//    d        : デリミタ( 省略可, デフォルト値 = ":" )
//
//--------------------------------------------------------------------------------------------------
// ■ ノートパッド入出力命令
//
// □ HashFromNoteF hash_info, hash_keys, hash_values, note, d
// □ HashAddNoteF  hash_info, hash_keys, hash_values, note, d
// □ HashToNoteF   hash_info, hash_keys, hash_values, note, d
//
//==================================================================================================
#module
#deffunc HashToNoteF array hash_info, array hash_keys, array hash_values, var note, str d
  if d == "" : return
  note = "" : notesel note
  foreach hash_keys
    if hash_keys(cnt) == "" : continue
    noteadd hash_keys(cnt) + d + hash_values(cnt)
  loop
  return
#global

//--------------------------------------------------------------------------------------------------
#module
#deffunc HashAddNoteF array hash_info, array hash_keys, array hash_values, var note, str d
  if d == "" : return
  notesel note : n = notemax
  repeat n
    notesel note : noteget s,cnt : i = instr(s,0,d) : if i < 1 : continue
    key   = strmid( s, 0, i )
    value = strmid( s, i+strlen(d), strlen(s) )
    HashSetValueF hash_info, hash_keys, hash_values, key, value
  loop
  return
#global

//--------------------------------------------------------------------------------------------------
#module
#deffunc HashFromNoteF array hash_info, array hash_keys, array hash_values, var note, str d
  if d == "" : return
  HashClearF   hash_info, hash_keys, hash_values
  HashAddNoteF hash_info, hash_keys, hash_values, note, d
  return
#global

//--------------------------------------------------------------------------------------------------
#module
#deffunc HashToFileF array hash_info, array hash_keys, array hash_values, str filename, str d
  if d == "" : return
  note = "" : HashToNoteF hash_info, hash_keys, hash_values, note, d
  notesel note : notesave filename
  return
#global

//--------------------------------------------------------------------------------------------------
#module
#deffunc HashAddFileF array hash_info, array hash_keys, array hash_values, str filename, str d
  if d == "" : return
  note = "" : notesel note : noteload filename
  HashAddNoteF hash_info, hash_keys, hash_values, note, d
  return
#global

//--------------------------------------------------------------------------------------------------
#module
#deffunc HashFromFileF array hash_info, array hash_keys, array hash_values, str filename, str d
  if d == "" : return
  note = "" : notesel note : noteload filename
  HashFromNoteF hash_info, hash_keys, hash_values, note, d
  return
#global

//--------------------------------------------------------------------------------------------------
#define global HashToNote(%1,%2,%3=":") HashToNoteF %1_info, %1_keys, %1_values, %2, %3
#define global HashAddNote(%1,%2,%3=":") HashAddNoteF %1_info, %1_keys, %1_values, %2, %3
#define global HashFromNote(%1,%2,%3=":") HashFromNoteF %1_info, %1_keys, %1_values, %2, %3

#define global HashToFile(%1,%2,%3=":") HashToFileF %1_info, %1_keys, %1_values, %2, %3
#define global HashAddFile(%1,%2,%3=":") HashAddFileF %1_info, %1_keys, %1_values, %2, %3
#define global HashFromFile(%1,%2,%3=":") HashFromFileF %1_info, %1_keys, %1_values, %2, %3

#endif /* ALIB_HASH_AS */
//==================================================================================================
//==================================================================================================
//==================================================================================================
