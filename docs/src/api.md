# API Reference

```@autodocs
Modules = [LSystems]
Filter = t -> begin
    # 既存の Function フィルタを維持しつつ、パスで除外
    t isa Function && !occursin("utils/substitution_matrix.jl", Documenter.Utilities.locinfo(t).file)
end
```