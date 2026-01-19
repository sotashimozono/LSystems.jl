# LSystems.jl

[L-system](https://ja.wikipedia.org/wiki/L-system) とは植物の生長プロセスなどを記述するために使用されるもの。フラクタルや繰り込み群フローを解くためによく使われている。

## About

Lindenmeyer System とは以下の情報から定義される記号力学系である

- 更新されていく文字 $\{V\}$
- 更新されずに不変な文字 $\{S\}$
- 初期状態を示す $\omega$
- $\{V\}$を書き換えていく置換規則 $P$

この規則から生成される文字列を適当に2次元にや3次元などに対応付ける turtle graphics などの規則を別で使用することで Fractal の生成などに応用することが可能である。(例としてモジュール内で定義したモデルは [Library](library.md) から参照することができる。)

## Related Works

- [Lindenmayer.jl](https://github.com/cormullion/Lindenmayer.jl) というパッケージが既に実装や描画の優れた interface を提供している。
