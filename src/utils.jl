"""
    grow_string(tile::AbstractTiles, iterations::Int)
L-systemのルールに基づいて、指定された回数だけ文字列を成長させる関数
"""
function grow_string(tile::AbstractTiles, iterations::Int)
    current_str = tile.axiom
    for _ in 1:iterations
        current_str = grow_step(tile, current_str)
    end
    return current_str
end
export grow_string

function grow_step(tile::AbstractTiles, current_str::String)
    new_str = sprint() do io
        for c in current_str
            if haskey(tile.rules, c)
                print(io, tile.rules[c])
            elseif c != 'F'
                print(io, c)
            end
        end
    end
    return new_str
end
export grow_step

"""
    string2positions(tile::AbstractTiles{2,T}, lstring::String) where {T}
作成したstringをもとに、タイルの描画に必要な座標配列を生成する
"""
function string2positions(tile::AbstractTiles{2,T}, lstring::String) where {T}
    curr_pos = SVector{2,T}(0.0, 0.0)
    curr_dir = SVector{2,T}(1.0, 0.0)
    stack = Tuple{SVector{2,T},SVector{2,T}}[]
    positions = SVector{2,T}[curr_pos]

    repeats = 1

    θ = tile.angle
    rot_left = @SMatrix [cos(θ) -sin(θ); sin(θ) cos(θ)]
    rot_right = @SMatrix [cos(-θ) -sin(-θ); sin(-θ) cos(-θ)]
    for cmd in lstring
        if isdigit(cmd)
            repeats = parse(Int, cmd)
            continue
        end
        for _ in 1:repeats
            if cmd in tile.accept
                curr_pos += curr_dir
                push!(positions, curr_pos)
            elseif cmd == '+'
                curr_dir = rot_left * curr_dir
            elseif cmd == '-'
                curr_dir = rot_right * curr_dir
            elseif cmd == '['
                push!(stack, (curr_pos, curr_dir))
            elseif cmd == ']'
                if !isempty(stack)
                    curr_pos, curr_dir = pop!(stack)
                    push!(positions, SVector{2,T}(NaN, NaN))
                    push!(positions, curr_pos)
                end
            end
        end
        repeats = 1
    end
    return positions
end
export string2positions

"""
    substitution_matrix(tile::LSystems.AbstractTiles; restricted::Bool=false)

L-systemの置換行列を生成する。
`restricted=true` の場合、`tile.accept` に含まれるシンボルのみを抽出する。
`restricted=false` の場合、axiomとrulesに登場するすべての記号（フルセット）を対象とする。

res = (matrix, alphabet, lookup) という NamedTupleを返す。
res.lookup[Char] で、Charが表すmatrixの行を調べることができる
"""
function substitution_matrix(tile::LSystems.AbstractTiles; restricted::Bool=false)
    # 1. アルファベットの決定
    if restricted
        alphabet = sort(collect(tile.accept))
    else
        # axiom, rulesのKey, rulesのValueに登場する全文字を抽出
        all_chars = Set{Char}(tile.axiom)
        for (k, v) in tile.rules
            push!(all_chars, k)
            union!(all_chars, v)
        end
        alphabet = sort(collect(all_chars))
    end
    n = length(alphabet)
    char_to_idx = Dict(c => i for (i, c) in enumerate(alphabet))
    # 2. Sparse Matrix 構築用の座標リスト
    # sparse(I, J, V) の形式で構築するのが最も効率的
    I_coords = Int[]
    J_coords = Int[]
    V_values = Int[]
    for (j, char_j) in enumerate(alphabet)
        # 置換ルールを取得（存在しない場合は恒等写像として扱う）
        replacement = get(tile.rules, char_j, string(char_j))
        # 置換後の文字列内の各文字をカウント
        counts = Dict{Char, Int}()
        for c in replacement
            counts[c] = get(counts, c, 0) + 1
        end
        for (char_i, count) in counts
            # alphabetに含まれる（restrictedの場合は制限内にある）文字のみ記録
            if haskey(char_to_idx, char_i)
                push!(I_coords, char_to_idx[char_i])
                push!(J_coords, j)
                push!(V_values, count)
            end
        end
    end
    # 3. 疎行列の生成
    M = sparse(I_coords, J_coords, V_values, n, n)
    return (matrix=M, alphabet=alphabet, lookup=char_to_idx)
end
export substitution_matrix