module ModelTools

using POMDPs
using Random
using LinearAlgebra
using SparseArrays
using Tricks: static_hasmethod

import POMDPs: actions, actionindex
import POMDPs: states, stateindex
import POMDPs: observations, obsindex
import POMDPs: initialstate, isterminal, discount
import Statistics: mean
import Base: ==

using ..POMDPDistributions

# import Distributions: pdf, mode, mean, support
# import POMDPLinter: @POMDP_require

export
    render
include("visualization.jl")

# info interface
export
    action_info,
    solve_info,
    update_info
include("info.jl")

export
    ordered_states,
    ordered_actions,
    ordered_observations
include("ordered_spaces.jl")

export
    TerminalState,
    terminalstate
include("terminal_state.jl")

export GenerativeBeliefMDP
include("generative_belief_mdp.jl")

export FullyObservablePOMDP
include("fully_observable_pomdp.jl")

export UnderlyingMDP
include("underlying_mdp.jl")

export obs_weight
include("obs_weight.jl")

export
    probability_check,
    obs_prob_consistency_check,
    trans_prob_consistency_check

export
    StateActionReward,
    FunctionSAR,
    LazyCachedSAR
include("state_action_reward.jl")

export 
    SparseTabularMDP,
    SparseTabularPOMDP,
    transition_matrix,
    reward_vector,
    observation_matrix,
    reward_matrix,
    observation_matrices
include("sparse_tabular.jl")

export
    transition_matrices,
    reward_vectors
include("matrices.jl")

end
