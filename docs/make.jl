using Documenter, POMDPs

makedocs(
    modules = [POMDPs],
    format = :html,
    sitename = "POMDPs.jl"
)

deploydocs(
    repo = "github.com/JuliaPOMDP/POMDPs.jl.git",
    julia = "1.0",
    osname = "linux",
    target = "build",
    deps = nothing,
    make = nothing
)
