# HistoryRecorder
# maintained by @zsunberg

"""
A simulator that records the history for later examination

The simulation will be terminated when either
1) a terminal state is reached (as determined by `isterminal()` or
2) the discount factor is as small as `eps` or
3) max_steps have been executed

Keyword Arguments:
    - `rng`: The random number generator for the simulation
    - `capture_exception::Bool`: whether to capture an exception and store it in the history, or let it go uncaught, potentially killing the script
    - `show_progress::Bool`: show a progress bar for the simulation
    - `eps`
    - `max_steps`

Usage (optional arguments in brackets):

    hr = HistoryRecorder()
    history = simulate(hr, pomdp, policy, [updater [, init_belief [, init_state]]])
"""
mutable struct HistoryRecorder <: Simulator
    rng::AbstractRNG

    # options
    capture_exception::Bool
    show_progress::Bool

    # optional: if these are null, they will be ignored
    max_steps::Union{Nothing,Any}
    eps::Union{Nothing,Any}
end

# This is the only stable constructor
function HistoryRecorder(;rng=Random.GLOBAL_RNG,
                          eps=nothing,
                          max_steps=nothing,
                          capture_exception=false,
                          show_progress=false)
    return HistoryRecorder(rng, capture_exception, show_progress, max_steps, eps)
end

@POMDP_require simulate(sim::HistoryRecorder, pomdp::POMDP, policy::Policy) begin
    @req updater(::typeof(policy))
    up = updater(policy)
    @subreq simulate(sim, pomdp, policy, up)
end

@POMDP_require simulate(sim::HistoryRecorder, pomdp::POMDP, policy::Policy, bu::Updater) begin
    @req initialstate(::typeof(pomdp))
    dist = initialstate(pomdp)
    @subreq simulate(sim, pomdp, policy, bu, dist)
end

function simulate(sim::HistoryRecorder, pomdp::POMDP, policy::Policy, bu::Updater=updater(policy))
    dist = initialstate(pomdp)
    return simulate(sim, pomdp, policy, bu, dist)
end

@POMDP_require simulate(sim::HistoryRecorder, pomdp::POMDP, policy::Policy, bu::Updater, dist::Any) begin
    P = typeof(pomdp)
    S = statetype(pomdp)
    A = actiontype(pomdp)
    O = obstype(pomdp)
    @req initialize_belief(::typeof(bu), ::typeof(dist))
    @req isterminal(::P, ::S)
    @req discount(::P)
    @req gen(::P, ::S, ::A, ::typeof(sim.rng))
    b = initialize_belief(bu, dist)
    B = typeof(b)
    @req action(::typeof(policy), ::B)
    @req update(::typeof(bu), ::B, ::A, ::O)
end

function simulate(sim::HistoryRecorder,
                           pomdp::POMDP{S,A,O}, 
                           policy::Policy,
                           bu::Updater,
                           initialstate_dist::Any,
                           is::Any=rand(sim.rng, initialstate(pomdp))
                  ) where {S,A,O}

    initial_belief = initialize_belief(bu, initialstate_dist)
    max_steps = something(sim.max_steps, typemax(Int))
    if sim.eps != nothing
        max_steps = min(max_steps, ceil(Int,log(sim.eps)/log(discount(pomdp))))
    end
    
    if sim.show_progress
        if (sim.max_steps == nothing) && (sim.eps == nothing)
            error("If show_progress=true in a HistoryRecorder, you must also specify max_steps or eps.")
        end
        prog = Progress(max_steps, "Simulating..." )
    else
        prog = nothing
    end

    it = POMDPSimIterator(default_spec(pomdp),
                          pomdp,
                          policy,
                          bu,
                          sim.rng,
                          initial_belief,
                          is,
                          max_steps)

    history, exception, backtrace = collect_history(it, Val(sim.capture_exception), prog)

    if sim.show_progress
        finish!(prog)
    end

    return SimHistory(promote_history(history), discount(pomdp), exception, backtrace)
end

@POMDP_require simulate(sim::HistoryRecorder, mdp::MDP, policy::Policy) begin
    init_state = rand(sim.rng, initialstate(mdp))
    @subreq simulate(sim, mdp, policy, init_state)
end

@POMDP_require simulate(sim::HistoryRecorder, mdp::MDP, policy::Policy, initialstate::Any) begin
    P = typeof(mdp)
    S = statetype(mdp)
    A = actiontype(mdp)
    @req isterminal(::P, ::S)
    @req action(::typeof(policy), ::S)
    @req gen(::P, ::S, ::A, ::typeof(sim.rng))
    @req discount(::P)
end

function simulate(sim::HistoryRecorder,
                  mdp::MDP{S,A}, policy::Policy,
                  init_state::S=rand(sim.rng, initialstate(mdp))) where {S,A}
    
    max_steps = something(sim.max_steps, typemax(Int))
    if sim.eps != nothing
        max_steps = min(max_steps, ceil(Int,log(sim.eps)/log(discount(mdp))))
    end

    it = MDPSimIterator(default_spec(mdp),
                        mdp,
                        policy,
                        sim.rng,
                        init_state,
                        max_steps)

    if sim.show_progress
        if (sim.max_steps == nothing) && (sim.eps == nothing)
            error("If show_progress=true in a HistoryRecorder, you must also specify max_steps or eps.")
        end
        prog = Progress(max_steps, "Simulating..." )
    else
        prog = nothing
    end
    
    history, exception, backtrace = collect_history(it, Val(sim.capture_exception), prog)

    if sim.show_progress
        finish!(prog)
    end

    return SimHistory(promote_history(history), discount(mdp), exception, backtrace)
end

function collect_history(it, cap_ex::Val{true}, prog::Union{Progress,Nothing})
    exception = nothing
    backtrace = nothing
    history = NamedTuple[] # capturing part of the history is more important than this having a concrete type
    try
        for step in it
            push!(history, step)
            if prog !== nothing
                next!(prog)
            end
        end
    catch ex
        exception = ex
        backtrace = catch_backtrace()
    end
    return history, exception, backtrace
end

collect_history(it, cap_ex::Val{false}, prog::Nothing) = collect(it), nothing, nothing
function collect_history(it, cap_ex::Val{false}, prog::Progress)
    h = collect(begin
                    next!(prog)
                    step
                end for step in it)
    return h, nothing, nothing
end

"""
Promotes all NamedTuples in the history to the same type.
"""
function promote_history(hist::AbstractVector)
    if isconcretetype(eltype(hist))
        return hist
    elseif isempty(hist) # note, from above, also does not have concrete type
        return NamedTuple{(), Tuple{}}[]
    else
        # it would really astound me if this branch was type stable
        names = fieldnames(first(hist))
        types = fieldtypes(first(hist))
        for step in hist
            @assert fieldnames(step) == names
            types = map(promote_type, types, fieldtypes(step))
        end
        newtype = NamedTuple{names, Tuple{types...}}
        return convert(Vector{newtype}, hist)
    end
end
