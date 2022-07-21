let
    mutable struct InfoTestUpdater <: Updater end
    POMDPs.update(::InfoTestUpdater, ::B, ::Any, ::Any, b=nothing) where B = nothing

    mutable struct InfoTestRandomPolicy{P <: Union{MDP, POMDP}} <: Policy
        rng::AbstractRNG
        problem::P
    end
    InfoTestRandomPolicy(problem::Union{POMDP,MDP};
                rng=Random.GLOBAL_RNG) = InfoTestRandomPolicy(rng, problem)

    function POMDPs.action(policy::InfoTestRandomPolicy, s)
        return rand(policy.rng, actions(policy.problem, s))
    end

    mutable struct InfoTestRandomSolver <: Solver
        rng::AbstractRNG
    end

    InfoTestRandomSolver(;rng=Base.GLOBAL_RNG) = InfoTestRandomSolver(rng)
    POMDPs.solve(solver::InfoTestRandomSolver, problem::P) where {P<:Union{POMDP,MDP}} = InfoTestRandomPolicy(solver.rng, problem)

    let
        rng = MersenneTwister(7)

        mdp = LegacyGridWorld()

        pomdp = TigerPOMDP()
        s = rand(rng, initialstate(pomdp))

        up = InfoTestUpdater()
        policy = InfoTestRandomPolicy(rng, pomdp)
        @inferred action_info(policy, s)

        solver = InfoTestRandomSolver(rng=rng)
        policy, sinfo = solve_info(solver, pomdp)
        @test isa(sinfo, Nothing)

        d = initialstate_distribution(pomdp)
        b = initialize_belief(up, d)
        a = action(policy, b)
        sp, o, r = @gen(:sp,:o,:r)(pomdp, rand(rng, d), a, rng)
        @inferred update_info(up, b, a, o)
    end
end
