using SparseArrays
using LinearAlgebra

@testset "Substitution Matrix Tests" begin
    # 1. フィボナッチ列 (L -> LS, S -> L) の検証
    @testset "Fibonacci Matrix (2x2)" begin
        tile = FibonacciFractal()
        res = substitution_matrix(tile, restricted=true)
        M = res.matrix
        idx = res.lookup

        # インデックスの確認 (alphabetはソートされているので 'L'=1, 'S'=2 のはず)
        @test idx['L'] == 1
        @test idx['S'] == 2

        # 行列成分の確認: M[i, j] は シンボル j が 生成する シンボル i の数
        # L -> 1*L + 1*S
        @test M[idx['L'], idx['L']] == 1
        @test M[idx['S'], idx['L']] == 1
        # S -> 1*L + 0*S
        @test M[idx['L'], idx['S']] == 1
        @test M[idx['S'], idx['S']] == 0
        
        # 疎行列であることを確認
        @test issparse(M)
    end

    # 2. restricted フラグの挙動検証 (Koch Curve 等)
    @testset "Restricted vs Full" begin
        # KochCurve は通常 'F', '+', '-' を含む
        tile = KochCurve()
        
        # Restricted: 'F' のみ（acceptが 'F' の場合）
        res_res = substitution_matrix(tile, restricted=true)
        # Full: 'F', '+', '-' すべて
        res_full = substitution_matrix(tile, restricted=false)

        @test length(res_res.alphabet) < length(res_full.alphabet)
        @test '+' in res_full.alphabet
        @test !('+' in res_res.alphabet)
    end

    # 3. 数学的整合性 (列和 = 置換後の文字列長)
    @testset "Consistency with Rules" begin
        tile = FibonacciFractal()
        res = substitution_matrix(tile)
        M = res.matrix
        
        for (j, char_j) in enumerate(res.alphabet)
            # 各列の合計値は、その文字の置換ルールの長さと一致するはず
            # (ただし、restricted=true の場合は accept 外の文字が引かれる)
            rule_len = length(get(tile.rules, char_j, string(char_j)))
            @test sum(M[:, j]) == rule_len
        end
    end

    # 4. 固有値の確認 (物理的なスケーリング)
    @testset "Scaling Factor (Eigenvalues)" begin
        tile = FibonacciFractal()
        res = substitution_matrix(tile)
        # 黄金比 (1.618...) を確認
        vals = eigvals(Array(res.matrix)) # 固有値計算のために一時的に密行列へ
        @test maximum(real.(vals)) ≈ (1 + sqrt(5)) / 2
    end
end


@testset "Heighway Dragon Matrix Analysis" begin
    # JSONデータからインスタンスを取得（DEFINED_LSYSTEMSにあると想定）
    tile = LSystems.DEFINED_LSYSTEMS["heighwaydragon"]

    @testset "Full Matrix (Internal States + Geometry)" begin
        # restricted=false で全記号 (+, -, F, X, Y) を追跡
        res = substitution_matrix(tile, restricted=false)
        M = res.matrix
        idx = res.lookup
        
        # 記号セットの確認
        @test length(res.alphabet) == 5
        @test issetequal(res.alphabet, ['+', '-', 'F', 'X', 'Y'])

        # ルールの検証: X -> X+YF+
        # X(column) が生成するもの(rows): X:1, +:2, Y:1, F:1
        col_X = idx['X']
        @test M[idx['X'], col_X] == 1
        @test M[idx['+'], col_X] == 2  # '+' が2つ含まれることを正しくカウントできるか
        @test M[idx['Y'], col_X] == 1
        @test M[idx['F'], col_X] == 1

        # ルールの検証: Y -> -FX-Y
        # Y(column) が生成するもの(rows): -:2, F:1, X:1, Y:1
        col_Y = idx['Y']
        @test M[idx['-'], col_Y] == 2
        @test M[idx['F'], col_Y] == 1
        @test M[idx['X'], col_Y] == 1
        @test M[idx['Y'], col_Y] == 1
    end

    @testset "Restricted Matrix (Physical Segments only)" begin
        # restricted=true で 'F' のみを抽出
        res = substitution_matrix(tile, restricted=true)
        
        @test res.alphabet == ['F']
        @test size(res.matrix) == (1, 1)
        
        # 'F' はこのルールセットでは定数（F -> F）として扱われる
        @test res.matrix[1, 1] == 1
    end

    @testset "Dynamical Properties" begin
        res = substitution_matrix(tile, restricted=false)
        M_dense = Array(res.matrix)
        
        # 固有値解析
        λ = eigvals(M_dense)
        max_λ = maximum(real.(λ))
        
        # ドラゴン曲線の全文字列の長さの増大率は、この行列の最大固有値に支配される
        # X(1) -> X+YF+(5), Y(1) -> -FX-Y(5) なので、
        # 非常に大きい系ではステップごとに約1.6倍〜程度（正確な値は固有値による）で成長する
        @test max_λ > 1.0
    end
end