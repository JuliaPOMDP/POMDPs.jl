"""
    add(solver_name::AbstractString)

Downloads and installs a registered solver with name `solver_name`. 
This function is not exported, and must be called:
```julia
julia> using POMDPs
julia> POMDPs.add("MCTS")
```
"""
function add(solver_name::AbstractString)
    @assert solver_name in SUPPORTED_SOLVERS string("The solver: ", solver_name, " is not supported")
    full_url = string(REMOTE_URL, solver_name, ".jl")
    Pkg.clone(full_url)
    Pkg.build(solver_name)
end
