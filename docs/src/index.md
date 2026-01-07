# LSystems.jl

[L-system](https://ja.wikipedia.org/wiki/L-system) とは植物の生長プロセスなどを記述するために使用されるもの。フラクタルや繰り込み群フローを解くためによく使われている。

## About

構造としては以下を与えることで再帰的に文字列を構築する

- 更新されていく文字 $\{V\}$
- 更新されずに不変な文字 $\{S\}$
- 初期状態を示す $\omega$
- $\{V\}$ を書き換えていく置換規則 $P$

実際にはこの文字列を 2 次元平面とかの実空間に翻訳する規則を与える必要もあるかもしれない

## Related Works

- [Lindenmayer.jl](https://github.com/cormullion/Lindenmayer.jl) というパッケージが既に実装や描画の優れた interface を提供している。
