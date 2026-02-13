using Documenter
using LSystems
using Downloads

const DOCS_SRC_FIGURES = joinpath(@__DIR__, "src", "assets", "figures")

assets_dir = joinpath(@__DIR__, "src", "assets")
mkpath(assets_dir)
favicon_path = joinpath(assets_dir, "favicon.ico")

Downloads.download("https://github.com/sotashimozono.png", favicon_path)

makedocs(
    sitename = "LSystems.jl",
    modules=[LSystems],
    format = Documenter.HTML(
        canonical = "https://codes.sota-shimozono.com/LSystems.jl/stable/",
        prettyurls = get(ENV, "CI", "false") == "true",
        mathengine = MathJax3(Dict(
            :tex => Dict(
                :inlineMath => [["\$", "\$"], ["\\(", "\\)"]],
                :tags => "ams",
                :packages => ["base", "ams", "autoload", "physics"]
            ),
        )),
        assets = ["assets/favicon.ico"],
    ),
    pages=[
        "Home" => "index.md",
        "Substitution Matrix" => "substitution_matrix.md",
        "API Reference" => "api.md",
        "Library" => "library.md",
    ],
    warnonly=[:missing_docs, :cross_references],
)

deploydocs(; repo="github.com/sotashimozono/LSystems.jl.git", devbranch="main")
