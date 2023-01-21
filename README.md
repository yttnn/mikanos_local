# mikanos_local
## めも
### day02
#### day02a
- インテリセンスまわりを整備`@c_cpp_properties.json`
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
