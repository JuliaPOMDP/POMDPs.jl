using Documenter, POMDPs

makedocs(
    # options
    #deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    modules = [POMDPs]    
)

deploydocs(
    repo = "github.com/JuliaPOMDP/POMDPs.jl.git",
    julia = "0.6",
    osname = "linux"
)
