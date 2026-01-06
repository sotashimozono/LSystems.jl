using MyModule
using Documenter

makedocs(
    sitename = "MyModule.jl",
    modules  = [MyModule],
    pages    = [
        "Home" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/sotashimozono/MyModule.jl.git",
)