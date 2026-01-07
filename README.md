# LSystems.jl

[![docs: dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://sotashimozono.github.io/LSystems.jl/dev/)
[![Julia](https://img.shields.io/badge/julia-v1.12+-9558b2.svg)](https://julialang.org)
[![Code Style: Blue](https://img.shields.io/badge/Code%20Style-Blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![codecov](https://codecov.io/gh/sotashimozono/LSystems.jl/graph/badge.svg?token=jXCFXXk37H)](https://codecov.io/gh/sotashimozono/LSystems.jl)
[![Build Status](https://github.com/sotashimozono/Lattice2D.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sotashimozono/Lattice2D.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Fractal を描画する言語としてよく知られる Lindenmayersystem をここに実装してみた  
[Lindenmayer.jl](https://github.com/cormullion/Lindenmayer.jl) というパッケージでより詳細な実装がされている

ここでは、`src/config/model.json` に記載した設定から自動でそれに相当する struct の定義を返す、という実装をした
