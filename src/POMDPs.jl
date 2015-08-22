module POMDPs

import Base.rand!

export 
    # Abstract type
    POMDP,
    DiscretePOMDP,

    # Discrete Functions
    n_states,
    n_actions,
    n_observations,
    
    # Model functions
    discount,
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
    isterminal,
    
    # Need below?;
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
    create_transition_distribution,
    create_observation_distribution,
    create_belief,

    # Solver types
    Solver,
    solve,
    solve!,
    
    # States
    State,
    
    # Actions
    Action,

    # Observations
    Observation,

    # Rewards
    Reward,

    # Beliefs
    Belief,
    update_belief,
    update_belief!,

    # Policy
    Policy,
    action,
    value,

    # Simulation
    simulate


include("pomdp.jl")
include("distribution.jl")
include("belief.jl")
include("solver.jl")
include("policy.jl")
include("simulate.jl")

end

