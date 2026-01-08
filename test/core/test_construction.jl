using StaticArrays

@testset "L-System Logic Tests" begin
    struct MockTile{N,T} <: LSystems.AbstractTiles{N,T}
        axiom::String
        rules::Dict{Char,String}
        angle::T
        accept::Set{Char}
    end

    # テストデータ: コッホ曲線のような基本的なルール
    # 角度90度, 'A'を移動として受理
    tile = MockTile{2, Float64}(
        "A", 
        Dict('A' => "A+A-A-A+A"), 
        deg2rad(90.0), 
        Set(['A'])
    )

    @testset "String Evolution (grow_step & grow_string)" begin
        @test LSystems.grow_step(tile, "A") == "A+A-A-A+A"
        
        # 0回、1回、2回の進化
        @test LSystems.grow_string(tile, 0) == "A"
        @test LSystems.grow_string(tile, 1) == "A+A-A-A+A"

        tile_f = MockTile{2, Float64}("AF", Dict('A' => "B"), 0.0, Set(['B']))
        @test LSystems.grow_step(tile_f, "AF") == "B" 
    end

    @testset "Geometry Calculation (string2positions)" begin
        # 基本的な直進
        simple_tile = MockTile{2, Float64}("A", Dict(), deg2rad(90.0), Set(['A']))
        pos = LSystems.string2positions(simple_tile, "A")
        @test length(pos) == 2
        @test pos[1] == SVector(0.0, 0.0)
        @test pos[2] == SVector(1.0, 0.0)

        # 回転のテスト (+ は左回転)
        # "A+A" -> (0,0) -> (1,0) -> (1,1)
        pos_rot = LSystems.string2positions(simple_tile, "A+A")
        @test length(pos_rot) == 3
        @test pos_rot[3] ≈ SVector(1.0, 1.0) atol=1e-10

        # リピート（数字）のテスト
        # "2A" -> (0,0) -> (1,0) -> (2,0)
        pos_rep = LSystems.string2positions(simple_tile, "2A")
        @test length(pos_rep) == 3
        @test pos_rep[3] == SVector(2.0, 0.0)

        # スタック（分岐 [ ] ）のテスト
        # "[A]A" -> 枝を書いて戻ってから、また同じ方向に進む
        # (0,0)->(1,0) (push), pop to (0,0), (0,0)->(1,0)
        pos_stack = LSystems.string2positions(simple_tile, "[A]A")
        # 戻る際に NaN が挿入されているか
        @test any(isnan, pos_stack[3])
        # pop後に元の位置(0,0)から再開しているか
        @test pos_stack[4] == SVector(0.0, 0.0)
        @test pos_stack[5] == SVector(1.0, 0.0)
    end
end