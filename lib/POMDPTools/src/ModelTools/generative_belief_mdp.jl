"""
    GenerativeBeliefMDP(pomdp, updater)

Create a generative model of the belief MDP corresponding to POMDP `pomdp` with belief updates performed by `updater`.
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

const warned_about_gbmdp_terminal=false

# override this if you want to handle it in a special way
function gbmdp_handle_terminal(pomdp::POMDP, updater::Updater, b, s, a, rng)
    global warned_about_gbmdp_terminal
    if !warned_about_gbmdp_terminal
        @warn("""
             Sampled a terminal state for a GenerativeBeliefMDP transition - not sure how to proceed, but will try.

             See $(@__FILE__) and implement a new method of POMDPToolbox.gbmdp_handle_terminal if you want special behavior in this case.

             """)
        warned_about_gbmdp_terminal = true
    end
    sp, o, r = @gen(:sp, :o, :r)(pomdp, s, a, rng)
    bp = update(updater, b, a, o)
    return bp
end

function initialstate(bmdp::GenerativeBeliefMDP)
    return Deterministic(initialize_belief(bmdp.updater, initialstate_distribution(bmdp.pomdp)))
end

# deprecated in POMDPs v0.9
function initialstate(bmdp::GenerativeBeliefMDP, rng::AbstractRNG)
    return initialize_belief(bmdp.updater, initialstate_distribution(bmdp.pomdp))
end
