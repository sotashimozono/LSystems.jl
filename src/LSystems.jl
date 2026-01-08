module LSystems

using LinearAlgebra, StaticArrays, JSON3
using SparseArrays

const PKG_ROOT = pkgdir(@__MODULE__)
const CONFIG_DIR = joinpath(@__DIR__, "config")
const FIGURE_DIR = joinpath(PKG_ROOT, "docs", "assets", "figures")

const DEFINED_LSYSTEMS = Dict{String,Any}()

include("abstractlsystems.jl")
include("utils.jl")
include("utils/substitution_matrix.jl")

end # module LSystems
