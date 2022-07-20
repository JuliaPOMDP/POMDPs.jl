"""
    has_consistent_distributions(m::Union)

Return true if no problems are found in the distributions for a discrete problem. Print information and return false if problems are found.

Tests whether
- All probabilities are positive
- Probabilities for all distributions sum to 1
- All items with positive probability are in the support
"""
function has_consistent_distributions end

function has_consistent_distributions(m::POMDP)
    return has_consistent_initial_distribution(m) &&
        has_consistent_transition_distributions(m) &&
        has_consistent_observation_distributions(m)
end

function has_consistent_distributions(m::MDP)
    return has_consistent_initial_distribution(m) &&
        has_consistent_transition_distributions(m)
end

"""
    has_consistent_transition_distributions(m)

Return true if no problems are found in the transition distributions for a discrete problem. Print information and return false if problems are found.

See `has_consistent_distributions` for information on what checks are performed.
"""
function has_consistent_transition_distributions(m::Union{MDP,POMDP})
    ok = true
    for s in states(m)
        if !isterminal(m, s)
            for a in actions(m)
                d = transition(m, s, a)
                psum = 0.0
                sup = Set(support(d))
                for sp in sup
                    if pdf(d, sp) > 0.0 && !(sp in states(m))
                        @warn "sp in support(transition(m, s, a)), but not in states(m)" s a sp
                        ok = false
                    end
                end
                for sp in states(m) 
                    p = pdf(d, sp)
                    if p < 0.0
                        @warn "Transition probability negative ($p < 0.0)." s a sp
                        ok = false
                    elseif p > 0.0 && !(sp in sup)
                        @warn "State $sp with probability $p is not in support" s a
                        ok = false
                    end
                    psum += p
                end
                if !isapprox(psum, 1.0)
                    @warn "Transition probabilities sum to $psum, not 1." s a
                    ok = false
                end
            end
        end
    end
    return ok
end

"""
    has_consistent_observation_distributions(m)

Return true if no problems are found in the observation distributions for a discrete POMDP. Print information and return false if problems are found.

See `has_consistent_distributions` for information on what checks are performed.
"""
function has_consistent_observation_distributions(m::POMDP)
    ok = true
    for s in states(m)
        if !isterminal(m, s)
            for a in actions(m)
                for sp in states(m)
                    obs = observation(m, s, a, sp)
                    psum = 0.0
                    sup = Set(support(obs))
                    for o in sup
                        if pdf(obs, o) > 0.0 && !(o in observations(m))
                            @warn "o in support(observation(m, s, a, sp)), but not in observations(m)" s a sp o
                            ok = false
                        end
                    end
                    for o in observations(m)
                        p = pdf(obs, o)
                        if p < 0.0
                            @warn "Observation probability negative ($p < 0.0)." s a sp o
                            ok = false
                        elseif p > 0.0 && !(o in sup)
                            @warn "Observation $o with probability $p is not in support." s a sp
                            ok = false
                        end
                        psum += p
                    end
                    if !isapprox(psum, 1.0)
                        @warn "Observation probabilities sum to $psum, not 1." s a sp
                        ok = false
                    end
                end
            end
        end
    end
    return ok
end

"""
    has_consistent_initial_distribution(m)

Return true if no problems are found with the initial state distribution for a discrete problem. Print information and return false if problems are found.

See `has_consistent_distributions` for information on what checks are performed.
"""
function has_consistent_initial_distribution(m::Union{MDP,POMDP})
    ok = true
    d = initialstate(m)
    sup = Set(support(d))
    psum = 0.0
    for s in states(m)
        p = pdf(d, s)
        psum += p
        if p < 0.0
            @warn "Initial state probability negative ($p < 0.0)" s
            ok = false
        elseif p > 0.0 && !(s in sup)
            @warn "State $s with probability $p is not in initial distribution support."
            ok = false
        end
    end
    if !isapprox(psum, 1.0)
        @warn "Initial state probabilities sum to $psum, not 1."
        ok = false
    end
    return ok
end

"""
   probability_check(pomdp::POMDP)
Checks if the transition and observation function of the discrete `pomdp`
have probability mass that sums up to unity for all state-action pairs.
"""
function probability_check(pomdp::POMDP)
    @warn "probability_check(m) is deprecated. Use @test has_consistent_distributions(m) instead."
    obs_prob_consistency_check(pomdp)
    trans_prob_consistency_check(pomdp)
end

"""
    obs_prob_consistency_check(pomdp::POMDP)
Checks if the observation function of the discrete `pomdp`
has probability mass that sums up to unity for all state-action pairs.
"""
function obs_prob_consistency_check(pomdp::POMDP)
    @warn "obs_prob_consistency_check(m) is deprecated. Use @test has_consistent_observation_distributions(m) instead."
    # initalize space
    sspace = states(pomdp)
    aspace = actions(pomdp)
    ospace = observations(pomdp)
    # iterate through all s-a pairs
    for s in sspace
        for a in aspace
            obs = observation(pomdp, a, s)
            psum = 0.0
            for o in ospace
                p = pdf(obs, o)
                @assert p ≥ 0 "Probability is negative for state: $s, action: $a, observation: $o"
                psum += p
            end
            @assert isapprox(psum, 1.0) "Observation probability does not sum to unity for state: $s, action: $a"
        end
    end
end

"""
    trans_prob_consistency_check(pomdp::Union{MDP, POMDP})
Checks if the transition function of the discrete problem
has probability mass that sums up to unity for all state-action pairs.
"""
function trans_prob_consistency_check(pomdp::Union{MDP, POMDP})
    @warn "trans_prob_consistency_check(m) is deprecated. Use @test has_consistent_transition_distributions(m) instead."
    # initalize space
    sspace = states(pomdp)
    aspace = actions(pomdp)
    # iterate through all s-a pairs
    for s in sspace
        for a in aspace
            tran = transition(pomdp, s, a)
            psum = 0.0
            for sp in sspace
                p = pdf(tran, sp)
                @assert p ≥ 0 "Probability is negative for state: $s, action: $a, next state: $sp"
                psum += p
            end
            @assert isapprox(psum, 1.0) "Transition probability does not sum to unity for state: $s, action: $a"
        end
    end
end
