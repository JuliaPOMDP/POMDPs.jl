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

# @deprecate_requirements_macro(POMDP_require)
# @deprecate_requirements_macro(POMDP_requirements)
# @deprecate_requirements_macro(requirements_info)
# @deprecate_requirements_macro(get_requirements)
# @deprecate_requirements_macro(show_requirements)
# @deprecate_requirements_macro(warn_requirements)
# @deprecate_requirements_macro(req)
# @deprecate_requirements_macro(subreq)

# in future versions, these will go in POMDPLinter
function POMDPLinter.implemented(t::typeof(transition), TT::Type{<:Tuple})
    m = which(t, TT)
    return m.module != POMDPs # see if this was implemented by a user elsewhere
end

# in future versions, these will go in POMDPLinter
function POMDPLinter.implemented(o::typeof(observation), TT::Type{Tuple{M, SP}}) where {M<:POMDP, SP}
    m = which(o, TT)
    return m.module != POMDPs
end
