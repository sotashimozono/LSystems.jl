"""
    substitution_matrix_basis(tile::LSystems.AbstractTiles, restrict_level::Int)

L-system の置換行列を構成する基底の集合を返す
- restrict_level=0 : 置換に含まれるすべての文字
- restrict_level=1 : Ruleの根本/Accept に含まれる文字のみ
- restrict_level=2 : Accept に含まれる文字のみ
"""
function substitution_matrix_basis(tile::AbstractTiles, restrict_level::Int)
    alphabet_set = Set{Char}()
    if restrict_level==0
        union!(alphabet_set, tile.accept)
        for (k, v) in tile.rules
            push!(alphabet_set, k)  # 置換元の文字
            union!(alphabet_set, v) # 置換後の文字列に含まれる全文字
        end
    elseif restrict_level==1
        # Rules と Accept
        union!(alphabet_set, tile.accept)
        for (k, v) in tile.rules
            push!(alphabet_set, k)
        end
    else
        # Acceptのみ
        union!(alphabet_set, tile.accept)
    end
    return alphabet_set
end
export substitution_matrix_basis

"""
    substitution_matrix(tile::LSystems.AbstractTiles; restrict_level::Bool=false)

L-systemの置換行列を生成する。`substitution_matrix_basis` で定義されるrestrict_levelに応じた基底を用いて置換行列を出力する。
現在 `restrict_level=1,2` は実験的な運用のため注意されたし。
(単に部分空間への射影を取っているだけであり、補空間の寄与を取り込めていない。)

res = (matrix, alphabet, lookup) という NamedTupleを返す。
res.lookup[Char] で、Charが表すmatrixの行を調べることができる
"""
function substitution_matrix(tile::AbstractTiles; restrict_level::Int=0)
    # 1. フル空間の行列と情報を取得
    res_full = substitution_matrix_full(tile)
    M_full = res_full.matrix

    if restrict_level == 0
        return res_full
    end

    # 2. 制限する空間の基底（文字セット）を取得
    basis_set = substitution_matrix_basis(tile, restrict_level)
    target_alphabet = sort([c for c in basis_set if haskey(res_full.lookup, c)])
    indices = [res_full.lookup[c] for c in target_alphabet]

    # 3. フル空間のインデックスの中から、抽出対象のインデックスを特定
    # alphabet は sort し、順序を一貫させる
    target_alphabet = sort([c for c in basis_set if haskey(res_full.lookup, c)])
    indices = [res_full.lookup[c] for c in target_alphabet]

    # 4. 射影 (PMP) の実行：スライス操作が P * M * P' に相当
    M_proj = M_full[indices, indices]

    # 新しい lookup を作成
    new_lookup = Dict(c => i for (i, c) in enumerate(target_alphabet))

    return (matrix=M_proj, alphabet=target_alphabet, lookup=new_lookup)
end
export substitution_matrix

"""
    substitution_matrix_full(tile::LSystems.AbstractTiles)

`substitution_matrix()` でいうところの `restrict_level=0` の行列を返すオブジェクト
"""
function substitution_matrix_full(tile::AbstractTiles)
    # 1. ルールに登場する全文字を漏れなく収集する
    alphabet_set = substitution_matrix_basis(tile, 0)
    alphabet = sort(collect(alphabet_set))

    n = length(alphabet)
    lookup = Dict(c => i for (i, c) in enumerate(alphabet))

    # 2. 正方疎行列の構築 (n × n)
    I_coords = Int[]
    J_coords = Int[]
    V_values = Int[]
    for (j, char_j) in enumerate(alphabet)
        # 置換ルールを取得
        replacement = get(tile.rules, char_j, string(char_j))

        counts = Dict{Char,Int}()
        for c in replacement
            counts[c] = get(counts, c, 0) + 1
        end

        for (char_i, count) in counts
            # alphabet（基底空間）に含まれる文字への遷移のみを記録
            if haskey(lookup, char_i)
                push!(I_coords, lookup[char_i])
                push!(J_coords, j)
                push!(V_values, count)
            end
        end
    end
    M = sparse(I_coords, J_coords, V_values, n, n)
    return (matrix=M, alphabet=alphabet, lookup=lookup)
end
export substitution_matrix_full


"""
    stationary_density(tile::AbstractTiles; restrict_level::Int=1)

L-system の固定点における各記号の出現比率（定常密度）を計算する。
restrict_level=1 (成長の核) を使用することを推奨。

# 戻り値
- `Dict{Char, Float64}`: 記号 => 出現確率 (合計が 1.0 に規格化される)
"""
function stationary_density(tile::AbstractTiles; restrict_level::Int=1)
    # 1. 指定レベルの置換行列を取得
    res = substitution_matrix(tile; restrict_level=restrict_level)
    M = res.matrix
    alphabet = res.alphabet
    
    # 2. 固有値・固有ベクトルを計算
    # 疎行列から密度行列へ変換して eigen を実行
    # (小さな行列であればこれで十分。巨大な場合は Arpack.jl 等を検討)
    vals, vecs = eigen(Array(Float64.(M)))
    
    # 3. 最大固有値のインデックスを特定
    # 実数成分の最大値を探す
    idx_max = argmax(real.(vals))
    v_max = real.(vecs[:, idx_max])
    
    # 4. 全成分を正にし、和が 1 になるよう規格化
    v_max = abs.(v_max) 
    p = v_max ./ sum(v_max)
    
    # 5. 文字と確率を対応させて返す
    return Dict(alphabet[i] => p[i] for i in 1:length(alphabet))
end
export stationary_density