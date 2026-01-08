using JSON3, Base.Docs

@testset "L-System Type Generation Tests" begin
    mktempdir() do tmpdir
        test_json_path = joinpath(tmpdir, "test_struct.json")
        
        json_data = Dict(
            "name" => "test_struct",
            "axiom" => "A",
            "rules" => Dict("A" => "AB", "B" => "A"),
            "accept" => ["A", "B"],
            "angle" => 90,
            "metadata" => Dict(
                "description" => "A test test_struct L-System",
                "figure" => Dict("shape" => "line.png")
            )
        )
        
        open(test_json_path, "w") do io
            JSON3.pretty(io, json_data)
        end

        # 2. 関数を実行してインスタンスを生成
        instance = LSystems.build_lsystem_type(test_json_path)

        # 3. 型の定義チェック
        @testset "Type Definition" begin
            # 型名が正しいか
            @test typeof(instance) <: LSystems.AbstractTiles{2, Float64}
            @test nameof(typeof(instance)) == :test_struct
            
            # 型がグローバルスコープにエクスポートされているか（Mainなどのモジュールで確認）
            @test isdefined(LSystems, :test_struct)
        end

        # 4. フィールド値のチェック
        @testset "Field Values" begin
            @test instance.axiom == "A"
            @test instance.rules['A'] == "AB"
            @test instance.rules['B'] == "A"
            @test instance.angle ≈ deg2rad(90.0)
            @test 'A' in instance.accept
        end

        # 5. ドキュメントのチェック
        @testset "Documentation" begin
            # 1. LSystems モジュールが持つドキュメントのメタデータ（辞書）を取得
            meta_dict = Base.Docs.meta(LSystems)
            
            # 2. 検索対象の Binding（名前の紐付け）を作成
            # これなら test_struct 型そのものがまだ不完全でも「名前」で検索できる
            binding = Base.Docs.Binding(LSystems, :test_struct)
            
            # 3. メタデータ内にその名前が登録されているかチェック
            @test haskey(meta_dict, binding)
            
            # 4. 内容を文字列として検証
            doc_content = string(meta_dict[binding])
            
            @testset "Docstring Content" begin
                @test occursin("test_struct", doc_content)
                @test occursin("A test test_struct L-System", doc_content)
                @test occursin("### Visual Representation", doc_content)
                @test occursin("Axiom", doc_content)
            end
        end
    end
end