"""
Provides a basic interface for defining and solving MDPs/POMDPs
"""
module POMDPs

using Random
using Base: @pure
import Base: rand
import Statistics
import Distributions: rand, pdf, mode, mean, support
import NamedTupleTools
import Pkg
import LibGit2
using LightGraphs
using Logging

export 
    # Abstract type
    POMDP,
    MDP,

    # Model functions
    discount,
    states,
    actions,
    observations,
    transition,
    observation,
    reward,
    isterminal,

    # Generative model functions
    gen,
    initialstate,
    initialobs,

    # Discrete Functions
    length,
    stateindex,
    actionindex,
    obsindex,
    
    # Common Functions
    rand,
    pdf,
    mode,
    mean,
    dimensions,
    support,
    initialstate_distribution,

    # Solver types
    Solver,
    solve,
    
    # Beliefs
    Updater,
    update,
    initialize_belief,
    history,
    currentobs,

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

    # DDNs
    DDNNode,
    DDNOut,
    DDNStructure,
    DDNStructure,
    DistributionDDNNode,
    FunctionDDNNode,
    ConstantDDNNode,
    InputDDNNode,
    GenericDDNNode,
    node,
    depvars,
    depnames,
    nodenames,
    outputnames,
    name,
    add_node,
    pomdp_ddn,
    mdp_ddn,
    DistributionNotImplemented,

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
    generate_s,
    generate_o,
    generate_sr,
    generate_so,
    generate_or,
    generate_sor,
    sampletype,
    n_states,
    n_actions,
    n_observations
 
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
include("type_inferrence.jl")
include("ddn_struct.jl")
include("errors.jl")
include("generative.jl")
include("gen_impl.jl")
include("utils.jl")
include("deprecated.jl")

end
