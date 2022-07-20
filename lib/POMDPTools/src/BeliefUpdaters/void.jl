# maintained by @zsunberg
# an empty belief
# for use with e.g. a random policy
"""
An updater useful for when a belief is not necessary (i.e. for a random policy). `update` always returns `nothing`.
"""
mutable struct NothingUpdater <: Updater end

initialize_belief(::NothingUpdater, ::Any) = nothing
initialize_belief(::NothingUpdater, ::Any, ::Any) = nothing
create_belief(::NothingUpdater) = nothing

update(::NothingUpdater, ::B, ::Any, ::Any, b=nothing) where B = nothing
