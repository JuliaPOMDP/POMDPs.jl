@deprecate implemented POMDPLinter.implemented
@deprecate RequirementSet POMDPLinter.RequirementSet
@deprecate check_requirements POMDPLinter.check_requirements
@deprecate show_requirements POMDPLinter.show_requirements
@deprecate get_requirements POMDPLinter.get_requirements
@deprecate requirements_info POMDPLinter.requirements_info

# Tried for 2 hours 

# macro deprecate_requirements_macro(name)
#     newmacro = Symbol("@$(string(name))")
#     return nothing
#     quote
#          macro $name(args...)
#             @warn("POMDPs.@$name is deprecated, use POMDPLinter.@$name instead.", maxlog=1)
#             only(args)
#         end
#    end
# end

# for name in [:implemented]
#     @eval macro $name(arg)
#               macroname = $name
#               newmacro = Symbol("@$macroname")
#               @warn("POMDPs.@$macroname is deprecated, use POMDPLinter.@$macroname instead.", maxlog=1)
#               return :(POMDPLinter.$newmacro($(esc(arg))))
#           end
# end

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
        @warn("gen(DDNOut(:$symbols), m, s, a, rng) is deprecated, use @gen(:$symbols)(m, s, a, rng) instead.", maxlog=1)
    else
        symbolstring = join([":$s" for s in symbols], ", ")
        @warn("gen(DDNOut($symbolstring), m, s, a, rng) is deprecated, use @gen($symbolstring)(m, s, a, rng) instead.", maxlog=1)
    end
    return genout(Val(symbols), m, s, a, rng)
end

@deprecate initialstate(m, rng) rand(rng, initialstate(m))
@deprecate initialstate_distribution initialstate
@deprecate initialobs(m, s, rng) rand(rng, initialobs(m, s))
