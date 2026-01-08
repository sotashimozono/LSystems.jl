using Documenter
using LSystems

const DOCS_SRC_FIGURES = joinpath(@__DIR__, "src", "assets", "figures")
makedocs(;
    sitename="LSystems.jl",
    modules=[LSystems],
    format=Documenter.HTML(; prettyurls=get(ENV, "CI", nothing) == "true", assets=String[]),
    pages = [
        "Home" => "index.md",
        "Substitution Matrix" => "substitution_matrix.md",
        "API Reference" => "api.md",
        "Library" => "library.md",
    ]
    warnonly=[:missing_docs, :cross_references],
)

deploydocs(; repo="github.com/sotashimozono/LSystems.jl.git", devbranch="main")
