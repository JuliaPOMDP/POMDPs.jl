module POMDPs

export 
    # Abstract type
    POMDP,
    # Model functions
    states,
    actions!,
    observations,
    n_states,
    n_actions,
    n_observations,
    transition!,
    observation!,
    reward,
    create_action,
    create_state,
    convert!,

    # Spaces, Distributions and accessor functions
    AbstractDistribution,
    Space, 
    rand!,
    pdf,
    dimensions,
    lowerbound,
    upperbound,
    getindex,
    create_transition,
    create_observation,

    # Interpolants and access functions
    AbstractInterpolants,
    create_interpolants,
    length,
    interpolants!,
    weight,
    index,

    # Solver types
    Solver,
    SerialSolver,
    ParallelSolver,
    solve,
    solve!,

    # Belieds
    Belief,
    update_belief,

    # Policy
    Policy,
    DiscretePolicy,
    get_action,
    get_value


include("pomdp.jl")
include("belief.jl")
include("distribution.jl")
include("interpolants.jl")
include("solver.jl")
include("policy.jl")

end

