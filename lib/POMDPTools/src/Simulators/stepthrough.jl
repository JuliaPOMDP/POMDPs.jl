# StepSimulator
# maintained by @zsunberg

struct StepSimulator <: Simulator
    rng::AbstractRNG
    max_steps::Union{Nothing,Any}
    spec
end
function StepSimulator(spec; rng=Random.GLOBAL_RNG, max_steps=nothing)
    return StepSimulator(rng, max_steps, spec)
end

function simulate(sim::StepSimulator, mdp::MDP{S}, policy::Policy, init_state::S=rand(sim.rng, initialstate(mdp))) where {S}
    symtuple = convert_spec(sim.spec, typeof(mdp))
    max_steps = something(sim.max_steps, typemax(Int64))
    return MDPSimIterator(symtuple, mdp, policy, sim.rng, init_state, max_steps)
end

function simulate(sim::StepSimulator, pomdp::POMDP, policy::Policy, bu::Updater=updater(policy))
    dist = initialstate(pomdp)    
    return simulate(sim, pomdp, policy, bu, dist)
end

function simulate(sim::StepSimulator, pomdp::POMDP, policy::Policy, bu::Updater, dist::Any, is=rand(sim.rng, initialstate(pomdp)))
    initial_belief = initialize_belief(bu, dist)
    symtuple = convert_spec(sim.spec, typeof(pomdp))
    max_steps = something(sim.max_steps, typemax(Int64))
    return POMDPSimIterator(symtuple, pomdp, policy, bu, sim.rng, initial_belief, is, max_steps)
end

struct MDPSimIterator{SPEC, M<:MDP, P<:Policy, RNG<:AbstractRNG, S}
    mdp::M
    policy::P
    rng::RNG
    init_state::S
    max_steps::Int
end

function MDPSimIterator(spec::Union{Tuple, Symbol}, mdp::MDP, policy::Policy, rng::AbstractRNG, init_state, max_steps::Int) 
    return MDPSimIterator{spec, typeof(mdp), typeof(policy), typeof(rng), typeof(init_state)}(mdp, policy, rng, init_state, max_steps)
end

Base.IteratorSize(::Type{<:MDPSimIterator}) = Base.SizeUnknown()

function Base.iterate(it::MDPSimIterator, is::Tuple{Int, S}=(1, it.init_state)) where S
    if isterminal(it.mdp, is[2]) || is[1] > it.max_steps 
        return nothing 
    end 
    t = is[1]
    s = is[2]
    a, ai = action_info(it.policy, s)
    out = @gen(:sp,:r,:info)(it.mdp, s, a, it.rng)
    nt = merge(NamedTuple{(:sp,:r,:info)}(out), (t=t, s=s, a=a, action_info=ai))
    return (out_tuple(it, nt), (t+1, nt.sp))
end

struct POMDPSimIterator{SPEC, M<:POMDP, P<:Policy, U<:Updater, RNG<:AbstractRNG, B, S}
    pomdp::M
    policy::P
    updater::U
    rng::RNG
    init_belief::B
    init_state::S
    max_steps::Int
end
function POMDPSimIterator(spec::Union{Tuple,Symbol}, pomdp::POMDP, policy::Policy, up::Updater, rng::AbstractRNG, init_belief, init_state, max_steps::Int) 
    return POMDPSimIterator{spec,
                            typeof(pomdp),
                            typeof(policy),
                            typeof(up),
                            typeof(rng),
                            typeof(init_belief),
                            typeof(init_state)}(pomdp,
                                                policy,
                                                up,
                                                rng,
                                                init_belief,
                                                init_state,
                                                max_steps)
end

Base.IteratorSize(::Type{<:POMDPSimIterator}) = Base.SizeUnknown()

function Base.iterate(it::POMDPSimIterator, is::Tuple{Int,S,B} = (1, it.init_state, it.init_belief)) where {S,B}
    if isterminal(it.pomdp, is[2]) || is[1] > it.max_steps 
        return nothing 
    end 
    t = is[1]
    s = is[2]
    b = is[3]
    a, ai = action_info(it.policy, b)
    out = @gen(:sp,:o,:r,:info)(it.pomdp, s, a, it.rng)
    outnt = NamedTuple{(:sp,:o,:r,:info)}(out)
    bp, ui = update_info(it.updater, b, a, outnt.o)
    nt = merge(outnt, (t=t, b=b, s=s, a=a, action_info=ai, bp=bp, update_info=ui))
    return (out_tuple(it, nt), (t+1, nt.sp, nt.bp))
end

function out_tuple(it::Union{MDPSimIterator{spec}, POMDPSimIterator{spec}}, all::NamedTuple) where spec
    if isa(spec, Tuple)
        return NamedTupleTools.select(all, spec)
    else 
        @assert isa(spec, Symbol) "Invalid specification: $spec is not a Symbol or Tuple."
        return all[spec]
    end
