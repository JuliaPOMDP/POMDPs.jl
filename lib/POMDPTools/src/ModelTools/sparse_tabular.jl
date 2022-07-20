"""
    SparseTabularMDP

An MDP object where states and actions are integers and the transition is represented by a list of sparse matrices.
This data structure can be useful to exploit in vectorized algorithm (e.g. see SparseValueIterationSolver).
The recommended way to access the transition and reward matrices is through the provided accessor functions: `transition_matrix` and `reward_vector`.

# Fields
- `T::Vector{SparseMatrixCSC{Float64, Int64}}` The transition model is represented as a vector of sparse matrices (one for each action). `T[a][s, sp]` the probability of transition from `s` to `sp` taking action `a`.
- `R::Array{Float64, 2}` The reward is represented as a matrix where the rows are states and the columns actions: `R[s, a]` is the reward of taking action `a` in sate `s`.
- `terminal_states::Set{Int64}` Stores the terminal states
- `discount::Float64` The discount factor

# Constructors

- `SparseTabularMDP(mdp::MDP)` : One can provide the matrices to the default constructor or one can construct a `SparseTabularMDP` from any discrete state MDP defined using the explicit interface. 
Note that constructing the transition and reward matrices requires to iterate over all the states and can take a while.
To learn more information about how to define an MDP with the explicit interface please visit https://juliapomdp.github.io/POMDPs.jl/latest/explicit/ .
- `SparseTabularMDP(smdp::SparseTabularMDP; transition, reward, discount)` : This constructor returns a new sparse MDP that is a copy of the original smdp except for the field specified by the keyword arguments.

"""
struct SparseTabularMDP <: MDP{Int64, Int64}
    T::Vector{SparseMatrixCSC{Float64, Int64}} # T[a][s, sp]
    R::Array{Float64, 2} # R[s, a]
    terminal_states::Set{Int64}
    discount::Float64
end

function SparseTabularMDP(mdp::MDP)
    T = transition_matrix_a_s_sp(mdp)
    R = reward_s_a(mdp)
    ts = terminal_states_set(mdp)
    return SparseTabularMDP(T, R, ts, discount(mdp))
end

@POMDP_require SparseTabularMDP(mdp::MDP) begin
    P = typeof(mdp)
    S = statetype(P)
    A = actiontype(P)
    @req discount(::P)
    @subreq ordered_states(mdp)
    @subreq ordered_actions(mdp)
    @req transition(::P,::S,::A)
    @req reward(::P,::S,::A,::S)
    @req stateindex(::P,::S)
    @req actionindex(::P, ::A)
    @req actions(::P, ::S)
    as = actions(mdp)
    ss = states(mdp)
    @req length(::typeof(as))
    @req length(::typeof(ss))
    a = first(as)
    s = first(ss)
    dist = transition(mdp, s, a)
    D = typeof(dist)
    @req support(::D)
    @req pdf(::D,::S)
end

function SparseTabularMDP(mdp::SparseTabularMDP;
                          transition::Union{Nothing, Vector{SparseMatrixCSC{Float64, Int64}}} = nothing,
                          reward::Union{Nothing, Array{Float64, 2}} = nothing,
                          discount::Union{Nothing, Float64} = nothing,
                          terminal_states::Union{Nothing, Set{Int64}} = nothing)
    T = transition != nothing ? transition : mdp.T
    R = reward != nothing ? reward : mdp.R
    d = discount != nothing ? discount : mdp.discount
    ts = terminal_states != nothing ? terminal_states : mdp.terminal_states
    return SparseTabularMDP(T, R, ts, d)    
end

"""
    SparseTabularPOMDP

A POMDP object where states and actions are integers and the transition and observation distributions are represented by lists of sparse matrices.
This data structure can be useful to exploit in vectorized algorithms to gain performance (e.g. see SparseValueIterationSolver).
The recommended way to access the transition, reward, and observation matrices is through the provided accessor functions: `transition_matrix`, `reward_vector`, `observation_matrix`.

# Fields
- `T::Vector{SparseMatrixCSC{Float64, Int64}}` The transition model is represented as a vector of sparse matrices (one for each action). `T[a][s, sp]` the probability of transition from `s` to `sp` taking action `a`.
- `R::Array{Float64, 2}` The reward is represented as a matrix where the rows are states and the columns actions: `R[s, a]` is the reward of taking action `a` in sate `s`.
- `O::Vector{SparseMatrixCSC{Float64, Int64}}` The observation model is represented as a vector of sparse matrices (one for each action). `O[a][sp, o]` is the probability of observing `o` from state `sp` after having taken action `a`.
- `terminal_states::Set{Int64}` Stores the terminal states
- `discount::Float64` The discount factor

# Constructors

- `SparseTabularPOMDP(pomdp::POMDP)` : One can provide the matrices to the default constructor or one can construct a `SparseTabularPOMDP` from any discrete state MDP defined using the explicit interface. 
Note that constructing the transition and reward matrices requires to iterate over all the states and can take a while.
To learn more information about how to define an MDP with the explicit interface please visit https://juliapomdp.github.io/POMDPs.jl/latest/explicit/ .
- `SparseTabularPOMDP(spomdp::SparseTabularMDP; transition, reward, observation, discount)` : This constructor returns a new sparse POMDP that is a copy of the original smdp except for the field specified by the keyword arguments.

"""
struct SparseTabularPOMDP <: POMDP{Int64, Int64, Int64}
    T::Vector{SparseMatrixCSC{Float64, Int64}} # T[a][s, sp]
    R::Array{Float64, 2} # R[s,sp]
    O::Vector{SparseMatrixCSC{Float64, Int64}} # O[a][sp, o]
    terminal_states::Set{Int64}
    discount::Float64
