# adds a registered solver
function add(solver_name::AbstractString)
    full_url = string(REMOTE_URL, solver_name)
    Pkg.clone(full_url)
    Pkg.build(solver_name)
end
