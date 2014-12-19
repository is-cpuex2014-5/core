##How To Run 
###ISE 上での動作手順

1. source に入ってる全てのファイルを ISE に入れる。
2. IMPACT を呼び出し minicom を立ち上げる。
3. cat (ファイル名) > /dev/ttyUSB0 で OK

* 入力の format
  * (命令列を16進数で列挙)X(入力列を16進数で列挙)X
  * という形式(2 つめの"X"で実行開始)
  * 空白とか改行は挟まない。

* 例(rg1 に read して write するコード)
```
E0200000E2200000X59X
```
現状、命令や入力を読み込む際に自動的に末尾の 4 bit を出力
する仕様ですが、u232c_go <= '1' (手前の方) をコメントアウトすることで
消すことができます。


##サンプルプログラム
fib_runset.txt : fib の実行  
ffib_runset.txt : float_fib の実行  
m128_runset.txt : 128*128 のマンデルブロ  
rt_contest_runset.txt : min-rt に contestb.sld を入力として与えたもの  

## その他サンプル
iotest.txt : これはプログラムではなく、入力のビット落ち検出テスト用  
ln.txt : 同じく、こちらはでかい  
load_runset.txt : load 命令とかのお試し  
read_runset.txt : read 命令のお試し  
long_runset.txt : 長い命令のお試し  
