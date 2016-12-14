__precompile__()

"""
Provides a basic interface for defining and solving MDPs/POMDPs
"""
module POMDPs

import Base.rand

export 
    # Abstract type
    POMDP,
    MDP,

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
    initial_state_distribution,

    # Solver types
    Solver,
    solve,
    
    # Beliefs
    Updater,
    update,
    initialize_belief,

    # Policy
    Policy,
    action,
    updater,
    value,

    # Simulation
    Simulator,
    simulate,

    # Utilities
    #add not explicitly imported
    state_type,
    action_type,
    obs_type,

    # Requirements checking
    RequirementSet,
    check_requirements,
    @POMDP_requirements,
    @check_requirements,
    @req


include("pomdp.jl")
include("distribution.jl")
include("belief.jl")
include("space.jl")
include("solver.jl")
include("policy.jl")
include("simulator.jl")
include("type_inferrence.jl")
include("constants.jl")
include("utils.jl")
include("requirements.jl")

end
