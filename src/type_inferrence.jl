
"""
    statetype(t::Type)
    statetype(p::Union{POMDP,MDP})

Return the state type for a problem type (the `S` in `POMDP{S,A,O}`).

```
type A <: POMDP{Int, Bool, Bool} end

statetype(A) # returns Int
```
"""
statetype(t::Type) = statetype(supertype(t))
statetype(t::Type{POMDP{S,A,O}}) where {S,A,O} = S
statetype(t::Type{MDP{S,A}}) where {S,A} = S
statetype(t::Type{Any}) = error("Attempted to extract the state type for $t. This is not a subtype of `POMDP` or `MDP`. Did you declare your problem type as a subtype of `POMDP{S,A,O}` or `MDP{S,A}`?")
statetype(p::Union{POMDP,MDP}) = statetype(typeof(p))

"""
    actiontype(t::Type)
    actiontype(p::Union{POMDP,MDP})

Return the action type for a problem type (the `A` in `POMDP{S,A,O}`).

```
type A <: POMDP{Bool, Int, Bool} end

actiontype(A) # returns Int
```
"""
actiontype(t::Type) = actiontype(supertype(t))
actiontype(t::Type{POMDP{S,A,O}}) where {S,A,O} = A
actiontype(t::Type{MDP{S,A}}) where {S,A} = A
actiontype(t::Type{Any}) = error("Attempted to extract the action type of $t. This is not a subtype of `POMDP` or `MDP`. Did you declare your problem type as a subtype of `POMDP{S,A,O}` or `MDP{S,A}`?")
actiontype(p::Union{POMDP,MDP}) = actiontype(typeof(p))

"""
    obstype(t::Type)

Return the observation type for a problem type (the `O` in `POMDP{S,A,O}`).

```
type A <: POMDP{Bool, Bool, Int} end

obstype(A) # returns Int
```
"""
obstype(t::Type) = obstype(supertype(t))
obstype(t::Type{POMDP{S,A,O}}) where {S,A,O} = O
obstype(t::Type{Any}) = error("Attempted to extract the observation type of $t. This is not a subtype of `POMDP`. Did you declare your problem type as a subtype of `POMDP{S,A,O}`?")
obstype(p::POMDP) = obstype(typeof(p))
