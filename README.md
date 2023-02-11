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
  - `register.hpp`の`MemMapRegister.Write`内のfor文の終了条件を下記間違えて、無限ループで止まっていた