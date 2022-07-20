"""
    transition_matrices(m::Union{MDP,POMDP})
    transition_matrices(m; sparse=true)

Construct transition matrices for (PO)MDP m.

The returned object is an associative object (usually a Dict), where the keys are actions. Each value in this object is an AbstractMatrix where the row corresponds to the state index of s and the column corresponds to the state index of s'. The entry in the matrix is the probability of transitioning from state s to state s'.
"""
function transition_matrices(m::Union{MDP,POMDP}; sparse::Bool=true)
    transmats = POMDPModelTools.transition_matrix_a_s_sp(m)
    if !sparse
        transmats = [convert(Matrix, t) for t in transmats]
    end
    mtype = typeof(first(transmats))
    oa = ordered_actions(m)
    return Dict{actiontype(m), mtype}(oa[ai]=>transmats[ai] for ai in 1:length(actions(m)))
end

"""
    reward_vectors(m::Union{MDP, POMDP})

Construct reward vectors for (PO)MDP m.

The returned object is an associative object (usually a Dict), where the keys are actions. Each value in this object is an AbstractVector where the index corresponds to the state index of s and the entry is the reward for that state.
"""
function reward_vectors(m::Union{MDP,POMDP})
    d = Dict{actiontype(m), Vector{Float64}}()
    r = StateActionReward(m)
    for a in actions(m)
        rv = zeros(length(states(m)))
        for s in states(m)
            rv[stateindex(m, s)] = r(s, a)
        end
        d[a] = rv
    end
    return d
end
