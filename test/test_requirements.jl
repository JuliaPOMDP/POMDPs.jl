using Base.Test

module MyModule
    using POMDPs
    
    export CoolSolver, solve

    type CoolSolver <: Solver end

    function POMDPs.solve{S,A,O}(s::CoolSolver, p::POMDP{S,A,O})

        PTYPE = typeof(p)

        # register requirements
        reqs = RequirementSet("CoolSolver")
        @push_reqs! reqs begin
            discount( ::PTYPE)
            states( ::PTYPE)
            actions( ::PTYPE)
            transition( ::PTYPE, ::S, ::A)
        end

        # you can use expressions like typeof(p) directly (redundant with above)
        @push_reqs! reqs begin
            actions( ::typeof(p))
        end

        # alternative way to push requirements (redundant with above)
        push!(reqs, @req actions(::typeof(p)) )

        @try_with_reqs begin
            s = first(states(p))
            a = first(actions(p))
            t_dist = transition(p, s, a)
            @push_req! reqs rand( ::AbstractRNG, ::typeof(t_dist) )
        end reqs

        # check requirements and output list if any are missing
        return check_requirements(reqs, output=:ifmissing)
    end
end

using POMDPs
using MyModule
using POMDPToolbox

type SimplePOMDP <: POMDP{Float64, Bool, Int} end

@test @req(discount(::SimplePOMDP)) == (discount, Tuple{SimplePOMDP})

POMDPs.discount(::SimplePOMDP) = 0.9

@test_throws MethodError solve(CoolSolver(), SimplePOMDP())

POMDPs.states(::SimplePOMDP) = [1.4, 3.2, 5.8]
immutable SimpleDistribution
    ss::Vector{Float64}
    b::Vector{Float64}
end
POMDPs.transition(p::SimplePOMDP, s::Float64, ::Bool) = SimpleDistribution(states(p), [0.2, 0.2, 0.6])

@test solve(CoolSolver(), SimplePOMDP()) == false

Base.rand(rng::AbstractRNG, d::SimpleDistribution) = sample(rng, d.ss, WeightVec(d.b))

@test solve(CoolSolver(), SimplePOMDP())
