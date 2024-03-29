# mikanos_local
## めも
### day02
#### day02a
- インテリセンスまわりを整備`c_cpp_properties.json`
#### day02b
- `Main.c`を書いていく
  - `root_dir`を`root->dir`を見間違えた
  - `initialize the variable 'loaded_image' to silence this warning`と言われたので`loaded_image = NULL`にした
- メモリマップが出力されない
  - `Print`を追加してデバッグしてみる
    - `GetMemoryMap`までたどり着いてない
      - `build`するのを忘れてた
    - `OpenRootDir`が走らない
      - Printデバッグの結果、`fs->OpenVolume`で止まる
      - オリジナルのmikanosでは普通に動く
      - `gBS->OpenProtocol`に渡す引数を間違えてた...
- memmapもいい感じ
### day03
#### day03a
- `Loader.inf`に追記が必要なので注意
- おぼえがき
  - `kernel_base_addr`：kernelをコンパイル（リンク）するときに指定したベースアドレス
- boot service終了時の`GetMemoryMap`で`Buffer Size Too Small`で止まる
  - `GetMemoryMap`に若干加筆されてるのに気づかず...
- うごいた!!
- レッドゾーンよくワカンネ（そのうち戻ってくる）
#### day03c
- おそらくコマンドの打ち間違いで模様が出力されなかった（コピペしたコマンドで動いた）？
  - `readelf -h kernel.elf`で中をみると、オリジナルとエントリポイントアドレスが違っていた
- たぶんこの節からUbuntuドックに`MIKAN OS`が出現した（気づかなかっただけ？）
  - どうやらloopにマウントされている。`run_qemu.sh`などを見ると、そこでマウントされていることがわかった
  - ループバック（マウント）というやつで、別に気にしなくてもよさそう
#### day03d
- `Halt`関数を実装
- [ここ](https://uefi.org/specs/UEFI/2.10/13_Protocols_Media_Access.html#simple-file-system-protocol)に定義が書いてある
  - ながめてみるといいかも
### day04
#### day04b
- `frame_buffer_config.hpp`のシンボリックリンクをはる
- 投機実行...授業でやった
#### day04d
- 難しい
- `phdr`: program header
  - メモリ読み込み関係の情報（セグメント？）が入っている
  - 配列として存在
- `shdr`: section header
- `ehdr`: elf file header
  - p111図4.5の一番上にあるし、versionとかも入ってるし、ここを起点にする？
  - ファイルヘッダは全体の情報があると書籍に書いてあった
- `PT_***`: program (header) type ?
- まとめたら意外とわかった
### day05
#### day05d
- `~/osbook/devenv/x86_64-elf/include`へのパスを通してインテリセンスを有効にする
  - `/x86_64-elf/include/**`の書き方だとうまくいかず、`/x86_64-elf/include/`だといけた。なぜ
- Makefileがよめないから調べる
- `newlib_support.c`のsbrkはメモリ配置系らしい
  - 重ね合わせで使う
#### day05e
- `newlib_support.c`に加筆がある。よくわからない。
### day06
#### day06b
- 難しかった。また戻ってきてやる。
- 4章で定義した配置new `void* operator new(size_t size, void* buf)`が消えてた。なぜ？
#### day06c
- 配置new `void operator delete(void* obj)`が消えてた
- class code
  - ベースクラス0x0cはシリアル通信、サブクラス0x03はUSB、インターフェイス0x30はUSB3.0をそれぞれ表す
  - これを`main.cpp`で探す（リスト6.18）
- usb dir
  - kernel/usbディレクトリをコピー
  - 中身を見てみたけど、ぜんぜんわからなかった
  - https://uchan.hateblo.jp/entry/2020/12/01/071904
- マウスが動かない
  - LogLevelをDebugにすると、`xhc.Run()`で止まっていることが分かった（そもそもこの関数から帰ってきなさそう）
  - `register.hpp`の`MemMapRegister.Write`内のfor文の終了条件を書き間違えて、無限ループで止まっていた
### day07
#### day07a
- `kernel/usb/xhci/xhci.cpp`に修正がある
- 割り込みの流れをまとめる
  - 事前準備
    - 割り込みハンドラ`IntHandlerXHCI`を準備
    - それを識別子テーブルに登録（`LoadIDT`, `lidt`命令)、`pci::ConfigureMSIFixedDestination`でMSI有効化
  - イベント発生時
    - CPUがイベント検知
    - 今の処理をとめ、割り込みハンドラに処理を移す
    - 終わり次第、レジスタの状態とかを戻しつつ、処理を再開(`NotifyEndOfInterrupt`)
      - `__attribute__`をつけると、イイ感じにコンパイラが前後処理を入れてくれる
