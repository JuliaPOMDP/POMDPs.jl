@deprecate implemented POMDPLinter.implemented
@deprecate RequirementSet POMDPLinter.RequirementSet
@deprecate check_requirements POMDPLinter.check_requirements
@deprecate show_requirements POMDPLinter.show_requirements
@deprecate get_requirements POMDPLinter.get_requirements
@deprecate requirements_info POMDPLinter.requirements_info


macro implemented(ex)
    @warn("POMDPs.@implemented is deprecated, use POMDPLinter.@implemented instead.", maxlog=1)
    tplex = POMDPLinter.convert_req(ex)
    return quote
        POMDPLinter.implemented($(esc(tplex))...)
    end
end

macro POMDP_require(args...)
    @warn("POMDPs.@POMDP_require is deprecated, use POMDPLinter.@POMDP_require instead.", maxlog=1)
    POMDPLinter.pomdp_require(args...)
end

macro POMDP_requirements(args...)
    @warn("POMDPs.@POMDP_requirements is deprecated, use POMDPLinter.@POMDP_requirements instead.", maxlog=1)
    POMDPLinter.pomdp_requirements(args...)
end

macro requirements_info(exprs...)
    @warn("POMDPs.@requirements_info is deprecated, use POMDPLinter.@requirements_info instead.", maxlog=1)
    quote
        requirements_info($([esc(ex) for ex in exprs]...))
    end
end

macro get_requirements(call)
    @warn("POMDPs.@get_requirements is deprecated, use POMDPLinter.@get_requirements instead.", maxlog=1)
    return quote get_requirements($(esc(POMDPLinter.convert_call(call)))...) end
end

macro show_requirements(call)
    @warn("POMDPs.@show_requirements is deprecated, use POMDPLinter.@show_requirements instead.", maxlog=1)
    quote
        reqs = get_requirements($(esc(POMDPLinter.convert_call(call)))...)
        show_requirements(reqs)
    end
end

macro warn_requirements(call)
    @warn("POMDPs.@warn_requirements is deprecated, use POMDPLinter.@warn_requirements instead.", maxlog=1)
    quote
        reqs = get_requirements($(esc(POMDPLinter.convert_call(call)))...)
        c = check_requirements(reqs)
        if !ismissing(c) && c == false
            show_requirements(reqs)
        end
    end
end

macro req(args...)
    :(error("POMDPs.@req no longer exists. Please use POMDPLinter.@req"))
end

macro subreq(args...)
    :(error("POMDPs.@subreq no longer exists. Please use POMDPLinter.@subreq"))
end

function gen(o::DDNOut{symbols}, m::Union{MDP,POMDP}, s, a, rng) where symbols
    if symbols isa Symbol
        Base.depwarn("gen(DDNOut(:$symbols), m, s, a, rng) is deprecated, use @gen(:$symbols)(m, s, a, rng) instead.", :gen)
        # @warn("gen(DDNOut(:$symbols), m, s, a, rng) is deprecated, use @gen(:$symbols)(m, s, a, rng) instead.", maxlog=1)
    else
        symbolstring = join([":$s" for s in symbols], ", ")
        Base.depwarn("gen(DDNOut($symbolstring), m, s, a, rng) is deprecated, use @gen($symbolstring)(m, s, a, rng) instead.", :gen)
        # @warn("gen(DDNOut($symbolstring), m, s, a, rng) is deprecated, use @gen($symbolstring)(m, s, a, rng) instead.", maxlog=1)
    end
    return genout(DDNOut(symbols), m, s, a, rng)
end

@deprecate initialstate(m, rng) rand(rng, initialstate(m))
@deprecate initialstate_distribution initialstate

# for the case when initialstate is called, but initialstate_distribution is implemented
function initialstate(m::Union{MDP,POMDP})
    method = which(initialstate_distribution, Tuple{typeof(m)})
    if method.module == POMDPs # ignore the @deprecated definition to avoid infinite recurse
        throw(MethodError(initialstate, (m,)))
    else
        Base.depwarn("Falling back to using deprecated function initialstate_distribution(::$(typeof(m))). Please implement this as initialstate(::$(typeof(m))) instead.", :initialstate)
        return initialstate_distribution(m)
    end
end

@deprecate initialobs(m, s, rng) rand(rng, initialobs(m, s))

dimensions(s::Any) = error("dimensions is no longer part of the POMDPs.jl interface.")

"""
    available()

Prints all the available packages in the JuliaPOMDP registry
"""
function available()
    Base.depwarn("POMDPs.available() is deprecated. Please see the POMDPs.jl README for a list of packages.", :available)
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
    Base.depwarn("""POMDPs.add_registry() is deprecated. The JuliaPOMDP Registry is no longer needed to download most solvers. If the registry is needed, use Pkg.pkg"registry add https://github.com/JuliaPOMDP/Registry" instead.""", :add_registry)
    Pkg.pkg"registry add https://github.com/JuliaPOMDP/Registry"
end
