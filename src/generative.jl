# generative model interface functions

function gen end

"""
    initialstate{S}(p::Union{POMDP{S},MDP{S}}, rng::AbstractRNG)

Return the initial state for the problem `p`.

Usually the initial state is sampled from an initial state distribution.
"""
function initialstate end
