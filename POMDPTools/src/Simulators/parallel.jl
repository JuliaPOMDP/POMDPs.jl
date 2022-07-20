"""
    Sim(m::MDP, p::Policy[, initialstate]; kwargs...)
    Sim(m::POMDP, p::Policy[, updater[, initial_belief[, initialstate]]]; kwargs...)

Create a Sim object that contains everything needed to run and record a single simulation, including model, initial conditions, and metadata.

A vector of `Sim` objects can be executed with [`run`](@ref) or [`run_parallel`](@ref).

## Keyword Arguments
- `rng::AbstractRNG=Random.GLOBAL_RNG`
- `max_steps::Int=typemax(Int)`
- `simulator::Simulator=HistoryRecorder(rng=rng, max_steps=max_steps)`
- `metadata::NamedTuple a named tuple (or dictionary) of metadata for the sim that will be recorded, e.g. `(solver_iterations=500,)`.
"""
abstract type Sim end

struct POMDPSim <: Sim
    simulator::Simulator
    pomdp::POMDP
    policy::Policy
    updater::Updater
    initial_belief::Any
    initialstate::Any
    metadata::NamedTuple
end

problem(sim::POMDPSim) = sim.pomdp

struct MDPSim <: Sim
    simulator::Simulator
    mdp::MDP
    policy::Policy
    initialstate::Any
    metadata::NamedTuple
end

problem(sim::MDPSim) = sim.mdp

"""
    Sim(m::POMDP, p::Policy, metadata=(note="a note",))
    Sim(m::POMDP, p::Policy[, updater[, initial_belief[, initialstate]]]; kwargs...)

Create a `Sim` object that represents a POMDP simulation.
"""
function Sim(pomdp::POMDP,
             policy::Policy,
             up=updater(policy),
             initial_belief=initialstate(pomdp),
             initialstate=nothing;
             rng::AbstractRNG=Random.GLOBAL_RNG,
             max_steps::Int=typemax(Int),
             simulator::Simulator=HistoryRecorder(rng=rng, max_steps=max_steps),
             metadata = NamedTuple()
            )

    if initialstate == nothing && statetype(pomdp) != Nothing
        is = rand(rng, initial_belief)
    else
        is = initialstate
    end
    return POMDPSim(simulator, pomdp, policy, up, initial_belief, is, merge(NamedTuple(), metadata))
end

"""
    Sim(m::MDP, p::Policy, metadata=(note="a note",))
    Sim(m::MDP, p::Policy[, initialstate]; kwargs...)

Create a `Sim` object that represents a MDP simulation.
"""
function Sim(mdp::MDP,
             policy::Policy,
             initialstate=nothing;
             rng::AbstractRNG=Random.GLOBAL_RNG,
             max_steps::Int=typemax(Int),
             simulator::Simulator=HistoryRecorder(rng=rng, max_steps=max_steps),
             metadata = NamedTuple()
            )

    if initialstate == nothing && statetype(mdp) != Nothing
        is = rand(rng, POMDPs.initialstate(mdp))
    else
        is = initialstate
    end
    return MDPSim(simulator, mdp, policy, is, merge(NamedTuple(), metadata))
end

POMDPs.simulate(s::POMDPSim) = simulate(s.simulator, s.pomdp, s.policy, s.updater, s.initial_belief, s.initialstate)
POMDPs.simulate(s::MDPSim) = simulate(s.simulator, s.mdp, s.policy, s.initialstate)

default_process(s::Sim, r::Real) = (reward=r,)
default_process(s::Sim, hist::SimHistory) = default_process(s, discounted_reward(hist))

run_parallel(queue::AbstractVector; kwargs...) = run_parallel(default_process, queue; kwargs...)

"""
    run_parallel(queue::Vector{Sim})
    run_parallel(f::Function, queue::Vector{Sim})

Run `Sim` objects in `queue` in parallel and return results as a `DataFrame`.

By default, the `DataFrame` will contain the reward for each simulation and the metadata provided to the sim.

# Arguments
- `queue`: List of `Sim` objects to be executed
- `f`: Function to process the results of each simulation
This function should take two arguments, (1) the `Sim` that was executed and (2) the result of the simulation, by default a `SimHistory`. It should return a named tuple that will appear in the dataframe. See Examples below.

## Keyword Arguments
- `show_progress::Bool`: whether or not to show a progress meter
- `progress::ProgressMeter.Progress`: determines how the progress meter is displayed

# Examples

```julia
run_parallel(queue) do sim, hist
    return (n_steps=n_steps(hist), reward=discounted_reward(hist))
end
```
will return a dataframe with with the number of steps and the reward in it.
"""
function run_parallel(process::Function, queue::AbstractVector, pool::AbstractWorkerPool=default_worker_pool();
                      progress=Progress(length(queue), desc="Simulating..."),
                      proc_warn::Bool=true, show_progress::Bool=true)

    if nworkers(pool) == 1 && proc_warn
        @warn("""
             run_parallel(...) was started with only 1 worker in the pool, so simulations will be run in serial.

             To supress this warning, use run_parallel(..., proc_warn=false).

             To use multiple processes, use addprocs() or the -p option (e.g. julia -p 4) and make sure the correct worker pool is assigned to argument `pool` in the call to run_parallel.
             """)
    end
    
    if progress in (nothing, false)
        progstr = (progress == nothing) ? "nothing" : "false"
        @warn("run_parallel(..., progress=$progstr) is deprecated. Use run_parallel(..., show_progress=false) instead.")
        show_progress = false
    end

    map_function(args...) = (show_progress ?
                             progress_pmap(args..., progress=progress) : pmap(args...))

    frame_lines = map_function(pool, queue) do sim
        result = simulate(sim)
        output = process(sim, result)
        return merge(sim.metadata, output)
    end

    return create_dataframe(frame_lines)
end

Base.run(queue::AbstractVector) = run(default_process, queue)

"""
    run(queue::Vector{Sim})
    run(f::Function, queue::Vector{Sim})

Run the `Sim` objects in `queue` on a single process and return the results as a dataframe.

See `run_parallel` for more information.
"""
function Base.run(process::Function, queue::AbstractVector; show_progress=true)
    lines = []
    if show_progress
        @showprogress for sim in queue
            result = simulate(sim)
            output = process(sim, result)
            line = merge(sim.metadata, output)
            push!(lines, line)
        end
    else
        for sim in queue
            result = simulate(sim)
            output = process(sim, result)
            line = merge(sim.metadata, output)
            push!(lines, line)
        end
    end
    return create_dataframe(lines)
end

function create_dataframe(lines::Vector)
    master = Dict{Symbol, AbstractVector}()
    for line in lines
        push_line!(master, line)
    end
    return DataFrame(master)
end

function push_line!(d::Dict{Symbol, AbstractVector}, line::NamedTuple)
    if isempty(d)
        len = 0
    else
        len = length(first(values(d)))
    end
    for (key, val) in pairs(line)
        T = typeof(val)
        if !haskey(d, key)
            d[key] = Vector{Union{T,Missing}}(missing, len)
        end
        data = d[key]
        if !isa(val,eltype(data))
            d[key] = convert(Array{promote_type(typeof(val), eltype(data)),1}, data)
        end
        push!(d[key], val)
    end
    for da in values(d)
        if length(da) < len + 1
            push!(da, missing)
        end
    end
    return d
end