end

function SparseTabularPOMDP(pomdp::POMDP)
    T = transition_matrix_a_s_sp(pomdp)
    R = reward_s_a(pomdp)
    O = observation_matrix_a_sp_o(pomdp)
    ts = terminal_states_set(pomdp)
    return SparseTabularPOMDP(T, R, O, ts, discount(pomdp))
end

@POMDP_require SparseTabularPOMDP(pomdp::POMDP) begin
    P = typeof(pomdp)
    S = statetype(P)
    A = actiontype(P)
    O = obstype(P)
    @req discount(::P)
    @subreq ordered_states(pomdp)
    @subreq ordered_actions(pomdp)
    @subreq ordered_observations(pomdp)
    @req transition(::P,::S,::A)
    @req reward(::P,::S,::A,::S)
    @req observation(::P, ::A, ::S)
    @req stateindex(::P,::S)
    @req actionindex(::P, ::A)
    @req actions(::P, ::S)
    @req observations(::P)
    @req obsindex(::P, ::O)
    as = actions(pomdp)
    ss = states(pomdp)
    @req length(::typeof(as))
    @req length(::typeof(ss))
    a = first(as)
    s = first(ss)
    dist = transition(pomdp, s, a)
    D = typeof(dist)
    @req support(::D)
    @req pdf(::D,::S)
    odist = observation(pomdp, a, s)
    OD = typeof(odist)
    @req support(::OD)
    @req pdf(::OD, ::O)
end


function SparseTabularPOMDP(pomdp::SparseTabularPOMDP;
                          transition::Union{Nothing, Vector{SparseMatrixCSC{Float64, Int64}}} = nothing,
                          reward::Union{Nothing, Array{Float64, 2}} = nothing,
                          observation::Union{Nothing, Vector{SparseMatrixCSC{Float64, Int64}}} = nothing,
                          discount::Union{Nothing, Float64} = nothing,
                          terminal_states::Union{Nothing, Set{Int64}} = nothing)
    T = transition != nothing ? transition : pomdp.T
    R = reward != nothing ? reward : pomdp.R
    d = discount != nothing ? discount : pomdp.discount
    O = observation != nothing ? transition : pomdp.O
    ts = terminal_states != nothing ? terminal_states : pomdp.terminal_states
    return SparseTabularPOMDP(T, R, O, ts, d)    
end

const SparseTabularProblem = Union{SparseTabularMDP, SparseTabularPOMDP}


function transition_matrix_a_s_sp(mdp::Union{MDP, POMDP})
    # Thanks to zach
    na = length(actions(mdp))
    state_space = states(mdp)
    ns = length(state_space)
    transmat_row_A = [Int64[] for _ in 1:na]
    transmat_col_A = [Int64[] for _ in 1:na]
    transmat_data_A = [Float64[] for _ in 1:na]

    for s in state_space
        si = stateindex(mdp, s)
        for a in actions(mdp, s)
            ai = actionindex(mdp, a)
            if isterminal(mdp, s) # if terminal, there is a probability of 1 of staying in that state
                push!(transmat_row_A[ai], si)
                push!(transmat_col_A[ai], si)
                push!(transmat_data_A[ai], 1.0)
            else
                td = transition(mdp, s, a)
                for (sp, p) in weighted_iterator(td)
                    if p > 0.0
                        spi = stateindex(mdp, sp)
                        push!(transmat_row_A[ai], si)
                        push!(transmat_col_A[ai], spi)
                        push!(transmat_data_A[ai], p)
                    end
                end
            end
        end
    end
    transmats_A_S_S2 = [sparse(transmat_row_A[a], transmat_col_A[a], transmat_data_A[a], ns, ns) for a in 1:na]
    # if an action is not valid from a state, the transition is 0.0 everywhere
    # @assert all(all(sum(transmats_A_S_S2[a], dims=2) .≈ ones(ns)) for a in 1:na) "Transition probabilities must sum to 1"
    return transmats_A_S_S2
end

