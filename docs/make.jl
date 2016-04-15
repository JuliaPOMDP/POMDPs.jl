using Documenter, POMDPs

makedocs(
    # options
    modules = [POMDPs]    
)

deploydocs(
    repo = "github.com/JuliaPOMDP/POMDPs.jl.git",
    julia = "release",
    osname = "linux"
)
