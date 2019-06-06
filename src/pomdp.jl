# POMDP model functions
"""
    POMDP{S,A,O}

Abstract base type for a partially observable Markov decision process.

    S: state type
    A: action type
    O: observation type
"""
abstract type POMDP{S,A,O} end

"""
    MDP{S,A}

Abstract base type for a fully observable Markov decision process.

    S: state type
    A: action type
"""
abstract type MDP{S,A} end

"""
    n_states(problem::POMDP)
    n_states(problem::MDP)

Return the number of states in `problem`. Used for discrete models only.
"""
function n_states end

"""
    n_actions(problem::POMDP)
    n_actions(problem::MDP)

Return the number of actions in `problem`. Used for discrete models only.
"""
function n_actions end

"""
    n_observations(problem::POMDP)

Return the number of observations in `problem`. Used for discrete models only.
"""
function n_observations end

"""
    discount(problem::POMDP)
    discount(problem::MDP)

Return the discount factor for the problem.
"""
function discount end

"""
    transition(problem::POMDP, state, action)
    transition(problem::MDP, state, action)

Return the transition distribution from the current state-action pair
"""
function transition end

"""
    observation(problem::POMDP, statep)
    observation(problem::POMDP, action, statep)
    observation(problem::POMDP, state, action, statep)

Return the observation distribution. You need only define the method with the fewest arguments needed to determine the observation distribution.

# Example
```julia
using POMDPModelTools # for SparseCat

struct MyPOMDP <: POMDP{Int, Int, Int} end

observation(p::MyPOMDP, sp::Int) = SparseCat([sp-1, sp, sp+1], [0.1, 0.8, 0.1])
```
"""
function observation end

"""
    observation(problem::POMDP, action, statep)

Return the observation distribution for the a-s' tuple (action and next state)
"""
observation(problem::POMDP, a, sp) = observation(problem, sp)
# @impl_dep observation(::P,::A,::S) where {P<:POMDP,S,A} observation(::P,::S)
@impl_dep observation(::P,::A,::S) where {P<:POMDP,S,A} observation(::P,::S)

"""
    observation(problem::POMDP, state, action, statep)

Return the observation distribution for the s-a-s' tuple (state, action, and next state)
"""
observation(problem::POMDP, s, a, sp) = observation(problem, a, sp)
@impl_dep observation(::P,::S,::A,::S) where {P<:POMDP,S,A} observation(::P,::A,::S)

"""
    reward(m::POMDP, s, a)
    reward(m::MDP, s, a)

Return the immediate reward for the s-a pair.

For some problems, it is easier to express `reward(m, s, a, sp)` than
`reward(m, s, a)`, but some solvers, e.g. SARSOP, can only use
`reward(m, s, a)`. Both can be implemented for a problem, but when
`reward(m, s, a)` is implemented, it should be consistent with
`reward(m, s, a, sp)`, that is, it should be the expected value over all
destination states.
"""
function reward end

"""
    reward(m::POMDP, s, a, sp)
    reward(m::MDP, s, a, sp)

Return the immediate reward for the s-a-s' triple
"""
reward(problem::Union{POMDP,MDP}, s, a, sp) = reward(problem, s, a)
@impl_dep reward(::P,::S,::A,::S) where {P<:Union{POMDP,MDP},S,A} reward(::P,::S,::A)

"""
    isterminal(problem::POMDP, state)
    isterminal(problem::MDP, state)

Check if state s is terminal
"""
isterminal(problem::Union{POMDP,MDP}, state) = false

"""
    initialstate_distribution(pomdp::POMDP)
    initialstate_distribution(mdp::MDP)

Return a distribution of the initial state of the pomdp or mdp.
"""
function initialstate_distribution end
@deprecate initial_state_distribution initialstate_distribution

"""
    stateindex(problem::POMDP, s)
    stateindex(problem::MDP, s)

Return the integer index of state `s`. Used for discrete models only.
"""
function stateindex end
@deprecate state_index stateindex

"""
    actionindex(problem::POMDP, a)
    actionindex(problem::MDP, a)

Return the integer index of action `a`. Used for discrete models only.
"""
function actionindex end
@deprecate action_index actionindex

"""
    obsindex(problem::POMDP, o)

Return the integer index of observation `o`. Used for discrete models only.
"""
function obsindex end
@deprecate obs_index obsindex

"""
    convert_s(::Type{V}, s, problem::Union{MDP,POMDP}) where V<:AbstractArray
    convert_s(::Type{S}, vec::V, problem::Union{MDP,POMDP}) where {S,V<:AbstractArray}

Convert a state to vectorized form or vice versa.
"""
function convert_s end

convert_s(T::Type{A1}, s::A2, problem::Union{MDP, POMDP}) where {A1<:AbstractArray, A2<:AbstractArray} = convert(T, s)

convert_s(::Type{A}, s::Number, problem::Union{MDP,POMDP}) where A<:AbstractArray = convert(A, [s])
convert_s(::Type{N}, v::AbstractArray{F}, problem::Union{MDP, POMDP}) where {N<:Number, F<:Number} = convert(N, first(v))


"""
    convert_a(::Type{V}, a, problem::Union{MDP,POMDP}) where V<:AbstractArray
    convert_a(::Type{A}, vec::V, problem::Union{MDP,POMDP}) where {A,V<:AbstractArray}

Convert an action to vectorized form or vice versa.
"""
function convert_a end

convert_a(T::Type{A1}, s::A2, problem::Union{MDP, POMDP}) where {A1<:AbstractArray, A2<:AbstractArray} = convert(T, s)

convert_a(::Type{A}, s::Number, problem::Union{MDP,POMDP}) where A<:AbstractArray = convert(A,[s])
convert_a(::Type{N}, v::AbstractArray{F}, problem::Union{MDP, POMDP}) where {N<:Number, F<:Number} = convert(N, first(v))


"""
    convert_o(::Type{V}, o, problem::Union{MDP,POMDP}) where V<:AbstractArray
    convert_o(::Type{O}, vec::V, problem::Union{MDP,POMDP}) where {O,V<:AbstractArray}

Convert an observation to vectorized form or vice versa.
"""
function convert_o end

convert_o(T::Type{A1}, s::A2, problem::Union{MDP, POMDP}) where {A1<:AbstractArray, A2<:AbstractArray} = convert(T, s)

convert_o(::Type{A}, s::Number, problem::Union{MDP,POMDP}) where A<:AbstractArray = convert(A, [s])
convert_o(::Type{N}, v::AbstractArray{F}, problem::Union{MDP, POMDP}) where {N<:Number, F<:Number} = convert(N, first(v))
