using Test

tcall = Meta.parse("f(arg1::T1, arg2::T2)")
@test POMDPs.unpack_typedcall(tcall) == (:f, [:arg1, :arg2], [:T1, :T2])

# tests case where types aren't specified
@POMDP_require tan(s) begin
    @req sin(::typeof(s))
    @req cos(::typeof(s))
end

module MyModule
    using POMDPs
    using Random

    export CoolSolver, solve

    mutable struct CoolSolver <: Solver end

    p = nothing # to test hygeine
    @POMDP_require solve(s::CoolSolver, p::POMDP) begin
        PType = typeof(p)
        S = statetype(PType)
        A = actiontype(PType)
        @req states(::PType)
        @req actions(::PType)
        @req transition(::PType, ::S, ::A)
        @subreq util2(p)
        s = first(states(p))
        @subreq util1(s)
        a = first(actions(p))
        t_dist = transition(p, s, a)
        @req rand(::AbstractRNG, ::typeof(t_dist))
    end

    function POMDPs.solve(s::CoolSolver, problem::POMDP{S,A,O}) where {S,A,O}
        @warn_requirements solve(s, problem)
        reqs = @get_requirements solve(s,problem)
        @assert p==nothing
        return check_requirements(reqs)
    end

    util1(x) = abs(x)

    util2(p::POMDP) = observations(p)
    @POMDP_require util2(p::POMDP) begin
        P = typeof(p)
        @req observations(::P)
    end
end

using POMDPs
using Main.MyModule

mutable struct SimplePOMDP <: POMDP{Float64, Bool, Int} end
POMDPs.actions(SimplePOMDP) = [true, false]

POMDPs.discount(::SimplePOMDP) = 0.9

reqs = nothing # to check the hygeine of the macro
println("There should be a warning about no @reqs here:")
@POMDP_requirements "Warn none" begin
    1+1
end
@test reqs == nothing
@test_throws LoadError macroexpand(Main, quote @POMDP_requirements "Malformed" begin
        @req iterator(typeof(as))
    end
end)

# solve(CoolSolver(), SimplePOMDP())
@test_throws MethodError solve(CoolSolver(), SimplePOMDP())

POMDPs.states(::SimplePOMDP) = [1.4, 3.2, 5.8]
struct SimpleDistribution
    ss::Vector{Float64}
    b::Vector{Float64}
end
POMDPs.transition(p::SimplePOMDP, s::Float64, ::Bool) = SimpleDistribution(states(p), [0.2, 0.2, 0.6])

@test solve(CoolSolver(), SimplePOMDP()) == false

POMDPs.observations(p::SimplePOMDP) = [1,2,3]

Random.rand(rng::AbstractRNG, d::SimpleDistribution) = sample(rng, d.ss, WeightVec(d.b))

println("There should be no warnings or requirements output below this point!\n")

@test solve(CoolSolver(), SimplePOMDP())
