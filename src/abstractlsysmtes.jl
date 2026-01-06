abstract type AbstractTiles{N,T} end

function build_lsystem_type(filepath::String)
    json_content = read(filepath, String)
    data = JSON3.read(json_content)

    struct_name = Symbol(data.name)
    rules_dict = Dict{Char,String}(String(k)[1] => v for (k, v) in data.rules)
    accept_set = Set{Char}(String(s)[1] for s in data.accept)

    desc = get(data, :description, "$(data.name) L-System Model")
    doc_text = """
        $(data.name){N, T} <: AbstractTiles{N, T}

    $desc

    ### Meta Properties
    - **Axiom**: `$(data.axiom)`
    - **Angle**: $(data.angle)°
    - **Accept**: $(data.accept)
    """

    instance = @eval begin
        struct $struct_name{N,T} <: AbstractTiles{N,T}
            axiom::String
            rules::Dict{Char,String}
            angle::T
            accept::Set{Char}
        end

        @doc $doc_text $struct_name

        $struct_name{2,Float64}(
            $(string(data.axiom)),
            $rules_dict,
            deg2rad(Float64($(data.angle))),
            $accept_set,
        )
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
