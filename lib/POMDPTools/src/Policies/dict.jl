"""
     ValueDictPolicy(mdp)

A generic MDP policy that consists of a `Dict` storing Q-values for state-action pairs. If there are no entries higher than a default value, this will fall back to a default policy.

# Keyword Arguments 
- `value_table::AbstractDict` the value dict, key is (s, a) Tuple.
- `default_value::Float64` the defalut value of `value_dict`.
- `default_policy::Policy` the policy taken when no action has a value higher than `default_value`
"""
Base.@kwdef struct ValueDictPolicy{M<:MDP, T<:AbstractDict, P<:Policy} <: Policy
    mdp::M
    value_dict::T          = Dict{Tuple{statetype(mdp), actiontype(mdp)}, Float64}()
    default_value::Float64 = -Inf
    default_policy::P      = RandomPolicy(mdp)
end

ValueDictPolicy(m; kwargs...) = ValueDictPolicy(;mdp=m, kwargs...)

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
        end
    end
    if isnothing(max_action)
        max_action = action(p.default_policy, s)
    end
    return max_action
end

"""
Return a Dict mapping actions to values at state s.
"""
function valuemap(p::ValueDictPolicy, s)
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
