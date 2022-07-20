# RolloutSimulator
# maintained by @zsunberg

"""
    RolloutSimulator(rng, max_steps)
    RolloutSimulator(; <keyword arguments>)

A fast simulator that just returns the reward

The simulation will be terminated when either
1) a terminal state is reached (as determined by `isterminal()` or
2) the discount factor is as small as `eps` or
3) max_steps have been executed

# Keyword arguments:
- rng: A random number generator to use.
- eps: A small number; if γᵗ where γ is the discount factor and t is the time step becomes smaller than this, the simulation will be terminated.
- max_steps: The maximum number of steps to simulate.

# Usage (optional arguments in brackets):

    ro = RolloutSimulator()
    history = simulate(ro, pomdp, policy, [updater [, init_belief [, init_state]]])

See also: [`HistoryRecorder`](@ref), [`run_parallel`](@ref)
"""
struct RolloutSimulator{RNG<:AbstractRNG} <: Simulator
    rng::RNG

    # optional: if these are null, they will be ignored
    max_steps::Union{Nothing,Int}
    eps::Union{Nothing,Float64}
end

RolloutSimulator(rng::AbstractRNG, d::Int=typemax(Int)) = RolloutSimulator(rng, d, nothing)
function RolloutSimulator(;rng=Random.GLOBAL_RNG,
                           eps=nothing,
                           max_steps=nothing)
    return RolloutSimulator{typeof(rng)}(rng, max_steps, eps)
end


@POMDP_require simulate(sim::RolloutSimulator, pomdp::POMDP, policy::Policy) begin
    @req updater(::typeof(policy))
    bu = updater(policy)
    @subreq simulate(sim, pomdp, policy, bu)
end

@POMDP_require simulate(sim::RolloutSimulator, pomdp::POMDP, policy::Policy, bu::Updater) begin
    @req initialstate(::typeof(pomdp))
    dist = initialstate(pomdp)
    @subreq simulate(sim, pomdp, policy, bu, dist)
end

function simulate(sim::RolloutSimulator, pomdp::POMDP, policy::Policy, bu::Updater=updater(policy))
    dist = initialstate(pomdp)
    return simulate(sim, pomdp, policy, bu, dist)
end


@POMDP_require simulate(sim::RolloutSimulator, pomdp::POMDP, policy::Policy, updater::Updater, initial_belief) begin
    @req rand(::typeof(sim.rng), ::typeof(initial_belief))
    @subreq simulate(sim, pomdp, policy, updater, initial_belief, s)
end

function simulate(sim::RolloutSimulator, pomdp::POMDP{S}, policy::Policy, updater::Updater, initial_belief) where {S}
    s = rand(sim.rng, initial_belief)::S
    return simulate(sim, pomdp, policy, updater, initial_belief, s)
end

@POMDP_require simulate(sim::RolloutSimulator, pomdp::POMDP, policy::Policy, updater::Updater, initial_belief, s) begin
    P = typeof(pomdp)
    S = statetype(P)
    A = actiontype(P)
    O = obstype(P)
    @req initialize_belief(::typeof(updater), ::typeof(initial_belief))
    @req isterminal(::P, ::S)
    @req discount(::P)
    @req gen(::P, ::S, ::A, ::typeof(sim.rng))
    b = initialize_belief(updater, initial_belief)
    @req action(::typeof(policy), ::typeof(b))
    @req update(::typeof(updater), ::typeof(b), ::A, ::O)
end

function simulate(sim::RolloutSimulator, pomdp::POMDP, policy::Policy, updater::Updater, initial_belief, s)
    
    if sim.eps == nothing
        eps = 0.0
    else
        eps = sim.eps
    end
    
    if sim.max_steps == nothing
        max_steps = typemax(Int)
    else
        max_steps = sim.max_steps
    end

    disc = 1.0
    r_total = 0.0

    b = initialize_belief(updater, initial_belief)

    step = 1

    while disc > eps && !isterminal(pomdp, s) && step <= max_steps

        a = action(policy, b)

        sp, o, r = @gen(:sp,:o,:r)(pomdp, s, a, sim.rng)

        r_total += disc*r

        s = sp

        bp = update(updater, b, a, o)
        b = bp

        disc *= discount(pomdp)
        step += 1
    end

    return r_total
end

@POMDP_require simulate(sim::RolloutSimulator, mdp::MDP, policy::Policy) begin
    istate = initialstate(mdp, sim.rng)
    @subreq simulate(sim, mdp, policy, istate)
end

@POMDP_require simulate(sim::RolloutSimulator, mdp::MDP, policy::Policy, initialstate) begin
    P = typeof(mdp)
    S = typeof(initialstate)
    A = actiontype(mdp)
    @req isterminal(::P, ::S)
    @req action(::typeof(policy), ::S)
    @req gen(::P, ::S, ::A, ::typeof(sim.rng))
    @req discount(::P)
end

function simulate(sim::RolloutSimulator, mdp::MDP, policy::Policy)
    istate = rand(sim.rng, initialstate(mdp))
    simulate(sim, mdp, policy, istate)
end

function simulate(sim::RolloutSimulator, mdp::MDP{S}, policy::Policy, initialstate::S) where {S}
    
    if sim.eps == nothing
        eps = 0.0
    else
        eps = sim.eps
    end
    
    if sim.max_steps == nothing
        max_steps = typemax(Int)
    else
        max_steps = sim.max_steps
    end

    s = initialstate

    disc = 1.0
    r_total = 0.0
    step = 1

    while disc > eps && !isterminal(mdp, s) && step <= max_steps
        a = action(policy, s)

        sp, r = @gen(:sp,:r)(mdp, s, a, sim.rng)

        r_total += disc*r

        s = sp

        disc *= discount(mdp)
        step += 1
    end

    return r_total
end

function simulate(sim::RolloutSimulator, m::POMDP{S}, policy::Policy, initialstate::S) where {S}
    simulate(sim, UnderlyingMDP(m), policy, initialstate)
end

simulate(sim::RolloutSimulator, m::MDP, p::Policy, is) = simulate(sim, m, p, convert(statetype(m), is))
