### Dict Policy ###


"""
     DictPolicy{P<:Union{POMDP,MDP}, T<:AbstractDict{Tuple,Float64}}
A generic MDP policy that consists of a value dict.

# Fields 
- `mdp::P` the MDP problem
- `value_table::T` the value dict, key is (s,a) Tuple.
"""

mutable struct DictPolicy{P<:Union{POMDP,MDP}, T<:AbstractDict{Tuple,Float64}} <: Policy
    mdp::P
    value_dict::T
end

function DictPolicy(mdp::Union{MDP,POMDP})
    return DictPolicy(mdp, Dict{Tuple,Float64}())
end

# return the action with the max value
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

# return a dict of actions=>values at state s
function actionvalues(p::DictPolicy, s) ::Dict
    available_actions = actions(p.mdp,s)
    action_dict = Dict()
    for a in available_actions
        action_dict[a] = get(p.value_dict,(s,a),0)
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