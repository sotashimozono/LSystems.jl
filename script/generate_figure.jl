using LSystems
using Plots

for (name, lsys) in DEFINED_LSYSTEMS
    system = lsys.axiom
    while length(system) < 5000
        system = grow_step(lsys, system)
    end

    positions = string2positions(lsys, system)
    posx = [p[1] for p in positions]
    posy = [p[2] for p in positions]
    p = plot(
        posx,
        posy;
        aspect_ratio=1,
        title=name,
        legend=false,
        grid=false,
        axis=false,
        ticks=false,
        framestyle=:none,
    )
    savefig(p, joinpath(LSystems.FIGURE_DIR, "$(name)", "shape.png"))
end
