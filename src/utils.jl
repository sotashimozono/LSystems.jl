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
