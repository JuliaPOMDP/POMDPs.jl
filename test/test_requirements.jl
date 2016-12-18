using Base.Test

tcall = parse("f(arg1::T1, arg2::T2)")
@test POMDPs.unpack_typedcall(tcall) == (:f, [:arg1, :arg2], [:T1, :T2])

module MyModule
    using POMDPs
    
    export CoolSolver, solve

    type CoolSolver <: Solver end

    p = nothing

    @POMDP_require solve(s::CoolSolver, p::POMDP) begin
        PType = typeof(p)
        S = state_type(PType)
        A = action_type(PType)
        @req states(::PType)
        @req actions(::PType)
        @req transition(::PType, ::S, ::A)
        s = first(states(p))
        a = first(actions(p))
        t_dist = transition(p, s, a)
        @req rand(::AbstractRNG, ::typeof(t_dist))
    end

    function POMDPs.solve{S,A,O}(s::CoolSolver, problem::POMDP{S,A,O})
        @warn_requirements solve(s, problem)
        reqs = @get_requirements solve(s,problem)
        @assert p==nothing
        return check_requirements(reqs, output=false)
    end
end

using POMDPs
using MyModule
using POMDPToolbox

type SimplePOMDP <: POMDP{Float64, Bool, Int} end

POMDPs.discount(::SimplePOMDP) = 0.9

reqs = nothing # to check the hygeine of the macro
@POMDP_requirements "Warn none" begin
    1+1
end
@test reqs == nothing

# solve(CoolSolver(), SimplePOMDP())
@test_throws MethodError solve(CoolSolver(), SimplePOMDP())

POMDPs.states(::SimplePOMDP) = [1.4, 3.2, 5.8]
immutable SimpleDistribution
    ss::Vector{Float64}
    b::Vector{Float64}
end
POMDPs.transition(p::SimplePOMDP, s::Float64, ::Bool) = SimpleDistribution(states(p), [0.2, 0.2, 0.6])

@test solve(CoolSolver(), SimplePOMDP()) == false

Base.rand(rng::AbstractRNG, d::SimpleDistribution) = sample(rng, d.ss, WeightVec(d.b))

println("There should be no warnings or requirements output below this point!\n")

@test solve(CoolSolver(), SimplePOMDP())
