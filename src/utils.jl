"""
    add(solver_name::AbstractString)

Downloads and installs a registered solver with name `solver_name`. 
This function is not exported, and must be called:
```julia
julia> using POMDPs
julia> POMDPs.add("MCTS")
```
"""
function add(solver_name::AbstractString, v::Bool=true)
    @assert solver_name in SUPPORTED_PACKAGES string("The JuliaPOMDP package: ", solver_name, " is not supported")
    full_url = string(REMOTE_URL, solver_name, ".jl")
    try
        Pkg.installed(solver_name)
        Pkg.clone(full_url)
        Pkg.build(solver_name)
    catch
        v ? (println("Solver already installed")) : (nothing)
    end
end
