"""
    AlphaVectorPolicy(pomdp::POMDP, alphas, action_map)

Construct a policy from alpha vectors.

# Arguments
- `alphas`: an |S| x (number of alpha vecs) matrix or a vector of alpha vectors.
- `action_map`: a vector of the actions correponding to each alpha vector

    AlphaVectorPolicy{P<:POMDP, A}

Represents a policy with a set of alpha vectors.

Use `action` to get the best action for a belief, and `alphavectors` and `alphapairs` to 

# Fields
- `pomdp::P` the POMDP problem 
- `n_states::Int` the number of states in the POMDP
- `alphas::Vector{Vector{Float64}}` the list of alpha vectors
- `action_map::Vector{A}` a list of action corresponding to the alpha vectors
"""
struct AlphaVectorPolicy{P<:POMDP, A} <: Policy
    pomdp::P # needed for mapping states to locations in alpha vectors
    n_states::Int
    alphas::Vector{Vector{Float64}}
    action_map::Vector{A}
end

@deprecate AlphaVectorPolicy(pomdp::POMDP, alphas) AlphaVectorPolicy(pomdp, alphas, ordered_actions(pomdp))

function AlphaVectorPolicy(m::POMDP, alphas::AbstractVector, amap)
    AlphaVectorPolicy(m, length(states(m)), alphas,
                      convert(Vector{actiontype(m)}, amap))
end

# assumes alphas is |S| x (number of alpha vecs)
function AlphaVectorPolicy(p::POMDP, alphas::Matrix{Float64}, action_map)
    # turn alphas into vector of vectors
    num_actions = size(alphas, 2)
    alpha_vecs = Vector{Float64}[]
    for i = 1:num_actions
        push!(alpha_vecs, vec(alphas[:,i]))
    end

    AlphaVectorPolicy(p, length(states(p)), alpha_vecs,
                      convert(Vector{actiontype(p)}, action_map))
end

updater(p::AlphaVectorPolicy) = DiscreteUpdater(p.pomdp)

"""
Return an iterator of alpha vector-action pairs in the policy.
"""
alphapairs(p::AlphaVectorPolicy) = (p.alphas[i]=>p.action_map[i] for i in 1:length(p.alphas))

"""
Return the alpha vectors.
"""
alphavectors(p::AlphaVectorPolicy) = p.alphas

# The three functions below rely on beliefvec being implemented for the belief type 
# Implementations of beliefvec are below
function value(p::AlphaVectorPolicy, b)
    bvec = beliefvec(p.pomdp, p.n_states, b)
    maximum(dot(bvec,a) for a in p.alphas)
end

function action(p::AlphaVectorPolicy, b)
    bvec = beliefvec(p.pomdp, p.n_states, b)
    num_vectors = length(p.alphas)
    best_idx = 1
    max_value = -Inf
    for i = 1:num_vectors
        temp_value = dot(bvec, p.alphas[i])
        if temp_value > max_value
            max_value = temp_value
            best_idx = i
        end
    end
    return p.action_map[best_idx]
end

function actionvalues(p::AlphaVectorPolicy, b)
    bvec = beliefvec(p.pomdp, p.n_states, b)
    num_vectors = length(p.alphas)
    max_values = -Inf*ones(length(actions(p.pomdp)))
    for i = 1:num_vectors
        temp_value = dot(bvec, p.alphas[i])
        ai = actionindex(p.pomdp, p.action_map[i]) 
        if temp_value > max_values[ai]
            max_values[ai] = temp_value
        end
    end
    return max_values
end

"""
    POMDPPolicies.beliefvec(m::POMDP, n_states::Int, b)

Return a vector-like representation of the belief `b` suitable for calculating the dot product with the alpha vectors.
"""
function beliefvec end

function beliefvec(m::POMDP, n, b::SparseCat)
    return sparsevec(collect(stateindex(m, s) for s in b.vals), collect(b.probs), n)
end
beliefvec(m::POMDP, n, b::DiscreteBelief) = b.b
beliefvec(m::POMDP, n, b::AbstractArray) = b

function beliefvec(m::POMDP, n_states, b)
    sup = support(b)
    bvec = zeros(n_states)
    for s in sup
        bvec[stateindex(m, s)] = pdf(b, s)
    end
    return bvec
end

function Base.push!(p::AlphaVectorPolicy, alpha::Vector{Float64}, a)
    push!(p.alphas, alpha)
    push!(p.action_map, a)
end

@deprecate beliefvec(m::POMDP, b) beliefvec(m, length(states(m)), b)
