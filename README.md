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