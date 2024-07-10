"""
    GenerativeBeliefMDP(pomdp, updater)
    GenerativeBeliefMDP(pomdp, updater, terminal_behavior)

Create a generative model of the belief MDP corresponding to POMDP `pomdp` with belief updates performed by `updater`.
"""
struct GenerativeBeliefMDP{P<:POMDP, U<:Updater, T, B, A} <: MDP{B, A}
    pomdp::P
    updater::U
    terminal_behavior::T
end

function GenerativeBeliefMDP(pomdp, updater; terminal_behavior=DefaultGBMDPTerminalBehavior(pomdp, updater))
    B = determine_gbmdp_state_type(pomdp, updater, terminal_behavior)
    GenerativeBeliefMDP{typeof(pomdp),
                        typeof(updater),
                        typeof(terminal_behavior),
                        B,
                        actiontype(pomdp)
                       }(pomdp, updater, terminal_behavior)
end

function initialstate(bmdp::GenerativeBeliefMDP)
    return Deterministic(initialize_belief(bmdp.updater, initialstate(bmdp.pomdp)))
end

function POMDPs.gen(bmdp::GenerativeBeliefMDP, b, a, rng::AbstractRNG)
    s = rand(rng, b)
    if isterminal(bmdp.pomdp, s)
        bp = bmdp.terminal_behavior(b, s, a, rng)
        return (sp=bp, r=0.0)
    end
    o, r = @gen(:o, :r)(bmdp.pomdp, s, a, rng)
    bp = update(bmdp.updater, b, a, o)
    return (sp=bp, r=r)
end

actions(bmdp::GenerativeBeliefMDP{P,U,B,A}, b::B) where {P,U,B,A} = actions(bmdp.pomdp, b)
actions(bmdp::GenerativeBeliefMDP) = actions(bmdp.pomdp)

isterminal(bmdp::GenerativeBeliefMDP, b) = all(s -> isterminal(bmdp.pomdp, s) || pdf(b, s) == 0.0, support(b))
isterminal(bmdp::GenerativeBeliefMDP, ts::TerminalState) = true

discount(bmdp::GenerativeBeliefMDP) = discount(bmdp.pomdp)

function determine_gbmdp_state_type(pomdp, updater)
    b0 = initialize_belief(updater, initialstate(pomdp))
    return typeof(b0)
end

determine_gbmdp_state_type(pomdp, updater, terminal_behavior) = determine_gbmdp_state_type(pomdp, updater)

struct DefaultGBMDPTerminalBehavior{M, U}
    pomdp::M
    updater::U
end

function (tb::DefaultGBMDPTerminalBehavior)(b, s, a, rng)

    # This code block is only to handle backwards compatibility for the deprecated gbmdp_handle_terminal function
    bp = gbmdp_handle_terminal(tb.pomdp, tb.updater, b, s, a, rng)
    if bp != nothing # user has implemented gbmdp_handle_terminal
        Base.depwarn("Using gbmdp_handle_terminal to specify terminal behavior for a GenerativeBeliefMDP is deprecated. Use the terminal_behavior keyword argument instead.", :gbmdp_handle_terminal)
        return bp
    end

    return TerminalStateTerminalBehavior()(b, s, a, rng)
end

determine_gbmdp_state_type(pomdp, updater, tb::DefaultGBMDPTerminalBehavior) = determine_gbmdp_state_type(pomdp, updater, TerminalStateTerminalBehavior())

struct ContinueTerminalBehavior{M, U}
    pomdp::M
    updater::U
end

function (tb::ContinueTerminalBehavior)(b, s, a, rng)
    o, r = @gen(:o, :r)(tb.pomdp, s, a, rng)
    return update(tb.updater, b, a, o)
end

struct TerminalStateTerminalBehavior end
(tb::TerminalStateTerminalBehavior)(args...) = terminalstate
determine_gbmdp_state_type(pomdp, updater, tb::TerminalStateTerminalBehavior) = promote_type(determine_gbmdp_state_type(pomdp, updater), TerminalState)
