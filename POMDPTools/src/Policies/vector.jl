### Vector Policy ###
# maintained by @zsunberg and @etotheipluspi

"""
    VectorPolicy{S,A}
A generic MDP policy that consists of a vector of actions. The entry at `stateindex(mdp, s)` is the action that will be taken in state `s`.

# Fields
- `mdp::MDP{S,A}` the MDP problem
- `act::Vector{A}` a vector of size |S| mapping state indices to actions
"""
mutable struct VectorPolicy{S,A} <: Policy
    mdp::MDP{S,A}
    act::Vector{A}
end

action(p::VectorPolicy, s) = p.act[stateindex(p.mdp, s)]

"""
    VectorSolver{A}
Solver for VectorPolicy. Doesn't do any computation - just sets the action vector.

# Fields 
- `act::Vector{A}` the action vector
"""
mutable struct VectorSolver{A}
    act::Vector{A}
end

function solve(s::VectorSolver{A}, mdp::MDP{S,A}) where {S,A}
    return VectorPolicy{S,A}(mdp, s.act)
end

function Base.show(io::IO, mime::MIME"text/plain", p::VectorPolicy)
    summary(io, p)    
    println(io, ':')
    ds = get(io, :displaysize, displaysize(io))
    ioc = IOContext(io, :displaysize=>(first(ds)-1, last(ds)))
    showpolicy(ioc, mime, p.mdp, p)
end

"""
     ValuePolicy{P<:Union{POMDP,MDP}, T<:AbstractMatrix{Float64}, A}
A generic MDP policy that consists of a value table. The entry at `stateindex(mdp, s)` is the action that will be taken in state `s`.
It is expected that the order of the actions in the value table is consistent with the order of the actions in `act`. 
If `act` is not explicitly set in the construction, `act` is ordered according to `actionindex`.

# Fields 
- `mdp::P` the MDP problem
- `value_table::T` the value table as a |S|x|A| matrix
- `act::Vector{A}` the possible actions
"""
struct ValuePolicy{P<:Union{POMDP,MDP}, T<:AbstractMatrix{Float64}, A} <: Policy
    mdp::P
    value_table::T
    act::Vector{A}
end
function ValuePolicy(mdp::Union{MDP,POMDP}, value_table=zeros(length(states(mdp)), length(actions(mdp))))
    return ValuePolicy(mdp, value_table, ordered_actions(mdp))
end

action(p::ValuePolicy, s) = p.act[argmax(p.value_table[stateindex(p.mdp, s),:])]

actionvalues(p::ValuePolicy, s) = p.value_table[stateindex(p.mdp, s), :]

function Base.show(io::IO, mime::MIME"text/plain", p::ValuePolicy{M}) where M <: MDP
    summary(io, p)
    println(io, ':')
    ds = get(io, :displaysize, displaysize(io))
    ioc = IOContext(io, :displaysize=>(first(ds)-1, last(ds)))
    showpolicy(io, mime, p.mdp, p)
end
