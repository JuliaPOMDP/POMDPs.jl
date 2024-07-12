"""
    GenerativeBeliefMDP(pomdp, updater)

<<<<<<< Updated upstream
Create a generative model of the belief MDP corresponding to POMDP `pomdp` with belief updates performed by `updater`.
=======
Create a generative model of the belief MDP corresponding to POMDP `pomdp` with belief updates performed by `updater`. Each step is performed by sampling a state from the current belief, generating an observation from that state and action, and then using `updater` to update the belief.

A belief is considered terminal when _all_ POMDP states in the support with nonzero probability are terminal.

The default behavior when a terminal POMDP state is sampled from the belief is to transition to [`terminalstate`](@ref). This can be controlled by the `terminal_behavior` keyword argument. Using `terminal_behavior=ContinueTerminalBehavior(pomdp, updater)` will cause the MDP to keep attempting a belief update even when the sampled state is terminal. This can be further customized by providing `terminal_behavior` with a `Function` or callable object that takes arguments `b, s, a, rng` and returns a new belief (see the implementation of `ContinueTerminalBehavior` for an example). `determine_gbmdp_state_type` can be used to further customize behavior.
>>>>>>> Stashed changes
"""
struct GenerativeBeliefMDP{P<:POMDP, U<:Updater, B, A} <: MDP{B, A}
    pomdp::P
    updater::U
end

function GenerativeBeliefMDP(pomdp::P, up::U) where {P<:POMDP, U<:Updater}
    # XXX hack to determine belief type
    b0 = initialize_belief(up, initialstate(pomdp))
    GenerativeBeliefMDP{P, U, typeof(b0), actiontype(pomdp)}(pomdp, up)
end

function POMDPs.gen(bmdp::GenerativeBeliefMDP, b, a, rng::AbstractRNG)
    s = rand(rng, b)
    if isterminal(bmdp.pomdp, s)
        bp = gbmdp_handle_terminal(bmdp.pomdp, bmdp.updater, b, s, a, rng::AbstractRNG)::typeof(b)
        return (sp=bp, r=0.0)
    end
    sp, o, r = @gen(:sp, :o, :r)(bmdp.pomdp, s, a, rng) # maybe this should have been generate_or?
    bp = update(bmdp.updater, b, a, o)
    return (sp=bp, r=r)
end

actions(bmdp::GenerativeBeliefMDP{P,U,B,A}, b::B) where {P,U,B,A} = actions(bmdp.pomdp, b)
actions(bmdp::GenerativeBeliefMDP) = actions(bmdp.pomdp)

isterminal(bmdp::GenerativeBeliefMDP, b) = all(isterminal(bmdp.pomdp, s) for s in support(b))

discount(bmdp::GenerativeBeliefMDP) = discount(bmdp.pomdp)

# override this if you want to handle it in a special way
function gbmdp_handle_terminal(pomdp::POMDP, updater::Updater, b, s, a, rng)
    @warn("""
         Sampled a terminal state for a GenerativeBeliefMDP transition - not sure how to proceed, but will try.

         See $(@__FILE__) and implement a new method of POMDPToolbox.gbmdp_handle_terminal if you want special behavior in this case.

         """, maxlog=1)
    sp, o, r = @gen(:sp, :o, :r)(pomdp, s, a, rng)
    bp = update(updater, b, a, o)
    return bp
end

function initialstate(bmdp::GenerativeBeliefMDP)
    return Deterministic(initialize_belief(bmdp.updater, initialstate(bmdp.pomdp)))
end

# deprecated in POMDPs v0.9
function initialstate(bmdp::GenerativeBeliefMDP, rng::AbstractRNG)
    return initialize_belief(bmdp.updater, initialstate(bmdp.pomdp))
end
