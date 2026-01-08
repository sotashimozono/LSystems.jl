# Substitution Matrix

L-system の置換則 $P$ は、線形演算子（置換行列） $M$ として表現できる。この行列を解析することで、文字列の具体的な生成を待たずに、系の成長率や固定点における統計的性質を議論することができる。

## 定義

扱う文字列の集合を $\{c_1, c_2, \dots, c_n\}$ とし、置換規則$P$で変換するときの各文字の出現個数をベクトル $\mathbf{v}$ とすると、次ステップにおける各文字の個数は次のように記述される。

$$\mathbf{v}_{n+1} = M \mathbf{v}_n$$

ここで、行列成分 $M_{ij}$ は「文字 $j$ を 1 回置換したときに現れる文字 $i$ の個数」に対応し、この$M$がここで定義される Substitution matrix である。

## 基底の制限レベル (Restrict Level)

`LSystems.jl` では、解析の目的に応じて 3 段階の基底（行列サイズ）を選択できる。

| Level | 名称 | 構成される基底 (Basis) | 用途 |
| :--- | :--- | :--- | :--- |
| **0** | **Full** | Axiom, Rules, Accept に含まれる全記号 | システム全体の完全な遷移の記述 |
| **1** | **Core** | Rules の置換元 (Key) + Accept | 成長を司る生成子と物理量のダイナミクス |
| **2** | **Physical**| Accept に含まれる記号のみ | 物理的な観測量（サイト数等）の有効スケーリング |

## 物理的意味：最大固有値とスケーリング

置換行列 $M$ の最大固有値 $\lambda_{max}$ は、系の**成長率（Scaling Factor）**に対応します。
- **Hilbert Curve**: $\lambda_{max} = 4.0$ (2次元空間を埋める再帰ユニットの拡大率)
- **Gosper Curve**: $\lambda_{max} = 7.0$ (Gosper 島の面積増大率)
- **Fibonacci Chain**: $\lambda_{max} = \phi \approx 1.618$ (黄金比)

## API Reference (Auto-generated)

```@autodocs
Modules = [LSystems]
Pages   = ["utils/substitution_matrix.jl"]
Order   = [:function, :type]
```
