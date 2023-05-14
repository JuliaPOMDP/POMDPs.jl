### Dict Policy ###


"""
     DictPolicy{P<:Union{POMDP,MDP}, T<:AbstractMatrix{Float64}, A}
A generic MDP policy that consists of a value table. The entry at `stateindex(mdp, s)` is the action that will be taken in state `s`.
It is expected that the order of the actions in the value table is consistent with the order of the actions in `act`. 
If `act` is not explicitly set in the construction, `act` is ordered according to `actionindex`.

# Fields 
- `mdp::P` the MDP problem
- `value_table::T` the value table as a |S|x|A| matrix
- `act::Vector{A}` the possible actions
"""
# 加S,A类型？
mutable struct DictPolicy{P<:Union{POMDP,MDP}, T<:AbstractDict{Tuple,Float64}} <: Policy
    mdp::P
    value_dict::T
end

function DictPolicy(mdp::Union{MDP,POMDP})
    return DictPolicy(mdp, Dict{Tuple,Float64}())
end


function action(p::DictPolicy, s)
    available_actions = actions(p.mdp,s)
    max_action = nothing
    max_action_value = 0
    for a in available_actions
        if haskey(p.value_dict,(s,a))
            action_value = p.value_dict[(s,a)]
            if action_value > max_action_value
                max_action = a
                max_action_value = action_value
            end
        else
            p.value_dict[(s,a)] = 0
        end
    end
    if max_action === nothing
        max_action = available_actions[1]
    end
    return max_action
end

function actionvalues(p::DictPolicy, s) ::Dict
    available_actions = actions(p.mdp,s)
    action_dict = Dict()
    for a in available_actions
        action_dict[a] = haskey(p.value_dict,(s,a)) ? p.value_dict[(s,a)] : 0
    end
    return action_dict
end

function Base.show(io::IO, mime::MIME"text/plain", p::DictPolicy{M}) where M <: MDP
    summary(io, p)
    println(io, ':')
    ds = get(io, :displaysize, displaysize(io))
    ioc = IOContext(io, :displaysize=>(first(ds)-1, last(ds)))
    showpolicy(io, mime, p.mdp, p)
end