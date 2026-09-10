"""
    ValuePolicy(mdp, values)

A policy defined by a vector or array of state values (or utility estimates) corresponding to each state index. 

# Fields
- `mdp`: The Markov Decision Process.
- `values`: A vector where the entry at `stateindex(mdp, s)` represents the value of state `s`.

# Example