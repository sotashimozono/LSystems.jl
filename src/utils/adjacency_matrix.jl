"""
    adjacency_matrix(tile::AbstractTiles, n_iterations::Int)

L-systemをn世代成長させ、その接続関係を隣接行列として返す。
あくまで開発途上
これでできるかも何もわかっていない
"""
function adjacency_matrix(tile::AbstractTiles, n_iterations::Int)
    # 1. 文字列を生成
    lstring = grow_string(tile, n_iterations)
    
    # 2. ノードのインデックス割り当て
    # 文字列中の 'F' (Accept記号) ごとに一意なIDを振る
    node_count = 0
    node_indices = Int[]
    for c in lstring
        if c in tile.accept
            node_count += 1
            push!(node_indices, node_count)
        else
            push!(node_indices, 0) # 記号以外は0
        end
    end

    # 3. グラフの構築（エッジの収集）
    I, J = Int[], Int[]
    stack = Int[] # '[' と ']' の分岐用
    last_node = 0

    for (k, cmd) in enumerate(lstring)
        curr_node_idx = node_indices[k]

        if curr_node_idx > 0 # ノード（Fなど）の場合
            if last_node > 0
                # 前のノードと接続（隣接行列に記録）
                push!(I, last_node); push!(J, curr_node_idx)
                push!(I, curr_node_idx); push!(J, last_node)
            end
            last_node = curr_node_idx
            
        elseif cmd == '['
            push!(stack, last_node) # 現在の位置を保存
            
        elseif cmd == ']'
            last_node = pop!(stack) # 分岐点に戻る
        end
    end

    return sparse(I, J, 1, node_count, node_count)
end