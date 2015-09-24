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
    actions,
    observations,
    transition,
    observation,
    reward,
    isterminal,
    
    # Need below?;
    create_state,
    create_observation,
    create_action,

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
    initial_belief,

    # Solver types
    Solver,
    solve,
    
    # States
    State,
    
    # Actions
    Action,
    create_action,

    # Observations
    Observation,

    # Rewards
    Reward,

    # Beliefs
    Belief,
    belief,

    # Policy
    Policy,
    action,
    value,

    # Simulation
    Simulator,
    simulate


include("pomdp.jl")
include("distribution.jl")
include("belief.jl")
include("solver.jl")
include("policy.jl")
include("simulator.jl")

end

