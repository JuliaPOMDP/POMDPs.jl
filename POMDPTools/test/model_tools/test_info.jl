mutable struct VoidUpdater <: Updater end
POMDPs.update(::VoidUpdater, ::B, ::Any, ::Any, b=nothing) where B = nothing

mutable struct RandomPolicy{P <: Union{MDP, POMDP}} <: Policy
    rng::AbstractRNG
    problem::P
end
RandomPolicy(problem::Union{POMDP,MDP};
            rng=Random.GLOBAL_RNG) = RandomPolicy(rng, problem)

function POMDPs.action(policy::RandomPolicy, s)
    return rand(policy.rng, actions(policy.problem, s))
end

mutable struct RandomSolver <: Solver
    rng::AbstractRNG
end

RandomSolver(;rng=Base.GLOBAL_RNG) = RandomSolver(rng)
POMDPs.solve(solver::RandomSolver, problem::P) where {P<:Union{POMDP,MDP}} = RandomPolicy(solver.rng, problem)

let
    rng = MersenneTwister(7)

    mdp = LegacyGridWorld()
    #=
    POMDPs.DDNStructure(::Type{typeof(mdp)}) = DDNStructure(MDP) |> add_infonode
    @test :info in nodenames(DDNStructure(mdp))
    s = initialstate(mdp, rng)
    a = rand(rng, actions(mdp))
    if VERSION >= v"1.3"
        sp, r, i = @inferred gen(DDNOut(:sp,:r,:info), mdp, s, a, rng)
    else
        sp, r, i = gen(DDNOut(:sp,:r,:info), mdp, s, a, rng)
    end
    @test i === nothing

    pomdp = TigerPOMDP()
    POMDPs.DDNStructure(::Type{typeof(pomdp)}) = DDNStructure(POMDP) |> add_infonode
    @test :info in nodenames(DDNStructure(pomdp))
    s = initialstate(pomdp, rng)
    a = rand(rng, actions(pomdp))
    if VERSION >= v"1.3"
        sp, o, r, i = @inferred gen(DDNOut(:sp,:o,:r,:info), pomdp, s, a, rng)
    else
        sp, o, r, i = gen(DDNOut(:sp,:o,:r,:info), pomdp, s, a, rng)
    end
    @test i === nothing
    =#

    pomdp = TigerPOMDP()
    s = rand(rng, initialstate(pomdp))

    up = VoidUpdater()
    policy = RandomPolicy(rng, pomdp)
    @inferred action_info(policy, s)

    solver = RandomSolver(rng=rng)
    policy, sinfo = solve_info(solver, pomdp)
    @test isa(sinfo, Nothing)

    d = initialstate_distribution(pomdp)
    b = initialize_belief(up, d)
    a = action(policy, b)
    sp, o, r = @gen(:sp,:o,:r)(pomdp, rand(rng, d), a, rng)
    @inferred update_info(up, b, a, o)
end
