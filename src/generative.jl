# generative model interface functions

"""
    generate_s{S,A}(p::Union{POMDP{S,A},MDP{S,A}}, s::S, a::A, rng::AbstractRNG)

Return the next state given current state `s` and action taken `a`.
"""
function generate_s end

"""
    generate_o{S,A,O}(p::POMDP{S,A,O}, s::S, a::A, sp::S, rng::AbstractRNG)

Return the next observation given current state `s`, action taken `a` and next state `sp`.

Usually the observation would only depend on the next state `sp`.

    generate_o{S,A,O}(p::POMDP{S,A,O}, s::S, rng::AbstractRNG)

Return the observation from the current state. This should be used to generate initial observations.
"""
function generate_o end

"""
    generate_sr{S}(p::Union{POMDP{S},MDP{S}}, s, a, rng::AbstractRNG)

Return the next state `sp` and reward for taking action `a` in current state `s`.
"""
function generate_sr end

"""
    generate_so{S,A,O}(p::POMDP{S,A,O}, s::S, a::A, rng::AbstractRNG)

Return the next state `sp` and observation `o`.
"""
function generate_so end

"""
    generate_or{S,A,O}(p::POMDP{S,A,O}, s::S, a::A, sp::S, rng::AbstractRNG)

Return the observation `o` and reward for taking action `a` in current state `s` reaching state `sp`.
"""
function generate_or end

"""
    generate_sor{S,A,O}(p::POMDP{S,A,O}, s::S, a::A, rng::AbstractRNG)

Return the next state `sp`, observation `o` and reward for taking action `a` in current state `s`.
"""
function generate_sor end

"""
    initialstate{S}(p::Union{POMDP{S},MDP{S}}, rng::AbstractRNG)

Return the initial state for the problem `p`.

Usually the initial state is sampled from an initial state distribution.
"""
function initialstate end
@deprecate initial_state initialstate
