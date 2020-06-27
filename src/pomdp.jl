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
    discount(m::POMDP)
    discount(m::MDP)

Return the discount factor for the problem.
"""
function discount end

"""
    transition(m::POMDP, state, action)
    transition(m::MDP, state, action)

Return the transition distribution from the current state-action pair.

If it is difficult to define the probability density or mass function explicitly, consider using `POMDPModelTools.ImplicitDistribution` to define a generative model.
"""
function transition end

"""
    observation(m::POMDP, statep)
    observation(m::POMDP, action, statep)
    observation(m::POMDP, state, action, statep)

Return the observation distribution. You need only define the method with the fewest arguments needed to determine the observation distribution.

If it is difficult to define the probability density or mass function explicitly, consider using `POMDPModelTools.ImplicitDistribution` to define a generative model.

# Example
```julia
using POMDPModelTools # for SparseCat

struct MyPOMDP <: POMDP{Int, Int, Int} end

observation(p::MyPOMDP, sp::Int) = SparseCat([sp-1, sp, sp+1], [0.1, 0.8, 0.1])
```
"""
function observation end

observation(problem::POMDP, a, sp) = observation(problem, sp)
POMDPLinter.@impl_dep observation(::P,::A,::S) where {P<:POMDP,S,A} observation(::P,::S)

observation(problem::POMDP, s, a, sp) = observation(problem, a, sp)
POMDPLinter.@impl_dep observation(::P,::S,::A,::S) where {P<:POMDP,S,A} observation(::P,::A,::S)

"""
    reward(m::POMDP, s, a)
    reward(m::MDP, s, a)

Return the immediate reward for the s-a pair.

    reward(m::POMDP, s, a, sp)
    reward(m::MDP, s, a, sp)

Return the immediate reward for the s-a-s' triple

    reward(m::POMDP, s, a, sp, o)

Return the immediate reward for the s-a-s'-o quad

For some problems, it is easier to express `reward(m, s, a, sp)` or `reward(m, s, a, sp, o)`, than `reward(m, s, a)`, but some solvers, e.g. SARSOP, can only use `reward(m, s, a)`. Both can be implemented for a problem, but when `reward(m, s, a)` is implemented, it should be consistent with `reward(m, s, a, sp[, o])`, that is, it should be the expected value over all destination states and observations.
"""
function reward end

reward(m::Union{POMDP,MDP}, s, a, sp) = reward(m, s, a)
POMDPLinter.@impl_dep reward(::P,::S,::A,::S) where {P<:Union{POMDP,MDP},S,A} reward(::P,::S,::A)

reward(m::Union{POMDP,MDP}, s, a, sp, o) = reward(m, s, a, sp)
POMDPLinter.@impl_dep reward(::P,::S,::A,::S,::O) where {P<:Union{POMDP,MDP},S,A,O} reward(::P,::S,::A,::S)

"""
    isterminal(m::Union{MDP,POMDP}, s)

Check if state `s` is terminal.

If a state is terminal, no actions will be taken in it and no additional rewards will be accumulated. Thus, the value at such a state is, by definition, zero.
"""
isterminal(problem::Union{POMDP,MDP}, state) = false

"""
    initialstate(m::Union{POMDP,MDP})

Return a distribution of initial states for (PO)MDP `m`.

If it is difficult to define the probability density or mass function explicitly, consider using `POMDPModelTools.ImplicitDistribution` to define a model for sampling.
"""
function initialstate end

"""
    initialobs(m::POMDP, s)

Return a distribution of initial observations for POMDP `m` and state `s`.

If it is difficult to define the probability density or mass function explicitly, consider using `POMDPModelTools.ImplicitDistribution` to define a model for sampling.

This function is only used in cases where the policy expects an initial observation rather than an initial belief, e.g. in a reinforcement learning setting. It is not used in a standard POMDP simulation.
"""
function initialobs end


"""
    stateindex(problem::POMDP, s)
    stateindex(problem::MDP, s)

Return the integer index of state `s`. Used for discrete models only.
"""
function stateindex end

"""
    actionindex(problem::POMDP, a)
    actionindex(problem::MDP, a)

Return the integer index of action `a`. Used for discrete models only.
"""
function actionindex end

"""
    obsindex(problem::POMDP, o)

Return the integer index of observation `o`. Used for discrete models only.
"""
function obsindex end

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
