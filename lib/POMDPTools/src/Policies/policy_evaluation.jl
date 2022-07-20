"""
Value function for a policy on an MDP.

If `v` is a `DiscreteValueFunction`, access the value for a state with `v(s)`
"""
struct DiscreteValueFunction{M<:MDP} <: Function
    m::M
    values::Vector{Float64}
end

(v::DiscreteValueFunction)(s) = v.values[stateindex(v.m, s)]

"""
    evaluate(m::MDP, p::Policy)
    evaluate(m::MDP, p::Policy; rewardfunction=POMDPs.reward)

Calculate the value for a policy on an MDP using the approach in equation 4.2.2 of Kochenderfer, *Decision Making Under Uncertainty*, 2015.

Returns a DiscreteValueFunction, which maps states to values.

# Example
```
using POMDPModelTools, POMDPPolicies, POMDPModels
m = SimpleGridWorld()
u = evaluate(m, FunctionPolicy(x->:left))
u([1,1]) # value of always moving left starting at state [1,1]
```
"""
function evaluate(m::MDP, p::Policy; rewardfunction=POMDPs.reward)
    t = policy_transition_matrix(m, p)
    r = policy_reward_vector(m, p, rewardfunction=rewardfunction)
    u = (I-discount(m)*t)\r
    return DiscreteValueFunction(m, u)
end

"""
    policy_transition_matrix(m::Union{MDP, POMDP}, p::Policy)

Create an |S|x|S| sparse transition matrix for a given policy.

The row corresponds to the current state and column to the next state. Corresponds to ``T^π`` in equation (4.7) in Kochenderfer, *Decision Making Under Uncertainty*, 2015.
"""
function policy_transition_matrix(m::Union{MDP,POMDP}, p::Policy)
    rows = Int[]
    cols = Int[]
    probs = Float64[]
    state_space = states(m)
    ns = length(state_space)
    for s in state_space
      if !isterminal(m, s) # if terminal, the transition probabilities are all just zero
        si = stateindex(m, s)
        a = action(p, s)
        td = transition(m, s, a)
        for (sp, p) in weighted_iterator(td)
          if p > 0.0
            spi = stateindex(m, sp)
            push!(rows, si)
            push!(cols, spi)
            push!(probs, p)
          end
        end
      end
    end

    return sparse(rows, cols, probs, ns, ns)
end

function policy_reward_vector(m::Union{MDP,POMDP}, p::Policy; rewardfunction=POMDPs.reward)
    state_space = states(m)
    r = zeros(length(state_space))
    for s in state_space
        if !isterminal(m, s) # if terminal, the transition probabilities are all just zero
            si = stateindex(m, s)
            a = action(p, s)
            td = transition(m, s, a)
            for (sp, p) in weighted_iterator(td)
                if p > 0.0
                    r[si] += p*rewardfunction(m, s, a, sp)
                end
            end
        end
    end
    return r
end
