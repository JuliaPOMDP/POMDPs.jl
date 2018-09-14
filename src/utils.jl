add(solver_name::AbstractString, v::Bool=true) = error("""
                                                        `POMDPs.add` has been removed.
                                                        To add POMDPs packages, use `POMDPs.add_registry()` with standard `Pkg.add`
                                                       """)

add_all(;native_only=false, v::Bool=true) = error("""
                                                    `POMDPs.add_all` has been removed.
                                                    To add POMDPs packages, use `POMDPs.add_registry()` with standard `Pkg.add`
                                                  """)
remove_all() = error("""
                     `POMDPs.remove_all` has been removed.
                     To remove POMDPs packages, use `POMDPs.add_registry()` with standard `Pkg.rm`
                     """)

build() = error("""
                `POMDPs.build` has been removed.
                To build POMDPs packages, use `POMDPs.add_registry()` with standard `Pkg.build`
                """)

test_all(v::Bool=false) = error("""
                                `POMDPs.test_all` has been removed.
                                To test POMDPs packages, use `POMDPs.add_registry()` with standard `Pkg.test`
                                """)

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
