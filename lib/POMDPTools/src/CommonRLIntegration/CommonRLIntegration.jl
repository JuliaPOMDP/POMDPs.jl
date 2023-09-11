module CommonRLIntegration

using ..POMDPDistributions

using POMDPs
import CommonRLInterface
import CommonRLInterface.AutomaticDefault as AD

using Tricks: static_hasmethod

export
    MDPCommonRLEnv,
    POMDPCommonRLEnv,
    POMDPsCommonRLEnv
include("to_env.jl")

export
    RLEnvMDP,
    RLEnvPOMDP,
    OpaqueRLEnvMDP,
    OpaqueRLEnvPOMDP
include("from_env.jl")

end
