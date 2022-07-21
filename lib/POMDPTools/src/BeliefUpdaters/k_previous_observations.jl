"""
    KMarkovUpdater
    
Updater that stores the k most recent observations as the belief.

Example:

```julia
up = KMarkovUpdater(5)
s0 = rand(rng, initialstate(pomdp))
initial_observation = rand(rng, initialobs(pomdp, s0))
initial_obs_vec = fill(initial_observation, 5)
hr = HistoryRecorder(rng=rng, max_steps=100)
hist = simulate(hr, pomdp, policy, up, initial_obs_vec, s0)
```
"""
struct KMarkovUpdater <: Updater
    k::Int
end

# this is a new type because `history(::AbstractVector)` and `currentobs(::AbstractVector)` are too broad
struct PreviousObservations{K,O} <: AbstractVector{O}
    storage::NTuple{K,O}
end

PreviousObservations(v::AbstractVector) = PreviousObservations(tuple(v...))

Base.size(::PreviousObservations{K}) where {K} = (K,)
Base.getindex(p::PreviousObservations, i::Int) = p.storage[i]
POMDPs.history(p::PreviousObservations) = collect((o=obs,) for obs in p)
POMDPs.currentobs(p::PreviousObservations) = p[end]

function initialize_belief(bu::KMarkovUpdater, obs_vec::AbstractVector)
    if length(obs_vec) != bu.k
        error("KMarkovUpdater: The length of the initial observation vector
               does not match the number of observation to stack\n"*throw_example(bu))
    end
    return PreviousObservations(obs_vec)
end

function update(bu::KMarkovUpdater, old_b::AbstractVector{O}, action, obs) where {O}
    if !isa(obs, O)
        error("KMarkovUpdater: Observation did not match previous observation type.\n"*throw_example(bu))
    end
    return PreviousObservations((old_b[end-(bu.k-2):end]..., obs))
end

function initialize_belief(bu::KMarkovUpdater, obs_vec)
    error("KMarkovUpdater: To initialize the belief, pass in a vector of observation.\n"*throw_example(bu))
end

function throw_example(bu::KMarkovUpdater)
    example = """
    Did you forget to pass the initial observation to the simulator?
    Example:
    ```julia
    up = KMarkovUpdater(5)
    s0 = rand(rng, initialstate(pomdp))
    initial_observation = rand(rng, initialobs(pomdp, s0))
    initial_obs_vec = fill(initial_observation, 5)
    hr = HistoryRecorder(rng=rng, max_steps=100)
    hist = simulate(hr, pomdp, policy, up, initial_obs_vec, s0)
    ```
    """
    return example
end
