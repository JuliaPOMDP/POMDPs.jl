# generative model interface functions

# deprecated
# function generate_s end
# function generate_o end
# function generate_sr end
# function generate_so end
# function generate_or end
# function generate_sor end

@deprecate generate_s(args...) gen(Val(:s), args...)
@deprecate generate_o(args...) gen(Val(:o), args...)
@deprecate generate_sr(args...) gen(Val((:s,:r)), args...)
@deprecate generate_so(args...) gen(Val((:s,:o)), args...)
@deprecate generate_or(args...) gen(Val((:o,:r)), args...)
@deprecate generate_sor(args...) gen(Val((:s,:o,:r)), args...)

"""
    initialstate{S}(p::Union{POMDP{S},MDP{S}}, rng::AbstractRNG)

Return the initial state for the problem `p`.

Usually the initial state is sampled from an initial state distribution.
"""
function initialstate end
