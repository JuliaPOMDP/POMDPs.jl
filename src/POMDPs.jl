module POMDPs

import Base.rand

export 
    # Abstract type
    POMDP,

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
    isterminal_obs,
    
    # Spaces, Distributions and accessor functions
    AbstractDistribution,
    DiscreteDistribution,
    AbstractSpace, 
    
    # Discrete Functions
    length,
    state_index,
    action_index,
    obs_index,
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
    
    #=
    # Rewards
    Reward,
    =#

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
include("default_constructors.jl")
include("pomdp.jl")
include("distribution.jl")
include("belief.jl")
include("space.jl")
include("solver.jl")
include("policy.jl")
include("simulator.jl")
#include("docs.jl")

end

