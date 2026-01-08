module LSystems

using LinearAlgebra, StaticArrays, SparseArrays, JSON3

const PKG_ROOT = pkgdir(@__MODULE__)
const CONFIG_DIR = joinpath(@__DIR__, "config")
const FIGURE_DIR = joinpath(PKG_ROOT, "docs", "assets", "figures")

const DEFINED_LSYSTEMS = Dict{String,Any}()

include("abstractlsystems.jl")
include("utils.jl")

end # module LSystems
