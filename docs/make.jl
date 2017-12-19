using Documenter, POMDPs

makedocs(
    modules = [POMDPs]    
)

deploydocs(
    repo = "github.com/JuliaPOMDP/POMDPs.jl.git",
    julia = "0.6",
    osname = "linux"
)
