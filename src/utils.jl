"""
    add(solver_name::AbstractString, v::Bool=true)

Downloads and installs a registered solver with name `solver_name`. 
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
    try
        Pkg.clone(full_url)
        Pkg.build(solver_name)
    catch
        v ? (println("Package already installed")) : (nothing)
    end
end

"""
    add_all()
Downloads and installs all the packages supported by JuliaPOMDP
"""
function add_all(;native_only=false)
    native_only ? pkg_set = NATIVE_PACKAGES : pkg_set = SUPPORTED_PACKAGES 
    for p in pkg_set
        add(p, false)
    end
end



"""
    remove(solver_name::AbstractString)

Remove a JuliaPOMDP package.
"""
function remove(solver_name::AbstractString)
    @assert solver_name in SUPPORTED_PACKAGES string("The JuliaPOMDP package: ", solver_name, " is not supported")
    Pkg.rm(solver_name)
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
    update()
Updates all the installed packages
"""
function update()
    for p in SUPPORTED_PACKAGES
        # check if package is intalled
        if isdir(Pkg.dir(p))
            Pkg.checkout(p)
        end
    end
end

"""
    build()
Builds all the existing packages
"""
function build()
    for p in SUPPORTED_PACKAGES
        # see of package is intalled
        if isdir(Pkg.dir(p))
            Pkg.build(p)
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
        catch
            v ? (println("Package ", p, "not being tested")) : (nothing)
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

"""
    POMDPs.get_methods(flist::Vector{Function})
Takes in a vector of function names, and returns the associated POMDPs.jl methods
"""
function get_methods(flist::Vector{Function})
    ms = Method[]
    # loop though functions
    for f in flist
        t = nothing
        # find the method from POMDPs.jl
        for m in methods(f)
            t = m
        end
        push!(ms, t)
    end
    ms
end