- MSIのCapabilityとは？
  - PCI Configuration SpaceにCapability Pointerがある（0x34）
  - 上のポインタが指しているであろうMSI Capability Registerの定義は`pci::MSICapability`で、[これ](https://www.intel.com/content/www/us/en/docs/programmable/683686/20-4/msi-registers.html)
  - `pci::CapabilityHeader`はおそらく`pci::MSICapability`の上4byteで、制御用？
  - MSI有効化の処理でmessage addressとmessage dataを登録しておくと、割り込み時にうまいことやってくれてそう
#### day07b
- 割り込みハンドラ内にあった処理をメインループ(?)に移している
- 割り込みハンドラの仕事がqueueへのpushだけになったため、忙しくなくなる
- cli: clear interrupt flag, sli: set interrupt flag
### day8
#### day8b
- 用語集
  - GDT: Global Data Table
  - DS: Data Segment (?)
  - SS: Stack Segment (register)
  - CS: Code Segment (register)
- CSSSの動作がイマイチよくわからなかった
#### day08c
- 起動時
  - メモリマップをなめながら、使用済みのフレームを`MarkAllocated`で記録していく
  - `SetMemoryRange`で物理メモリを超えないように設定
- `alloc_map_`について
- テストについて
  - `/test/usb/xhci`を作らないとコンパイルが通らなかった
  - `error: no matching function for call to '__iterator_category'`で止まる
  - 原因はよくわかってない
### day09
#### day09a
- sbrkを実装して、`new`が使えるようになる
- `Window`クラスを実装
  - マウスも`main`での定義からwindowでの実装に変わる
  - window自体は動かず、layerにより制御される
- `Layer`クラスなどを実装
  - windowを制御する
  - moveが定義されている
  - 各レイヤは`LayerManager`で制御される
#### day09c
- `((bits_per_pixel + 7)/8)`は1ピクセルのバイト数
- 画面描画の処理順が、PixelWriter->フレームバッファだったのが、シャドウバッファ->フレームバッファに変わった
  - それに合わせて、PixelWriterでの画面処理を書き換える
- 画面描画の流れ
  - `LayerManager::Draw`->`Layer::DrawTo`->`Window::DrawTo`->`FrameBuffer::Copy`
#### day09e
- `KernelMainNewStack`の最初の方に出てくる`DrawDesktop`いらなくね？
### day10
#### day10a
- マウスカーソルを限界まで右や下にもってくと、画面の外にでることに初めて気がついた。
### day11
#### day11b
- `lvt_time = (0b010 << 16) | InterruptVector::kLAPICTimer;` なにこれ...??
#### day11e
- [`EFI_CONFIGURATION_TABLE`](https://dox.ipxe.org/structEFI__CONFIGURATION__TABLE.html)
- [`EFI_SYSTEM_TABLE`](https://dox.ipxe.org/structEFI__SYSTEM__TABLE.html)
### day12
#### day12b
- タイマの論理はよくわかってないが、まぁ動いてるからヨシ
#### day12c
- 無事にキー入力できた！すげー
- https://www.usb.org/sites/default/files/hut1_2.pdf
  - このページにGame Controllerがあったから、Gamepadのドライバとかもかけるのかな？
#### day12d
- [本の参考文献13](https://www.usb.org/sites/default/files/hut1_2.pdf)のキー配列なんか違くね...
  - ちゃんと調査したら参考文献のはUS配列だった。
### day13
- 実装するコード量は少ないけど、内容がむずい...
### day14
#### day14b
- メインウィンドウの数字がカーソルのタイマに応じて変化するのはわかる
- でも、下1桁が4になるのはなぜ？
  - day14cに回答があった。タイムアウト時のタスクが優先された分早くなった。
#### day14c
- メインのタスクの`InitContext`をしないのは一番最初に動いてるから？
#### day14d
- taskbの中身がイマイチよくわかってない
- 現状、3タスクが動いている。
  - メインタスク
    - イベント処理（画面描画、割り込みなど）
### day15
#### day15b
- __TaskBWindowが消える__
  - https://github.com/uchan-nos/os-from-zero/issues/42
  - ここで報告されている
  - mainでマウス初期化前にTaskBをアクティブにしているのが原因
  - `active_layer->Activate`をマウス初期化の下に置く
### day17
- 用語集
  - ブロック(or セクタ)：USBやSSDのデータ領域。ブロック単位で読み書きして、デバイスによりサイズは固定。
  - ボリュームイメージ：ブロックデバイスの中身を記録したデータ。ファイル名とかが記録されてる。
  - パーティション：ブロックデバイスを分けた領域。複数のブロックで構成されている。
  - クラスタ：いくつかのブロックをまとめたもの。クラスタ単位で管理する。
- ボリュームイメージをメモリに読み込む
- BootLoaderのほうぜんぜん覚えてねぇ...
### day18
- day18cでrpnを実装するが、正しく動いていない
  - つねに0を返している
  - 原因がわからなかった
- day18dでstdlibを使うと同じ感じになるとあり、それはday19で直すらしいので、いったん置いておいて先に進む
  - `terminal.cpp`の`MakeArgVector`のwhile条件に、notを入れ忘れてただけだった....
### day20
#### day20a
- `FillRectangle`の仮想アドレスは0x10c1c0だとあるが、自分でnmコマンドをうったところ、0x10c1d0だった
  - 本の方でやるとうまく行かなかった（terminalがとまった）
  - 0x10c1c0をgrepで探したがなかったので、それはとまるか
#### day20b
- セグメント（セグメンテーション）
  - CPUの動作権限を決める機能(8.5)
  - CS(code segment), SS(stack segment)レジスタがGDTを指すことで、権限を決めることができる
  - 細かい部分はわからない
- asmfuncがよくわからない
- 改造したMakeArgVectorもよくわからない...