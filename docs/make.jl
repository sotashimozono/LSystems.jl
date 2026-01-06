using LSystems
using Documenter

makedocs(
    sitename = "LSystems.jl",
    modules  = [LSystems],
    pages    = [
        "Home" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/sotashimozono/LSystems.jl.git",
)