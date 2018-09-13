# """
#     add(solver_name::AbstractString, v::Bool=true)

# Downloads and installs a registered solver with name `solver_name`. This is a light wrapper around `Pkg.add()`, and it does nothing special or different other than looking up the URL.

# `v` is a verbose flag, when set to true, function will notify the user if solver is already installed.
# This function is not exported, and must be called:
# ```julia
# julia> using POMDPs
# julia> POMDPs.add("MCTS")
# ```
# """
# function add(solver_name::AbstractString, v::Bool=true)
#     @assert solver_name in SUPPORTED_PACKAGES string("The JuliaPOMDP package: ", solver_name, " is not supported")
#     full_url = string(REMOTE_URL, solver_name, ".jl")
#     if solver_name in REGISTERED_PACKAGES
#         Pkg.add(solver_name)
#     else
#         try
#             Pkg.add(Pkg.PackageSpec(url=full_url))
#             Pkg.build(solver_name)
#         catch ex
#             @show typeof(ex)
#             if isa(ex, Pkg.Types.PkgError) && ex.msg == "$solver_name already exists"
#                 v ? (println("Package already installed")) : (nothing)
#             else
#                 rethrow(ex)
#             end
#         end
#     end
# end

# """
#     add_all()

# Downloads and installs all the packages supported by JuliaPOMDP
# """
# function add_all(;native_only=false, v::Bool=true)
#     pkg_set = native_only ? NATIVE_PACKAGES : SUPPORTED_PACKAGES 
#     for p in pkg_set
#         add(p, v)
#     end
# end


# """
#     remove_all()

# Removes all the installed packages supported by JuliaPOMDP
# """
# function remove_all()
#     for p in SUPPORTED_PACKAGES
#         Pkg.rm(p)
#     end
# end


# """
#     build()

# Builds all the existing packages
# """
# function build()
#     for p in SUPPORTED_PACKAGES
#         try
#             Pkg.build(p)
#         catch ex
#             @warn("Error while building $p: $ex")
#         end
#     end
# end



# """
#     test_all()

# Tests all the JuliaPOMDP packages installed on your current machine.
# """
# function test_all(v::Bool=false)
#     for p in SUPPORTED_PACKAGES
#         try
#             Pkg.test(p)
#         catch ex
#             @warn("Error while testing $p: $ex")
#         end
#     end
# end

"""
    available()

Prints all the available packages in the JuliaPOMDP registry
"""
function available()
    reg_dict = read_registry(joinpath(Pkg.depots1(), "registries", "JuliaPOMDP", "Registry.toml"))
    for (uuid, pkginfo) in reg_dict["packages"]
        println(pkginfo["name"])
    end
end


"""
    add_registry()

Adds the JuliaPOMDP registry
"""
function add_registry(;url=POMDP_REGISTRY)
    depot = Pkg.depots1()
    # clone to temp dir first
    tmp = mktempdir()
    Base.shred!(LibGit2.CachedCredentials()) do creds
        LibGit2.with(Pkg.GitTools.clone(url, tmp; header = "registry from $(repr(url))", credentials = creds)) do repo
        end
    end
    # verify that the clone looks like a registry
    if !isfile(joinpath(tmp, "Registry.toml"))
        Pkg.Types.pkgerror("no `Registry.toml` file in cloned registry")
    end
    
    registry = read_registry(joinpath(tmp, "Registry.toml"))
    verify_registry(registry)
    
    # copy to depot
    regpath = joinpath(depot, "registries", registry["name"])
    ispath(dirname(regpath)) || mkpath(dirname(regpath))
    if Pkg.Types.isdir_windows_workaround(regpath)
        existing_registry = read_registry(joinpath(regpath, "Registry.toml"))
        @assert registry["uuid"] == existing_registry["uuid"]
        @info("registry `$(registry["name"])` already exists in `$(Base.contractuser(dirname(regpath)))`")
    else
        cp(tmp, regpath)
        Pkg.Types.printpkgstyle(stdout, :Added, "registry `$(registry["name"])` to `$(Base.contractuser(dirname(regpath)))`")
    end
    
end

function read_registry(regfile)
    registry = Pkg.TOML.parsefile(regfile)
    return registry
end

const REQUIRED_REGISTRY_ENTRIES = ("name", "uuid", "repo", "packages")

function verify_registry(registry::Dict{String, Any})
    for key in REQUIRED_REGISTRY_ENTRIES
        haskey(registry, key) || Pkg.Types.pkgerror("no `$key` entry in `Registry.toml`.")
    end
end