function reward_s_a(mdp::Union{MDP, POMDP})
    state_space = states(mdp)
    action_space = actions(mdp)
    reward_S_A = fill(-Inf, (length(state_space), length(action_space))) # set reward for all actions to -Inf unless they are in actions(mdp, s)
    for s in state_space
        if isterminal(mdp, s)
            reward_S_A[stateindex(mdp, s), :] .= 0.0
        else
            for a in actions(mdp, s)
                td = transition(mdp, s, a)
                r = 0.0
                for (sp, p) in weighted_iterator(td)
                    if p > 0.0
                        r += p*reward(mdp, s, a, sp)
                    end
                end
                reward_S_A[stateindex(mdp, s), actionindex(mdp, a)] = r
            end
        end
    end
    return reward_S_A
end


function terminal_states_set(mdp::Union{MDP, POMDP})
    ts = Set{Int64}()
    for s in states(mdp)
        if isterminal(mdp, s)
            si = stateindex(mdp, s) 
            push!(ts, si)
        end
    end
    return ts
end

function observation_matrix_a_sp_o(pomdp::POMDP)
    state_space, action_space, obs_space = states(pomdp), actions(pomdp), observations(pomdp)
    na, ns, no = length(action_space), length(state_space), length(obs_space)
    obsmat_row_A = [Int64[] for _ in 1:na]
    obsmat_col_A = [Int64[] for _ in 1:na]
    obsmat_data_A = [Float64[] for _ in 1:na]

    for sp in state_space
        spi = stateindex(pomdp, sp)
        for a in action_space
            ai = actionindex(pomdp, a)
            od = observation(pomdp, a, sp)
            for (o, p) in weighted_iterator(od)
                if p > 0.0
                    oi = obsindex(pomdp, o)
                    push!(obsmat_row_A[ai], spi)
                    push!(obsmat_col_A[ai], oi)
                    push!(obsmat_data_A[ai], p)
                end
            end
        end
    end
    obsmats_A_SP_O = [sparse(obsmat_row_A[a], obsmat_col_A[a], obsmat_data_A[a], ns, no) for a in 1:na]
    @assert all(all(sum(obsmats_A_SP_O[a], dims=2) .≈ ones(ns)) for a in 1:na) "Observation probabilities must sum to 1"
    return obsmats_A_SP_O
end

# MDP and POMDP common methods

POMDPs.states(p::SparseTabularProblem) = 1:size(p.T[1], 1)
POMDPs.actions(p::SparseTabularProblem) = 1:size(p.T, 1)
POMDPs.actions(p::SparseTabularProblem, s::Int64) = [a for a in actions(p) if sum(transition_matrix(p, a)) ≈ size(p.T[1], 1)]

POMDPs.stateindex(::SparseTabularProblem, s::Int64) = s
POMDPs.actionindex(::SparseTabularProblem, a::Int64) = a

POMDPs.discount(p::SparseTabularProblem) = p.discount

POMDPs.transition(p::SparseTabularProblem, s::Int64, a::Int64) = SparseCat(findnz(p.T[a][s, :])...) # XXX not memory efficient

POMDPs.reward(p::SparseTabularProblem, s::Int64, a::Int64) = p.R[s, a]

POMDPs.isterminal(p::SparseTabularProblem, s::Int64) = s ∈ p.terminal_states

"""
    transition_matrix(p::SparseTabularProblem, a)
Accessor function for the transition model of a sparse tabular problem.
It returns a sparse matrix containing the transition probabilities when taking action a: T[s, sp] = Pr(sp | s, a).
"""
transition_matrix(p::SparseTabularProblem, a) = p.T[a]

"""     
    transition_matrices(p::SparseTabularProblem)
Accessor function for the transition model of a sparse tabular problem.
It returns a list of sparse matrices for each action of the problem.
"""
transition_matrices(p::SparseTabularProblem) = p.T

"""
    reward_vector(p::SparseTabularProblem, a)
Accessor function for the reward function of a sparse tabular problem.
It returns a vector containing the reward for all the states when taking action a: R(s, a). 
The length of the return vector is equal to the number of states.
"""
reward_vector(p::SparseTabularProblem, a) = view(p.R, :, a)

""" 
    reward_matrix(p::SparseTabularProblem)
Accessor function for the reward matrix R[s, a] of a sparse tabular problem.
"""
reward_matrix(p::SparseTabularProblem) = p.R

# POMDP only methods

POMDPs.observations(p::SparseTabularPOMDP) = 1:size(p.O[1], 2)

POMDPs.observation(p::SparseTabularPOMDP, a::Int64, sp::Int64) = SparseCat(findnz(p.O[a][sp, :])...)

POMDPs.obsindex(p::SparseTabularPOMDP, o::Int64) = o

"""
    observation_matrix(p::SparseTabularPOMDP, a::Int64)
Accessor function for the observation model of a sparse tabular POMDP.
It returns a sparse matrix containing the observation probabilities when having taken action a: O[sp, o] = Pr(o | sp, a).
"""
observation_matrix(p::SparseTabularPOMDP, a::Int64) = p.O[a]

"""     
    observation_matrices(p::SparseTabularPOMDP)
Accessor function for the observation model of a sparse tabular POMDP.
It returns a list of sparse matrices for each action of the problem.
"""
observation_matrices(p::SparseTabularPOMDP) = p.O
