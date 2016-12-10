using Base.Test

module MyModule
    using POMDPs
    
    export CoolSolver, solve

    type CoolSolver <: Solver end

    function POMDPs.solve{S,A,O}(s::CoolSolver, p::POMDP{S,A,O})

        @POMDP_requirements "CoolSolver" begin
            @req states(::typeof(p))
        end

        #=
        @POMDP_requirements "CoolSolver" begin
            PType = typeof(p)
            @req states(::PType)
            @req actions(::PType)
            @req transition(::PType, ::S, ::A)
            s = first(states(p))
            a = first(actions(p))
            t_dist = transition(p, s, a)
            @req rand(::AbstractRNG, ::typeof(t_dist))
        end
        =#

    end
end

using POMDPs
using MyModule
using POMDPToolbox

type SimplePOMDP <: POMDP{Float64, Bool, Int} end

POMDPs.discount(::SimplePOMDP) = 0.9

@POMDP_requirements "Warn none" begin
    1+1
end

# @test_throws MethodError solve(CoolSolver(), SimplePOMDP())

POMDPs.states(::SimplePOMDP) = [1.4, 3.2, 5.8]
immutable SimpleDistribution
    ss::Vector{Float64}
    b::Vector{Float64}
end
POMDPs.transition(p::SimplePOMDP, s::Float64, ::Bool) = SimpleDistribution(states(p), [0.2, 0.2, 0.6])

@test solve(CoolSolver(), SimplePOMDP()) == false

Base.rand(rng::AbstractRNG, d::SimpleDistribution) = sample(rng, d.ss, WeightVec(d.b))

@test solve(CoolSolver(), SimplePOMDP())
