using POMDPs
using Base.Test

module MyModule
    using POMDPs
    
    export CoolSolver, solve

    type CoolSolver <: Solver end

    function POMDPs.solve{S,A,O}(s::CoolSolver, p::POMDP{S,A,O})

        # register requirements
        reqs = RequirementsList("CoolSolver")
        push!(reqs, discount, Tuple{typeof(p)})
        push!(reqs, states, Tuple{typeof(p)})
        push!(reqs, actions, Tuple{typeof(p)})
        push!(reqs, transition, Tuple{typeof(p), S, A})

        @try_with_reqs begin
            s = first(states(p))
            a = first(actions(p))
            t_dist = transition(p, s, a)
            push!(reqs, rand, Tuple{AbstractRNG, typeof(t_dist)})
        end reqs

        # check requirements and output list if any are missing
        return check_requirements(reqs, output=:ifmissing)
    end
end

using POMDPs
using MyModule
using POMDPToolbox

type SimplePOMDP <: POMDP{Float64, Bool, Int} end

POMDPs.discount(::SimplePOMDP) = 0.9
POMDPs.states(::SimplePOMDP) = [1.4, 3.2, 5.8]

@test_throws MethodError solve(CoolSolver, SimplePOMDP)

immutable SimpleDistribution
    ss::Vector{Float64}
    b::Vector{Float64}
end
POMDPs.transition(p::SimplePOMDP, s::Float64, ::Bool) = SimpleDistribution(states(p), [0.2, 0.2, 0.6])

@test solve(CoolSolver(), SimplePOMDP()) == false

Base.rand(rng::AbstractRNG, d::SimpleDistribution) = sample(rng, d.ss, WeightVec(d.b))

@test solve(CoolSolver(), SimplePOMDP())
