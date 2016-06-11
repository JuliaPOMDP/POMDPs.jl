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
function add_all()
    for p in SUPPORTED_PACKAGES
        add(p, false)
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
        #found = false
        for m in methods(f)
            t = m
            # too messy
            #=
            found ? (break) : (nothing)
            inputs = m.sig
            # method should have an export type form POMDPs.jl as input
            for t in EXPORTED_TYPES
                in(t, inputs.parameters) ? (push!(ms, m); found=true) : (nothing)
            end
            =#
        end
        push!(ms, t)
    end
    ms
end
