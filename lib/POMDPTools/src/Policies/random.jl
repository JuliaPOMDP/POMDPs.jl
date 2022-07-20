### RandomPolicy ###
# maintained by @zsunberg
"""
    RandomPolicy{RNG<:AbstractRNG, P<:Union{POMDP,MDP}, U<:Updater}
a generic policy that uses the actions function to create a list of actions and then randomly samples an action from it.

Constructor:

    `RandomPolicy(problem::Union{POMDP,MDP};
             rng=Random.GLOBAL_RNG,
             updater=NothingUpdater())`

# Fields 
- `rng::RNG` a random number generator 
- `probelm::P` the POMDP or MDP problem 
- `updater::U` a belief updater (default to `NothingUpdater` in the above constructor)
"""
mutable struct RandomPolicy{RNG<:AbstractRNG, P<:Union{POMDP,MDP}, U<:Updater} <: Policy
    rng::RNG
    problem::P
    updater::U # set this to use a custom updater, by default it will be a void updater
end
# The constructor below should be used to create the policy so that the action space is initialized correctly
RandomPolicy(problem::Union{POMDP,MDP};
             rng=Random.GLOBAL_RNG,
             updater=NothingUpdater()) = RandomPolicy(rng, problem, updater)

## policy execution ##
function action(policy::RandomPolicy, s)
    return rand(policy.rng, actions(policy.problem, s))
end

function action(policy::RandomPolicy, b::Nothing)
    return rand(policy.rng, actions(policy.problem))
end

## convenience functions ##
updater(policy::RandomPolicy) = policy.updater


"""
solver that produces a random policy
"""
mutable struct RandomSolver <: Solver
    rng::AbstractRNG
end
RandomSolver(;rng=Random.GLOBAL_RNG) = RandomSolver(rng)
solve(solver::RandomSolver, problem::Union{POMDP,MDP}) = RandomPolicy(solver.rng, problem, NothingUpdater())
