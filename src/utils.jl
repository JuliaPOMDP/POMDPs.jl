# adds a registered solver
function add(solver_name::AbstractString)
    @assert solver_name in SUPPORTED_SOLVERS string("The solver: ", solver_name, " is not supported")
    full_url = string(REMOTE_URL, solver_name, ".jl")
    Pkg.clone(full_url)
    Pkg.build(solver_name)
end
