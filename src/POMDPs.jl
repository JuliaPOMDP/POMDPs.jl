module POMDPs

import Base.rand

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
    rand,
    pdf,
    dimensions,
    lowerbound,
    upperbound,
    getindex,
    iterator,
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
    BeliefUpdater,
    initial_belief,
    update,
    convert_belief,

    # Policy
    Policy,
    action,
    updater,
    value,

    # Simulation
    Simulator,
    simulate

    # Utilities
    #add not explicitly imported

include("errors.jl")
include("constants.jl")
include("utils.jl")
include("pomdp.jl")
include("distribution.jl")
include("belief.jl")
include("space.jl")
include("solver.jl")
include("policy.jl")
include("simulator.jl")
include("docs.jl")

end

