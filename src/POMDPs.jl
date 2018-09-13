"""
Provides a basic interface for defining and solving MDPs/POMDPs
"""
module POMDPs

using Random
import Base: rand
import Statistics
import Distributions: rand, pdf, mode, mean, support
import Pkg
import LibGit2

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

    # Generative model functions
    generate_s,
    generate_o,
    generate_sr,
    generate_so,
    generate_or,
    generate_sor,
    initialstate,
    
    # Discrete Functions
    length,
    stateindex,
    actionindex,
    obsindex,
    weight,
    
    # Common Functions
    rand,
    pdf,
    mode,
    mean,
    dimensions,
    lowerbound,
    upperbound,
    getindex,
    support,
    sampletype,
    initialstate_distribution,

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
    implemented,
    @implemented,
    convert_s,
    convert_a,
    convert_o,
    statetype,
    actiontype,
    obstype,

    # Requirements checking
    RequirementSet,
    check_requirements,
    show_requirements,
    get_requirements,
    requirements_info,
    @POMDP_require,
    @POMDP_requirements,
    @requirements_info,
    @get_requirements,
    @show_requirements,
    @warn_requirements,
    @req,
    @subreq,


    # Deprecated
    state_index,
    action_index,
    obs_index,
    state_type,
    action_type,
    obs_type,
    initial_state,
    initial_state_distribution,
    iterator


include("requirements_internals.jl")
include("requirements_printing.jl")
include("pomdp.jl")
include("solver.jl")
include("simulator.jl")
include("requirements_interface.jl")
include("distribution.jl")
include("belief.jl")
include("space.jl")
include("policy.jl")
include("generative.jl")
include("generative_impl.jl")
include("type_inferrence.jl")
include("constants.jl")
include("utils.jl")

end
