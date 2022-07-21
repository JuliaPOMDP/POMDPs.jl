# these functions return vectors of states, actions and observations, ordered according to stateindex, actionindex, etc.

"""
    ordered_actions(mdp)    

Return an `AbstractVector` of actions ordered according to `actionindex(mdp, a)`.

`ordered_actions(mdp)` will always return an `AbstractVector{A}` `v` containing all of the actions in `actions(mdp)` in the order such that `actionindex(mdp, v[i]) == i`. You may wish to override this for your problem for efficiency.
"""
ordered_actions(mdp::Union{MDP,POMDP}) = ordered_vector(actiontype(typeof(mdp)), a->actionindex(mdp,a), actions(mdp), "action")

"""
    ordered_states(mdp)    

Return an `AbstractVector` of states ordered according to `stateindex(mdp, a)`.

`ordered_states(mdp)` will always return a `AbstractVector{A}` `v` containing all of the states in `states(mdp)` in the order such that `stateindex(mdp, v[i]) == i`. You may wish to override this for your problem for efficiency.
"""
ordered_states(mdp::Union{MDP,POMDP}) = ordered_vector(statetype(typeof(mdp)), s->stateindex(mdp,s), states(mdp), "state")

"""
    ordered_observations(pomdp)    

Return an `AbstractVector` of observations ordered according to `obsindex(pomdp, a)`.

`ordered_observations(mdp)` will always return a `AbstractVector{A}` `v` containing all of the observations in `observations(pomdp)` in the order such that `obsindex(pomdp, v[i]) == i`. You may wish to override this for your problem for efficiency.
"""
ordered_observations(pomdp::POMDP) = ordered_vector(obstype(typeof(pomdp)), o->obsindex(pomdp,o), observations(pomdp), "observation")

function ordered_vector(T::Type, index::Function, space, singular, plural=singular*"s")
    len = length(space)
    a = Array{T}(undef, len)
    gotten = falses(len)
    for x in space
        id = index(x)
        if id > len || id < 1
            error("""
                  $(singular)index(...) returned an index that was out of bounds for $singular $x.

                  index was $id.

                  n_$plural(...) was $len.
                  """) 
        end
        a[id] = x
        gotten[id] = true
    end
    if !all(gotten)
        missing = findall(.!gotten)
        @warn """
             Problem creating an ordered vector of $plural in ordered_$plural(...). There is likely a mistake in $(singular)index(...) or n_$plural(...).

             n_$plural(...) was $len.

             $plural corresponding to the following indices were missing from $plural(...): $missing
             """
    end
    return a
end

@POMDP_require ordered_actions(mdp::Union{MDP,POMDP}) begin
    P = typeof(mdp)
    @req actionindex(::P, ::actiontype(P))
    @req actions(::P)
    as = actions(mdp)
    @req length(::typeof(as))
end

@POMDP_require ordered_states(mdp::Union{MDP,POMDP}) begin
    P = typeof(mdp)
    @req stateindex(::P, ::statetype(P))
    @req states(::P)
    ss = states(mdp)
    @req length(::typeof(ss))
end

@POMDP_require ordered_observations(mdp::Union{MDP,POMDP}) begin
    P = typeof(mdp)
    @req obsindex(::P, ::obstype(P))
    @req observations(::P)
    os = observations(mdp)
    @req length(::typeof(os))
end
