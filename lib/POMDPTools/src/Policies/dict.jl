"""
     ValueDictPolicy{M<:MDP, T<:AbstractDict{Tuple,Float64}}
A generic MDP policy that consists of a value dict.

# Fields 
- `mdp::P` the MDP problem
- `value_table::T` the value dict, key is (s,a) Tuple.
- `default_value::Float64` the defalut value of `value_dict`.
"""

struct ValueDictPolicy{M<:MDP, T<:AbstractDict} <: Policy
    mdp::M
    value_dict::T
    default_value::Float64
end

ValueDictPolicy(mdp::MDP) = 
    ValueDictPolicy(mdp, Dict{Tuple{statetype(mdp), actiontype(mdp)}, Float64}(),0.0)

ValueDictPolicy(mdp::MDP,default_value::Float64) = 
    ValueDictPolicy(mdp, Dict{Tuple{statetype(mdp), actiontype(mdp)}, Float64}(),default_value)

# return the action with the max value
function action(p::ValueDictPolicy, s)
    available_actions = actions(p.mdp,s)

    if isnothing(available_actions) || isempty(available_actions)
        error("State $(s) has no action to do. Please check your MDP definition.")
    end

    max_action = nothing
    max_action_value = p.default_value
    for a in available_actions
        if haskey(p.value_dict,(s,a))
            action_value = p.value_dict[(s,a)]
            if action_value > max_action_value
                max_action = a
                max_action_value = action_value
            end
        else
            p.value_dict[(s,a)] = p.default_value
        end
    end
    if isnothing(max_action)
        max_action = rand(available_actions)
    end
    return max_action
end

# return a dict of actions=>values at state s
function actionvalues(p::ValueDictPolicy, s) ::Dict
    available_actions = actions(p.mdp,s)
    action_dict = Dict{actiontype(p.mdp),Float64}()
    for a in available_actions
        action_dict[a] = get(p.value_dict,(s,a),p.default_value)
    end
    return action_dict
end

function Base.show(io::IO, mime::MIME"text/plain", p::ValueDictPolicy{M}) where M <: MDP
    summary(io, p)
    println(io, ':')
    ds = get(io, :displaysize, displaysize(io))
    ioc = IOContext(io, :displaysize=>(first(ds)-1, last(ds)))
    showpolicy(io, mime, p.mdp, p)
end