# K-Shoot MANIA v1.xx
- ソースコード公開にあたって、下記機能に該当する箇所のコードは削除されています
    - INPUT GATE
    - Twitter連携機能
    - インターネットランキング

- 非常に汚いコードです
    - 基本的にモジュール(`#module`～`#global`)が使用されていないため、変数がすべてグローバルです
    - 共通の処理を含む部分をコピペ改変で実装してしまっている箇所が多いです
    - 変数名が無意味に省略されていたり、意味のない名前が使用されています
        - `stat1`, `stat2`, ... は仮の変数を意味しています
    - 座標などの数値がマジックナンバーとしてハードコードされていて、その一部は計算済みの値のみが書かれています
    - ただし、HSPではコンパイル時に一切最適化が行われないので、マジックナンバーの変数化・関数分けを行うと実行速度が低下する可能性があります

- 主となるファイルは以下の通りです
    - `kshootmania.hsp`: ゲーム本体
    - `src/scene/select.hsp`: ゲーム本体(選曲画面)
    - `src/scene/play.hsp`: ゲーム本体(プレイ画面)
    - `src/scene/result.hsp`: ゲーム本体(結果表示画面)
    - `kshooteditor.hsp`: 譜面エディタ

- リポジトリ内のファイルはMITライセンスで提供されています
    - ただし、ランキング機能等を含む公式サイトで配布されているバイナリはその利用規約に準拠します

-------

- To make source codes public, these features are deleted:
    - Input Gate (In-game chart downloader)
    - Link with Twitter
    - Internet ranking system

- The entire code is very badly written
    - All variables are global due to no use of modules (`#module`～`#global`)
    - Heavy use of copy & paste
    - Variable names are meaninglessly abbreviated
        - `stat1`, `stat2`, ... are temporal variables
    - The code has lots of magic numbers like coordinates, and some of them are pre-calculated for a better performance
    - However, since no code optimization is operated in HSP, refactoring can lead to a bad performance.

- Unfortunately, comments are written in Japanese. Good luck with Google Translate!

- Main program:
    - `kshootmania.hsp`: Game
    - `src/scene/select.hsp`: Game (song selection)
    - `src/scene/play.hsp`: Game (play screen)
    - `src/scene/result.hsp`: Game (result screen)
    - `kshooteditor.hsp`: Chart editor

- The files in this repository are available under the MIT license.
    - However, to use the binary (w/ online features) from the official website, you must follow the "Terms of Use".
