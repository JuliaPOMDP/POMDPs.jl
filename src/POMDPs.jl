module POMDPs

export 
    # Abstract type
    POMDP,
    DiscretePOMDP,
    # Discrete Functions
    n_states,
    n_actions,
    n_observations,
    # Model functions
    states,
    states!,
    actions,
    actions!,
    observations,
    observations!,
    fully_obs_space,
    part_obs_space,
    transition!,
    observation!,
    reward,
    # Need below?;
    create_action,
    create_state,
    create_observation,

    # Spaces, Distributions and accessor functions
    AbstractDistribution,
    DiscreteDistribution,
    AbstractSpace, 
    # Discrete Functions
    length,
    index,
    weight,
    # Common Functions
    rand!,
    pdf,
    dimensions,
    lowerbound,
    upperbound,
    getindex,
    domain,
    create_transition,
    create_observation,

    # Solver types
    Solver,
    solve,
    solve!,

    # Belieds
    Belief,
    update_belief,
    update_belief!,

    # Policy
    Policy,
    action,
    value


include("pomdp.jl")
include("distribution.jl")
include("belief.jl")
include("solver.jl")
include("policy.jl")

end

