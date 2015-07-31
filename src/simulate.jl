using Debug
"""
Return the reward for a single simulation of the pomdp.

The simulation will be terminated when either
1) a terminal state is reached (as determined by `isterminal()` or
2) the discount factor is as small as `eps`.

if initial_state is not supplied, it will be sampled from belief
"""
function simulate(pomdp::POMDP,
                  policy::Policy,
                  initial_belief::Belief;
                  rng=MersenneTwister(rand(Uint32)),
                  eps=0.0,
                  initial_state=nothing)

    if initial_state == nothing
        initial_state = create_state(pomdp)
        rand!(rng, initial_state, initial_belief)
    end

    disc = 1.0
    r = 0.0
    s = deepcopy(initial_state)
    b = deepcopy(initial_belief)

    obs_dist = create_observation_distribution(pomdp)
    trans_dist = create_transition_distribution(pomdp)
    sp = create_state(pomdp)
    o = create_observation(pomdp)

    while disc > eps && !isterminal(s)
        a = action(policy, b)
        r += disc*reward(pomdp, s, a)

        transition!(trans_dist, pomdp, s, a)
        rand!(rng, sp, trans_dist)

        observation!(obs_dist, pomdp, sp, a)
        rand!(rng, o, obs_dist)

        # alternates using the memory allocated for s and sp so nothing new has to be allocated
        tmp = s
        s = sp
        sp = tmp

        update_belief!(b, pomdp, a, o)

        disc*=discount(pomdp)
    end

    return r
end
