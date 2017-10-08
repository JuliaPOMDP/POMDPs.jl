using Documenter, POMDPs

makedocs(
    # options
    #deps = Deps.pip("pygments", "mkdocs", "python-markdown-math"),
    modules = [POMDPs]    
)

deploydocs(
    repo = "JuliaPOMDP/POMDPs.jl",
    julia = "0.6",
    osname = "linux"
)
