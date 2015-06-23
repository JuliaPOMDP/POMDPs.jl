

abstract AbstractDistribution

create_transition(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_transition") # creates a dsitribution 
create_observation(pomdp::POMDP) = error("$(typeof(pomdp)) does not implement create_observation") # creates a dsitribution 
rand!(state::Any, d::AbstractDistribution)  = error("$(typeof(d)) does not implement rand") # fills with a random state
pdf(d::AbstractDistribution, x::Any)        = error("$(typeof(d)) does not implement pdf") # returns a probability
discretize(d::AbstractDistribution, params::Any) = 

get_space(d::AbstractDistribution)   = error("$(typeof(d)) does not implement get_space") # returns a space
# can support this function here if define AbstractDistribution type
disretize(d::AbstractDistribution, cuts::Array{Int}) = error("$(typeof(d)) does not implement dicretize")
discretize!(x::Array, d::AbstractDistribution, cuts::Array{Int}) = error("$(typeof(d)) does not implement dicretize!")


typealias AbstractSpace AbstractDistribution

dimensions(s::AbstractSpace) = error("$(typeof(s)) does not implement dimensions") # returns an integer
lowerbound(s::AbstractSpace, i::Int) = error("$(typeof(s)) does not implement lowerbound") # returns bound of dim i
upperbound(s::AbstractSpace, i::Int) = error("$(typeof(s)) does not implement upperbound") # returns bound of dim i 
Base.getindex(s::AbstractSpace, i::Int) = error("$(typeof(s)) does not implement getindex") # returns distribution for dim i
