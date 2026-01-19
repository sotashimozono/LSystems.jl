abstract type AbstractTiles{N,T} end
function build_lsystem_type(filepath::String)
    json_content = read(filepath, String)
    data = JSON3.read(json_content)
    # prepare struct components
    struct_name = Symbol(data.name)
    rules_dict = Dict{Char,String}(String(k)[1] => v for (k, v) in data.rules)
    accept_set = Set{Char}(String(s)[1] for s in data.accept)

    ## prepare documentation (meta information)
    meta = data.metadata
    desc = get(meta, :description, "$(data.name) L-System Model")
    # figure path
    base_name = basename(filepath)
    asset_path = splitext(base_name)[1]
    figure_path = joinpath("assets", "figures", asset_path)
    fig_name = joinpath(figure_path, meta.figure.shape)
    # rules table
    sorted_rules = sort(collect(rules_dict); by=x -> x[1])
    rules_md_rows = join(["| **$(r[1])** | `$(r[2])` |" for r in sorted_rules], "\n")

    rules_table = """
    ### Substitution Rules
    | Left | Right |
    | :--- | :--- |
    $rules_md_rows
    """

    doc_text = """
        $(data.name){N, T} <: AbstractTiles{N, T}

    $desc

    ### Visual Representation
    ![Here should be a Figure]($(fig_name))

    ### Configuration
    | Property | Value |
    | :--- | :--- |
    | **Axiom** | `$(data.axiom)` |
    | **Angle** | $(data.angle)° |
    | **Accept Symbols** | `$(data.accept)` |
        
    $rules_table

    ### Metadata
    | Key | Value |
    | :--- | :--- |
    | **Source File** | `$(splitpath(filepath)[end])` |
    | **Type** | L-System |
    """
    # construct the type directly
    instance = @eval begin
        struct $struct_name{N,T} <: AbstractTiles{N,T}
            axiom::String
            rules::Dict{Char,String}
            angle::T
            accept::Set{Char}
        end

        function $struct_name()
            return $struct_name{2,Float64}(
                $(string(data.axiom)),
                $rules_dict,
                deg2rad(Float64($(data.angle))),
                $accept_set,
            )
        end
        # attach documentation
        @doc $doc_text $struct_name
        # return an instance
        $struct_name()
    end

    @eval export $struct_name

    return instance
end

for file in readdir(CONFIG_DIR)
    if endswith(file, ".json")
        filepath = joinpath(CONFIG_DIR, file)
        structname = splitext(file)[1]
        DEFINED_LSYSTEMS[structname] = build_lsystem_type(filepath)
    end
end
export DEFINED_LSYSTEMS
