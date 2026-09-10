"""
    ValuePolicy(mdp, values)

A policy that stores a value or Q-value for each state. 

The entry at `stateindex(mdp, s)` is the value (or Q-value) associated with state `s`.

# Example