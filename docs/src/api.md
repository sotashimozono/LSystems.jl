# API Reference

```@autodocs
Modules = [LSystems]
Filter = t -> begin
    # 既存の Function フィルタを維持しつつ、パスで除外
    t isa Function && !(nameof(t) in [
        :substitution_matrix, 
        :substitution_matrix_basis, 
        :substitution_matrix_full
    ])
end
```