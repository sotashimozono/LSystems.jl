module LSystems

using LinearAlgebra, StaticArrays, JSON3

const PKG_ROOT = pkgdir(@__MODULE__)
const CONFIG_DIR = joinpath(@__DIR__, "config")
const FIGURE_DIR = joinpath(PKG_ROOT, "figures")

const DEFINED_LSYSTEMS = Dict{String,Any}()

include("abstractlsysmtes.jl")
include("utils.jl")

end # module LSystems
