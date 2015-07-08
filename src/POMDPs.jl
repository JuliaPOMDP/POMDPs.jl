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
    transition!,
    observation!,
    reward,
    # Need below?;
    create_action,
    create_state,
    create_observation,
    convert!,

    # Spaces, Distributions and accessor functions
    AbstractDistribution,
    DiscreteDistribution,
    # Discrete Functions
    index,
    weight,
    # Common Functions
    Space, 
    rand!,
    pdf,
    dimensions,
    lowerbound,
    upperbound,
    getindex,
    domain,
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


include("distribution.jl")
include("pomdp.jl")
include("belief.jl")
include("interpolants.jl")
include("solver.jl")
include("policy.jl")

end