end

convert_spec(spec, T::Type{M}) where {M<:POMDP} = convert_spec(spec, Set(tuple(:s, :a, :sp, :o, :r, :info, :bp, :b, :action_info, :update_info, :t)))
convert_spec(spec, T::Type{M}) where {M<:MDP} = convert_spec(spec, Set(tuple(:s, :a, :sp, :r, :info, :action_info, :t)))
function convert_spec(spec, recognized::Set{Symbol})
    conv = convert_spec(spec)
    convtpl = isa(conv, Tuple) ? conv : tuple(conv)
    for s in convtpl
        if s == :ai && !(:action_info in convtpl)
            @warn("Using :ai to access the action info in a history is deprecated. Use :action_info instead.") # XXX get rid of in v0.4 or greater
        elseif s == :ui && !(:update_info in convtpl)
            @warn("Using :ui to access the update info in a history is deprecated. Use :update_info instead.") # XXX get rid of in v0.4 or greater
        elseif !(s in recognized)
            @warn("uncrecognized symbol $s in step iteration specification $spec.")
        end
    end
    return conv
end

function convert_spec(spec::String)
    syms = spec |> x->strip(x,['(',')']) |> x->split(x,',') |> x->strip.(x) |> x->Symbol.(x)
    if length(syms) == 1
        return Symbol(first(syms))
    else
        return tuple(syms...)
    end
end

function convert_spec(spec::Tuple)
    for s in spec
        @assert isa(s, Symbol)
    end
    return spec
end

convert_spec(spec::Symbol) = spec

"""
    CompleteSpec()

Default placeholder for a complete step output specification. Will include all DDNNodes, plus all known possible outputs in each step.
"""
struct CompleteSpec end

convert_spec(::CompleteSpec, T::Type{M}) where M <: MDP = default_spec(T)
convert_spec(::CompleteSpec, T::Type{M}) where M <: POMDP = default_spec(T)

default_spec(m::Union{MDP,POMDP}) = default_spec(typeof(m))
default_spec(T::Type{M}) where M <: MDP = tuple(:s, :a, :sp, :r, :info, :t, :action_info)
default_spec(T::Type{M}) where M <: POMDP = tuple(:s, :a, :sp, :o, :r, :info, :t, :action_info, :b, :bp, :update_info)


"""
    stepthrough(problem, policy, [spec])
    stepthrough(problem, policy, [spec], [rng=rng], [max_steps=max_steps])
    stepthrough(mdp::MDP, policy::Policy, [init_state], [spec]; [kwargs...])
    stepthrough(pomdp::POMDP, policy::Policy, [up::Updater, [initial_belief, [initial_state]]], [spec]; [kwargs...])

Create a simulation iterator. This is intended to be used with for loop syntax to output the results of each step *as the simulation is being run*. 

Example:

    pomdp = BabyPOMDP()
    policy = RandomPolicy(pomdp)

    for (s, a, o, r) in stepthrough(pomdp, policy, "s,a,o,r", max_steps=10)
        println("in state \$s")
        println("took action \$o")
        println("received observation \$o and reward \$r")
    end

The optional `spec` argument can be a string, tuple of symbols, or single symbol and follows the same pattern as [`eachstep`](@ref) called on a `SimHistory` object.

Under the hood, this function creates a `StepSimulator` with `spec` and returns a `[PO]MDPSimIterator` by calling simulate with all of the arguments except `spec`. All keyword arguments are passed to the `StepSimulator` constructor.
"""
function stepthrough end # for documentation

function stepthrough(mdp::MDP,
                     policy::Policy,
                     spec::Union{String, Tuple, Symbol}=default_spec(mdp);
                     kwargs...)
    sim = StepSimulator(spec; kwargs...)
    return simulate(sim, mdp, policy)
end

function stepthrough(mdp::MDP{S},
                     policy::Policy,
                     init_state::S,
                     spec::Union{String, Tuple, Symbol}=default_spec(mdp);
                     kwargs...) where {S}
    sim = StepSimulator(spec; kwargs...)
    return simulate(sim, mdp, policy, init_state)
end

function stepthrough(pomdp::POMDP, policy::Policy, args...; kwargs...)
    spec_included=false
    if !isempty(args) && isa(last(args), Union{String, Tuple, Symbol})
        spec = last(args)
        spec_included = true
        if spec isa statetype(pomdp) && length(args) == 3
            error("Ambiguity between `initial_state` and `spec` arguments in stepthrough. Please explicitly specify the initial state and spec.")
        end
    else
        spec = default_spec(pomdp)
    end
    sim = StepSimulator(spec; kwargs...)
    return simulate(sim, pomdp, policy, args[1:end-spec_included]...)
end
