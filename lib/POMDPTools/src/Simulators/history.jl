# SimHistory
# maintained by @zsunberg

abstract type AbstractSimHistory{NT} <: AbstractVector{NT} end

nt_type(::Type{H}) where H<:AbstractSimHistory{NT} where NT = NT
nt_type(h::AbstractSimHistory) = nt_type(typeof(h))

"""
    SimHistory

An (PO)MDP simulation history returned by `simulate(::HistoryRecorder, ::Union{MDP,POMDP},...)`.

This is an `AbstractVector` of [`NamedTuples`](https://docs.julialang.org/en/v1/manual/types/index.html#Named-Tuple-Types-1) containing the states, actions, etc.

# Examples
```
hist[1][:s] # returns the first state in the history
```
```
hist[:a] # returns all of the actions in the history
```
"""
struct SimHistory{NT, R<:Real} <: AbstractSimHistory{NT}
    hist::Vector{NT}

    discount::R

    # if an exception is captured, it will be stored here
    exception::Union{Nothing, Exception}
    backtrace::Union{Nothing, Any}
end

# accessors: use these to access the members - in case the implementation changes
n_steps(h::SimHistory) = length(h.hist)
hist(h::SimHistory) = h.hist

state_hist(h::AbstractSimHistory) = push!([step.s for step in hist(h)], last(hist(h)).sp)
action_hist(h::AbstractSimHistory) = h[:a]
observation_hist(h::AbstractSimHistory) = h[:o]
belief_hist(h::AbstractSimHistory) = push!([step.b for step in hist(h)], last(hist(h)).bp)
reward_hist(h::AbstractSimHistory) = h[:r]
info_hist(h::AbstractSimHistory) = h[:i]
ainfo_hist(h::AbstractSimHistory) = h[:action_info]
uinfo_hist(h::AbstractSimHistory) = h[:update_info]

exception(h::SimHistory) = h.exception
Base.backtrace(h::SimHistory) = h.backtrace
POMDPs.discount(h::SimHistory) = h.discount

undiscounted_reward(h::AbstractSimHistory) = sum(reward_hist(h))
function discounted_reward(h::AbstractSimHistory)
    disc = 1.0
    r_total = 0.0
    for r in h[:r]
        r_total += disc*r
        disc *= discount(h)
    end
    return r_total
end


# AbstractArray interface
Base.size(h::AbstractSimHistory) = (n_steps(h),)

Base.getindex(h::AbstractSimHistory, i::Int) = hist(h)[i]
Base.getindex(h::AbstractSimHistory, s::Symbol) = (step[s] for step in hist(h))

# SubHistory
const Inds = Union{AbstractRange,Colon,Real}
Base.view(h::AbstractSimHistory, inds::Inds) = SubHistory(h, inds)

struct SubHistory{NT, H<:AbstractSimHistory{NT}, I<:Inds} <: AbstractSimHistory{NT}
    parent::H
    inds::I
end

n_steps(h::SubHistory) = length(h.inds)
hist(h::SubHistory) = view(hist(h.parent), h.inds)

exception(h::SubHistory) = exception(h.parent)
Base.backtrace(h::SubHistory) = backtrace(h.parent)
POMDPs.discount(h::SubHistory) = discount(h.parent)


# iterators
struct HistoryIterator{H<:AbstractSimHistory, SPEC}
    history::H
end

hist(it::HistoryIterator) = it.history
spec(it::HistoryIterator) = typeof(it).parameters[2]

HistoryIterator(h::AbstractSimHistory, spec) = HistoryIterator{typeof(h), convert_spec(spec, POMDP)}(h)

"""
    for t in eachstep(hist, [spec])
        ...
    end

Iterate through the steps in `SimHistory` `hist`. `spec` is a tuple of symbols or string that controls what is returned for each step.

For example,
```julia
for (s, a, r, sp) in eachstep(h, "(s, a, r, sp)")    
    println("reward \$r received when state \$sp was reached after action \$a was taken in state \$s")
end
```
returns the start state, action, reward and destination state for each step of the simulation.

Alternatively, instead of expanding the steps implicitly, the elements of the step can be accessed as fields (since each step is a `NamedTuple`):
```julia
for step in eachstep(h, "(s, a, r, sp)")    
    println("reward \$(step.r) received when state \$(step.sp) was reached after action \$(step.a) was taken in state \$(step.s)")
end
```

The possible valid elements in the iteration specification are
- Any node in the (PO)MDP Dynamic Decision network (by default `:s`, `:a`, `:sp`, `:o`, `:r`)
- `b` - the initial belief in the step (for POMDPs only)
- `bp` - the belief after being updated based on `o` (for POMDPs only)
- `action_info` - info from the policy decision (from `action_info`)
- `update_info` - info from the belief update (from `update_info`)
- `t` - the timestep index
"""
eachstep(hist::AbstractSimHistory, spec) = HistoryIterator(hist, spec)
eachstep(mh::AbstractSimHistory) = mh

function step_tuple(it::HistoryIterator{<:Any, SPEC}, i::Int) where SPEC
    if isa(SPEC, Tuple)
        return NamedTupleTools.select(hist(it)[i], SPEC)
    else
        @assert isa(spec(it), Symbol) "Output specification $(spec(it)) was not a Tuple or Symbol"
        return hist(it)[i][spec(it)]
    end
end

Base.length(it::HistoryIterator) = n_steps(it.history)
Base.getindex(it::HistoryIterator, i) = step_tuple(it, i)
function Base.iterate(it::HistoryIterator, i::Int = 1)
    if i > length(it)
        return nothing 
    else
        return (step_tuple(it, i), i+1)
    end
end
