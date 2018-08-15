"""
    add(solver_name::AbstractString, v::Bool=true)

Downloads and installs a registered solver with name `solver_name`. This is a light wrapper around `Pkg.add()`, and it does nothing special or different other than looking up the URL.

`v` is a verbose flag, when set to true, function will notify the user if solver is already installed.
This function is not exported, and must be called:
```julia
julia> using POMDPs
julia> POMDPs.add("MCTS")
```
"""
function add(solver_name::AbstractString, v::Bool=true)
    @assert solver_name in SUPPORTED_PACKAGES string("The JuliaPOMDP package: ", solver_name, " is not supported")
    full_url = string(REMOTE_URL, solver_name, ".jl")
    if solver_name in REGISTERED_PACKAGES
        Pkg.add(solver_name)
    else
        try
            Pkg.add(Pkg.PackageSpec(url=full_url))
            Pkg.build(solver_name)
        catch ex
            @show typeof(ex)
            if isa(ex, Pkg.Types.PkgError) && ex.msg == "$solver_name already exists"
                v ? (println("Package already installed")) : (nothing)
            else
                rethrow(ex)
            end
        end
    end
end

"""
    add_all()

Downloads and installs all the packages supported by JuliaPOMDP
"""
function add_all(;native_only=false, v::Bool=true)
    pkg_set = native_only ? NATIVE_PACKAGES : SUPPORTED_PACKAGES 
    for p in pkg_set
        add(p, v)
    end
end


"""
    remove_all()

Removes all the installed packages supported by JuliaPOMDP
"""
function remove_all()
    for p in SUPPORTED_PACKAGES
        Pkg.rm(p)
    end
end


"""
    build()

Builds all the existing packages
"""
function build()
    for p in SUPPORTED_PACKAGES
        try
            Pkg.build(p)
        catch ex
            @warn("Error while building $p: $ex")
        end
    end
end



"""
    test_all()

Tests all the JuliaPOMDP packages installed on your current machine.
"""
function test_all(v::Bool=false)
    for p in SUPPORTED_PACKAGES
        try
            Pkg.test(p)
        catch ex
            @warn("Error while testing $p: $ex")
        end
    end
end

"""
    available()

Prints all the available packages in JuliaPOMDP
"""
function available()
    for p in SUPPORTED_PACKAGES
        println(p)
    end
end
