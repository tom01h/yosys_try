# オープンソース論理合成ツール Yosys による論理合成の試行

## 準備

[Yosys のダウンロードサイト](http://www.clifford.at/yosys/download.html) から Windows 版のバイナリリリースをダウンロードしてきて解凍。  
[セルライブラリ osu018_stdcells.lib](https://vlsiarch.ecen.okstate.edu/flows/MOSIS_SCMOS/osu_soc_v2.5/cadence/lib/tsmc018/signalstorm/) (UMCの180nm?)をダウンロード。  
[制約ファイル](https://github.com/cliffordwolf/yosys/blob/master/examples/osu035/example.constr) を Yosys の Github の例題からダウンロード。

セルライブラリと制約ファイルと合成対象の Verilog と、下記の合成スクリプトを同じディレクトリに置く。

### 合成スクリプトの例

```
read_verilog mul.v
read_liberty -lib osu018_stdcells.lib
proc
flatten
synth -top mul
write_verilog synth.v
dfflibmap -liberty osu018_stdcells.lib
abc -D 5000 -constr example.constr -liberty osu018_stdcells.lib
stat -liberty osu018_stdcells.lib
write_verilog gate.v
```

## 合成実行
```
${YOSYS_PATH}/yosys.exe hoge.ys
```


## 合成結果
|       |   add |    mul |  mul_1 |  mul_3 | fmul_2 | vscale_mul_div | estimate |
| :-    |    :- |     :- |     :- |     :- |     :- |             :- |       :- |
| Area  | 38930 | 248386 | 276981 | 150422 | 165649 |         330361 |    27916 |
| Delay |  6615 |   7132 |   9526 |   5872 |  11997 |           9018 |     4213 |

## 合成詳細
### add.v
64bit入力・64bit出力の ``` x + y``` を合成 (目標 5ns)

```
ABC: WireLoad = "none"  Gates =    807 ( 24.4 %)   Cap = 24.1 ff (  0.0 %)   Area =    20498.00 (100.0 %)   Delay =  6615.90 ps  (  9.5 %)
   Chip area for this module: 38930.000000
```

### mul.v
32bit入力・64bit出力の ``` x * y``` を合成 (目標 5ns)

```
ABC: WireLoad = "none"  Gates =   8204 ( 14.9 %)   Cap = 34.8 ff (  0.2 %)   Area =   236098.00 ( 99.1 %)   Delay =  7132.83 ps  (  1.0 %)
   Chip area for this module: 248386.000000
```

### mul_1.v
32bit入力・64bit出力の Booth アルゴリズムを使った符号無し・付き両対応の乗算器を合成 (目標 5ns)  
符号拡張を減らすアルゴリズム(名前は知らない)を適用  
ただし、部分積の圧縮は加算を並べただけ

```
ABC: WireLoad = "none"  Gates =   9100 ( 14.0 %)   Cap = 38.4 ff (  0.3 %)   Area =   270645.00 ( 98.9 %)   Delay =  9526.57 ps  (  1.8 %)
   Chip area for this module: 276981.000000
```

### mul_3.v
5サイクル乗算器を合成 (目標 5ns)  
V-scale で使っている演算器から整数乗算機能だけを抽出

```
ABC: WireLoad = "none"  Gates =   4894 ( 18.4 %)   Cap = 34.1 ff (  0.9 %)   Area =   131414.00 ( 96.7 %)   Delay =  5872.54 ps  (  5.1 %)
   Chip area for this module: 150422.000000
```

### fmul_2.v
5サイクルFPU乗算器を合成 (目標 5ns)  
V-scale で使っている演算器からFPU乗算機能だけを抽出  
ディレイ対策前のバージョン

```
ABC: WireLoad = "none"  Gates =   5525 ( 13.2 %)   Cap = 37.5 ff (  0.7 %)   Area =   165649.00 ( 97.5 %)   Delay = 11997.38 ps  (  7.1 %)
   Chip area for this module: 165649.000000
```

### vscale_mul_div.v
V-scale で使っている演算器を合成 (目標 5ns)  
作りかけですが…  
整数乗算(5サイクル)・整数除算(17サイクル)・FPU加算(2サイクル)・FPU乗算(5サイクル)・FPU積和(6サイクル)

```
ABC: WireLoad = "none"  Gates =  11220 ( 18.9 %)   Cap = 36.3 ff (  0.6 %)   Area =   294937.00 ( 97.7 %)   Delay =  9018.19 ps  (  3.0 %)
   Chip area for this module: 330361.000000
```

### estimate.sv
Binary Neural Net の推論アクセラレータコアを合成 (目標 5ns)  
以下の機能を持つ
1. 32bitのデータとパラメータを入力して XNOR 結果の"1"のbit数を数え ACC レジスタに累積
2. ACC レジスタと POOL レジスタを比較して大きい方を POOL レジスタに保存
3. POOL レジスタから入力値(平均)を引いて POOL レジスタに保存
4. POOL レジスタの符号を出力

ACC, POOL レジスタは 16bit

```
ABC: WireLoad = "none"  Gates =    772 ( 18.1 %)   Cap = 31.8 ff (  0.2 %)   Area =    21388.00 ( 99.2 %)   Delay =  4213.16 ps  (  8.0 %)
   Chip area for this module: 27916.000000
```
