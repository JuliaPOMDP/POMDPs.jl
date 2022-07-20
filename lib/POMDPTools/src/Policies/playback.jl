
"""
    PlaybackPolicy{A<:AbstractArray, P<:Policy, V<:AbstractArray{<:Real}}
a policy that applies a fixed sequence of actions until they are all used and then falls back onto a backup policy until the end of the episode.

Constructor:

    `PlaybackPolicy(actions::AbstractArray, backup_policy::Policy; logpdfs::AbstractArray{Float64, 1} = Float64[])`

# Fields
- `actions::Vector{A}` a vector of actions to play back
- `backup_policy::Policy` the policy to use when all prescribed actions have been taken but the episode continues
- `logpdfs::Vector{Float64}` the log probability (density) of actions
- `i::Int64` the current action index
"""
mutable struct PlaybackPolicy{A<:AbstractArray, P<:Policy, V<:AbstractArray{<:Real}} <: Policy
    actions::A
    backup_policy::P
    logpdfs::V
    i::Int64
end

# Constructor for the PlaybackPolicy
PlaybackPolicy(actions::AbstractArray, backup_policy::Policy; logpdfs::AbstractArray{<:Real} = Float64[]) = PlaybackPolicy(actions, backup_policy, logpdfs, 1)

# Action selection for the PlaybackPolicy
function POMDPs.action(p::PlaybackPolicy, s)
    a = p.i <= length(p.actions) ? p.actions[p.i] : action(p.backup_policy, s)
    p.i += 1
    a
end

# Get the logpdf of the history from the playback policy and the backup policy
function Distributions.logpdf(p::PlaybackPolicy, h)
    N = min(length(p.actions), length(h))
    # @assert all(collect(action_hist(h))[1:N] .== p.actions[1:N])
    @assert length(p.actions) == length(p.logpdfs)
    if length(h) > N
        return sum(p.logpdfs) + sum(logpdf(p.backup_policy, view(h, N+1:length(h))))
    else
        return sum(p.logpdfs[1:N])
    end
end


