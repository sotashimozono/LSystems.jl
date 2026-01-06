module LSystems

using LinearAlgebra, StaticArrays, JSON3

const CONFIG_DIR = joinpath(@__DIR__, "config")
const DEFINED_LSYSTEMS = Dict{String,Any}()

const ASSET_DIR = joinpath(@__DIR__, "..", "assets")



include("abstractlsysmtes.jl")
include("utils.jl")

end # module LSystems
