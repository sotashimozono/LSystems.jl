using JSON3

@testset "LSystems Initialization & Constants" begin
    # 1. パスの整合性テスト（省略：前回と同じ）

    # 2. JSON読み込みの網羅性テスト
    @testset "JSON Discovery & Loading" begin
        config_files = readdir(LSystems.CONFIG_DIR)
        json_files = filter(f -> endswith(f, ".json"), config_files)

        # DEFINED_LSYSTEMS の数とファイル数が一致するか
        @test length(LSystems.DEFINED_LSYSTEMS) == length(json_files)

        for file in json_files
            # ファイル名（キー）: "gospercurve"
            name_key = splitext(file)[1]
            filepath = joinpath(LSystems.CONFIG_DIR, file)

            # JSONの中身を読み込んで「期待される型名」を取得: "GosperCurve"
            raw_data = JSON3.read(read(filepath, String))
            expected_struct_name = raw_data.name

            @testset "L-System: $name_key" begin
                # Dictに登録されているか
                @test haskey(LSystems.DEFINED_LSYSTEMS, name_key)

                instance = LSystems.DEFINED_LSYSTEMS[name_key]

                # インスタンスの型名が、JSONの "name" フィールドと一致するか確認
                # Evaluated: "GosperCurve" == "GosperCurve" となるはずです
                @test string(nameof(typeof(instance))) == expected_struct_name

                # 抽象型を継承しているか
                @test instance isa LSystems.AbstractTiles
            end
        end
    end
end
