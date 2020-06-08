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

function read_registry(regfile)
    registry = Pkg.TOML.parsefile(regfile)
    return registry
end

function add_registry(;kwargs...)
    @warn("""POMDPs.add_registry() is deprecated. Use Pkg.pkg"registry add https://github.com/JuliaPOMDP/Registry" instead.""")
    Pkg.pkg"registry add https://github.com/JuliaPOMDP/Registry"
end
