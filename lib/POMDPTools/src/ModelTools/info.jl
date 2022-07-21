# functions for passing out info from simulations, similar to the info return from openai gym
# maintained by @zsunberg

"""
    a, ai = action_info(policy, x)

Return a tuple containing the action determined by policy 'p' at state or belief 'x' and information (usually a `NamedTuple`, `Dict` or `nothing`) from the calculation of that action.

By default, returns `nothing` as info.
"""
function action_info(p::Policy, x)
    return action(p, x), nothing
end

"""
    policy, si = solve_info(solver, problem)

Return a tuple containing the policy determined by a solver and information (usually a `NamedTuple`, `Dict` or `nothing`) from the calculation of that policy.

By default, returns `nothing` as info.
"""
function solve_info(s::Solver, problem::Union{POMDP,MDP})
    return solve(s, problem), nothing
end

"""
    bp, i = update_info(updater, b, a, o)

Return a tuple containing the new belief and information (usually a `NamedTuple`, `Dict` or `nothing`) from the belief update.

By default, returns `nothing` as info.
"""
function update_info(up::Updater, b, a, o)
    return update(up, b, a, o), nothing
end
