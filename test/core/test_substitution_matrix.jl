using LinearAlgebra

@testset "HilbeltPath Matrix Analysis" begin
    # 準備：LSystems モジュールから HilbeltPath を取得
    tile = LSystems.DEFINED_LSYSTEMS["hilbeltpath"]

    @testset "Full Operator Structure (restrict_level=0)" begin
        # ルールのみに依存した 5x5 の正方行列 (alphabet: +, -, A, B, F)
        res = substitution_matrix(tile, restrict_level=0)
        M = res.matrix
        idx = res.lookup
        
        @test size(M) == (5, 5)
        @test issetequal(res.alphabet, ['+', '-', 'A', 'B', 'F'])

        # ルールの検証: A -> -BF+AFA+FB-
        # A(col) が生成するもの: A:2, B:2, F:3, +:2, -:2 (合計11文字)
        col_A = idx['A']
        @test M[idx['A'], col_A] == 2
        @test M[idx['B'], col_A] == 2
        @test M[idx['F'], col_A] == 3
        @test M[idx['+'], col_A] == 2
        @test M[idx['-'], col_A] == 2
        @test sum(M[:, col_A]) == 11

        # ルールの検証: B -> +AF-BFB-FA+
        col_B = idx['B']
        @test M[idx['A'], col_B] == 2
        @test M[idx['B'], col_B] == 2
        @test M[idx['F'], col_B] == 3
        @test M[idx['+'], col_B] == 2
        @test M[idx['-'], col_B] == 2
        @test sum(M[:, col_B]) == 11

        # F(col) は恒等写像 (F -> F)
        @test M[idx['F'], idx['F']] == 1
    end
    @testset "Level 1 Projection (A, B, F, +, -)" begin
        # ジェネレータと物理記号を含む 5x5 (または 3x3) 行列
        res = substitution_matrix(tile, restrict_level=1)
        M = res.matrix
        idx = res.lookup
        
        @test 'A' in res.alphabet
        @test 'F' in res.alphabet
        
        col_A = idx['A']
        @test M[idx['A'], col_A] == 2
        @test M[idx['B'], col_A] == 2
        @test M[idx['F'], col_A] == 3
        @test sum(M[:, col_A]) == 7
        # ルールの検証: B -> +AF-BFB-FA+
        col_B = idx['B']
        @test M[idx['A'], col_B] == 2
        @test M[idx['B'], col_B] == 2
        @test M[idx['F'], col_B] == 3
        @test sum(M[:, col_B]) == 7

        # 系のダイナミクスを支配する固有値は 4.0
        λ = LinearAlgebra.eigvals(Array(Float64.(M)))
        @test maximum(real.(λ)) ≈ 4.0 atol=1e-8
    end

    @testset "Level 2 Projection (Physical Scaling)" begin
        # 物理空間 'F' のみに制限された有効行列
        res = substitution_matrix(tile, restrict_level=2)
        M_eff = res.matrix
        
        @test res.alphabet == ['F']
        @test size(M_eff) == (1, 1)
        
        # 有効ハミルトニアン的な観点から、1ステップで F が 4つ分に
        # XXX : 本来であれば平均サイト数成長率として level 1 での最大固有値をおろしたい。
        @test Float64(M_eff[1, 1]) ≈ 1.0 atol=1e-8
    end
end

@testset "GosperCurve Matrix Analysis" begin
    # 1. 準備：GosperCurve の取得
    tile = LSystems.DEFINED_LSYSTEMS["gospercurve"]

    @testset "Full Operator Structure (restrict_level=0)" begin
        # alphabet: +, -, A, B の 4x4 正方行列
        res = substitution_matrix(tile, restrict_level=0)
        M = res.matrix
        idx = res.lookup
        
        @test size(M) == (4, 4)
        @test issetequal(res.alphabet, ['+', '-', 'A', 'B'])

        # ルールの検証: A -> A-B--B+A++AA+B- (長さ15)
        # A(col) が生成するもの: A:4, B:3, +:4, -:4 (合計15文字)
        col_A = idx['A']
        @test M[idx['A'], col_A] == 4
        @test M[idx['B'], col_A] == 3
        @test M[idx['+'], col_A] == 4
        @test M[idx['-'], col_A] == 4
        @test sum(M[:, col_A]) == 15

        # ルールの検証: B -> +A-BB--B-A++A+B (長さ15)
        # B(col) が生成するもの: A:3, B:4, +:4, -:4 (合計15文字)
        col_B = idx['B']
        @test M[idx['A'], col_B] == 3
        @test M[idx['B'], col_B] == 4
        @test M[idx['+'], col_B] == 4
        @test M[idx['-'], col_B] == 4
        @test sum(M[:, col_B]) == 15
    end

    @testset "Level 1 Projection (A, B, +, -)" begin
        # GosperCurve の場合、A, B 自身が Generator なので Level 0 と同様の構造
        res = substitution_matrix(tile, restrict_level=1)
        M = res.matrix
        idx = res.lookup
        
        @test issetequal(res.alphabet, ['A', 'B'])
        
        # 固有値解析: ダイナミクスの核心を調べる
        # A, B の再帰ブロック [4 3; 3 4] の固有値は 7 (4+3) と 1 (4-3)
        # この "7" こそが Gosper 島の面積拡大率 (Scaling Factor) に対応する
        λ = LinearAlgebra.eigvals(Array(Float64.(M)))
        @test maximum(real.(λ)) ≈ 7.0 atol=1e-8
    end

    @testset "Level 2 Projection (Physical A, B)" begin
        # 物理空間 'A', 'B' のみに制限された 2x2 行列
        res = substitution_matrix(tile, restrict_level=2)
        M_eff = res.matrix
        idx = res.lookup
        
        @test issetequal(res.alphabet, ['A', 'B'])
        @test size(M_eff) == (2, 2)
        
        # 物理サイト A, B 間の遷移行列が正しく抽出されているか
        # [M_AA M_AB] = [4 3]
        # [M_BA M_BB]   [3 4]
        @test M_eff[idx['A'], idx['A']] == 4
        @test M_eff[idx['B'], idx['A']] == 3
        @test M_eff[idx['A'], idx['B']] == 3
        @test M_eff[idx['B'], idx['B']] == 4
        
        # 物理サイトの総数成長率が最大固有値 7.0 と一致することを期待
        λ_eff = LinearAlgebra.eigvals(Array(Float64.(M_eff)))
        @test maximum(real.(λ_eff)) ≈ 7.0 atol=1e-8
    end
end