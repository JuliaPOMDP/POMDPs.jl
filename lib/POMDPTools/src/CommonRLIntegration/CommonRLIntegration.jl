module CommonRLIntegration

using ..POMDPDistributions

using POMDPs
import CommonRLInterface

using Tricks: static_hasmethod # Yuck! 

export
    MDPCommonRLEnv,
    POMDPCommonRLEnv
include("to_env.jl") 

export
    RLEnvMDP,
    RLEnvPOMDP,
    OpaqueRLEnvMDP,
    OpaqueRLEnvPOMDP
include("from_env.jl") 

end
