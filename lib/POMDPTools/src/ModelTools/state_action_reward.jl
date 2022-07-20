"""
    StateActionReward(m::Union{MDP,POMDP})

Robustly create a reward function that depends only on the state and action.

If `reward(m, s, a)` is implemented, that will be used, otherwise the mean of `reward(m, s, a, sp)` for MDPs or `reward(m, s, a, sp, o)` for POMDPs will be used.

# Example
```jldoctest
using POMDPs
using POMDPModels
using POMDPModelTools

m = BabyPOMDP()

rm = StateActionReward(m)

rm(true, true)

# output

-15.0
```
"""
abstract type StateActionReward end

function StateActionReward(m)
    if hasmethod(reward, Tuple{typeof(m), statetype(m), actiontype(m)})
        return FunctionSAR(m)
    else
        return LazyCachedSAR(m)
    end
end

struct FunctionSAR{M} <: StateActionReward
    m::M
end

function (sar::FunctionSAR)(s, a)
    if isterminal(sar.m, s)
        return 0.0
    else
        return reward(sar.m, s, a)
    end
end

struct LazyCachedSAR{M} <: StateActionReward
    m::M
    cache::Matrix{Union{Missing,Float64}}
end

function LazyCachedSAR(m)
    ns = length(states(m))
    na = length(actions(m))
    return LazyCachedSAR(m, Matrix{Union{Missing, Float64}}(missing, ns, na))
end

function (sar::LazyCachedSAR)(s, a)::Float64
    si = stateindex(sar.m, s)
    ai = actionindex(sar.m, a)
    entry = sar.cache[si, ai]
    if ismissing(entry)
        r = mean_reward(sar.m, s, a)
        sar.cache[si, ai] = r
    else
        r = entry
    end
    return r
end

function mean_reward(m::MDP, s, a)
    if isterminal(m, s)
        return 0.0
    else
        td = transition(m, s, a)
        rsum = 0.0
        wsum = 0.0
        for (sp, w) in weighted_iterator(td)
            rsum += w*reward(m, s, a, sp)
            wsum += w
        end
        return rsum/wsum
    end
end

function mean_reward(m::POMDP, s, a)
    if isterminal(m, s)
        return 0.0
    else
        td = transition(m, s, a)
        rsum = 0.0
        wsum = 0.0
        for (sp, w) in weighted_iterator(td)
            od = observation(m, s, a, sp)
            for (o, ow) in weighted_iterator(od)
                rsum += ow*w*reward(m, s, a, sp, o)
                wsum += ow*w
            end
        end
        return rsum/wsum
    end
end
