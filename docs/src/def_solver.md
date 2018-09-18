# Defining a Solver

In this section, we will walk through an implementation of the
[QMDP](http://www-anw.cs.umass.edu/~barto/courses/cs687/Cassandra-etal-POMDP.pdf) algorithm. QMDP is the fully
observable approximation of a POMDP policy, and relies on the Q-values to determine actions.

## Background

Let's say we are working with a POMDP defined by the tuple $(\mathcal{S}, \mathcal{A}, \mathcal{Z}, T, R, O, \gamma)$,
where $\mathcal{S}$, $\mathcal{A}$, $\mathcal{Z}$ are the discrete state, action, and observation spaces
respectively. The QMDP algorithm assumes it is given a discrete POMDP. In our model $T : \mathcal{S} \times
\mathcal{A} \times \mathcal{S} \rightarrow [0, 1]$ is the transition function, $R: \mathcal{S} \times \mathcal{A}
\rightarrow \mathbb{R}$ is the reward function, and $O: \mathcal{Z} \times \mathcal{A} \times \mathcal{S} \rightarrow
[0,1]$ is the observation function. In a POMDP, our goal is to compute a policy $\pi$ that maps beliefs to actions $\pi: b \rightarrow a$. For
QMDP, a belief can be represented by a discrete probability distribution over the state space (although there may be
other ways to define a belief in general and POMDPs.jl allows this flexibility).

It can be shown (e.g. in [1], section 6.3.2) that the optimal value function for a POMDP can be written in terms of alpha vectors. In the QMDP approximation, there is a single alpha vector that corresponds to each action ($\alpha_a$), and the policy is computed according to

$\pi(b) = \underset{a}{\text{argmax}} \, \alpha_{a}^{T}b$

Thus, the alpha vectors can be used to compactly represent a QMDP policy.

## QMDP Algorithm

QMDP uses the columns of the Q-matrix obtained by solving the MDP defined by $(\mathcal{S}, \mathcal{A}, T, R, \gamma)$ (that is, the fully observable MDP that forms the basis for the POMDP we are trying to solve).
If you are familiar with the value iteration algorithm for MDPs, the procedure for finding these alpha vectors is identical. Let's first
initialize the alpha vectors $\alpha_{a}^{0} = 0$ for all $s$, and then iterate

$\alpha_{a}^{k+1}(s) = R(s,a) + \gamma \sum_{s'} T(s'|s,a) \max_{a'} \alpha_{a'}^{k}(s')$

After enough iterations, the alpha vectors converge to the QMDP approximation.

Remember that QMDP is just an approximation method, and does not guarantee that the alpha vectors you obtain actually
represent your POMDP value function. Specifically, QMDP has trouble in problems with information gathering actions
(because we completely ignored the observation function when computing our policy). However, QMDP works very well in problems where a particular choice of action has
little impact on the reduction in state uncertainty.


## Requirements for a Solver

Before getting into the implementation details, let's first go through what a POMDP solver must be able to do and support. We need three custom types that inherit from abstract types in POMDPs.jl. These type are Solver, Policy, and Updater. It is usually useful to have a custom type that represents the belief used by your policy as well.

The requirements are as follows:

```julia
# types
QMDPSolver
QMDPPolicy
DiscreteUpdater # already implemented for us in BeliefUpdaters
DiscreteBelief # already implemented for us in BeliefUpdaters
# methods
updater(p::QMDPPolicy) # returns a belief updater suitable for use with QMDPPolicy
initialize_belief(bu::DiscreteUpdater, initial_state_dist) # returns a Discrete belief
solve(solver::QMDPSolver, pomdp::POMDP) # solves the POMDP and returns a policy
update(bu::DiscreteUpdater, belief_old::DiscreteBelief, action, obs) # returns an updated belied (already implemented)
action(policy::QMDPPolicy, b::DiscreteBelief) # returns a QMDP action
```

You can find the implementations of these types and methods below.

## Defining the Solver and Policy Types

Let's first define the Solver type. The QMDP solver type should contain all the information needed to compute a policy (other than the problem itself). This information can be thought of as the hyperparameters of the solver. In QMDP, we only need two hyper-parameters. We may want to set the maximum number of iterations that the algorithm runs for, and a tolerance value (also known as the Bellman residual). Both of these quantities define terminating criteria for the algorithm. The algorithm stops either when the maximum number of iterations has been reached or when the infinity norm of the difference in utility values between two iterations goes below the tolerance value. The type definition has the form:

```julia
using POMDPs # first load the POMDPs module
type QMDPSolver <: Solver
    max_iterations::Int64 # max number of iterations QMDP runs for
    tolerance::Float64 # Bellman residual: terminates when max||Ut-Ut-1|| < tolerance
end
# default constructor
QMDPSolver(;max_iterations::Int64=100, tolerance::Float64=1e-3) = QMDPSolver(max_iterations, tolerance)
```

Note that the QMDPSolver inherits from the abstract Solver type that's part of POMDPs.jl.

Now, let's define a policy type. In general, the policy should contain all the information needed to map a belief to an action. As mentioned earlier, we need alpha vectors to be part of our policy. We can represent the alpha vectors using a matrix of size $|\mathcal{S}| \times |\mathcal{A}|$. Recall that in POMDPs.jl, the actions can be represented in a number of ways (Int64, concrete types, etc), so we need a way to map these actions to integers so we can index into our alpha matrix. The type looks like:

```julia
using POMDPModelTools # for ordered_actions

type QMDPPolicy <: Policy
    alphas::Matrix{Float64} # matrix of alpha vectors |S|x|A|
    action_map::Vector{Any} # maps indices to actions
    pomdp::POMDP            # models for convenience
end
# default constructor
function QMDPPolicy(pomdp::POMDP)
    ns = n_states(pomdp)
    na = n_actions(pomdp)
    alphas = zeros(ns, na)
    am = Any[]
    space = ordered_actions(pomdp)
    for a in iterator(space)
        push!(am, a)
    end
    return QMDPPolicy(alphas, am, pomdp)
end
```

Now that we have our solver and policy types, we can write the solve function to compute the policy.

## Writing the Solve Function

The solve function takes in a solver, a POMDP, and an optional policy argument. Let's compute those alpha vectors!

```julia
function POMDPs.solve(solver::QMDPSolver, pomdp::POMDP)

    policy = QMDPPolicy(pomdp)

    # get solver parameters
    max_iterations = solver.max_iterations
    tolerance = solver.tolerance
    discount_factor = discount(pomdp)

    # intialize the alpha-vectors
    alphas = policy.alphas

    # initalize space
    sspace = ordered_states(pomdp)  # returns a discrete state space object of the pomdp
    aspace = ordered_actions(pomdp) # returns a discrete action space object

    # main loop
    for i = 1:max_iterations
        residual = 0.0
        # state loop
        for (istate, s) in enumerate(sspace)
            old_alpha = maximum(alphas[istate,:]) # for residual
            max_alpha = -Inf
            # action loop
            # alpha(s) = R(s,a) + discount_factor * sum(T(s'|s,a)max(alpha(s'))
            for (iaction, a) in enumerate(aspace)
                # the transition function modifies the dist argument to a distribution availible from that state-action pair
                dist = transition(pomdp, s, a) # fills distribution over neighbors
                q_new = 0.0
                for sp in iterator(dist)
                    # pdf returns the probability mass of sp in dist
                    p = pdf(dist, sp)
                    p == 0.0 ? continue : nothing # skip if zero prob
                    # returns the reward from s-a-sp triple
                    r = reward(pomdp, s, a, sp)
    
                    # stateindex returns an integer
                    sidx = stateindex(pomdp, sp)
                    q_new += p * (r + discount_factor * maximum(alphas[sidx,:]))
                end
                new_alpha = q_new
                alphas[istate, iaction] = new_alpha
                new_alpha > max_alpha ? (max_alpha = new_alpha) : nothing
            end # actiom
            # update the value array
            diff = abs(max_alpha - old_alpha)
            diff > residual ? (residual = diff) : nothing
        end # state
        # check if below Bellman residual
        residual < tolerance ? break : nothing
    end # main
    # return the policy
    policy
end
```

At each iteration, the algorithm iterates over the state space and computes an alpha vector for each action. There is a check at the end to see if the Bellman residual has been satisfied. The solve function assumes the following POMDPs.jl functions are implemented by the user of QMDP:

```julia
states(pomdp) # (in ordered_states) returns a state space object of the pomdp
actions(pomdp) # (in ordered_actions) returns the action space object of the pomdp
transition(pomdp, s, a) # returns the transition distribution for the s, a pair
reward(pomdp, s, a, sp) # returns real valued reward from s, a, sp triple
pdf(dist, sp) # returns the probability of sp being in dist
stateindex(pomdp, sp) # returns the integer index of sp (for discrete state spaces)
```

Now that we have a solve function, we define the [`action`](@ref) function to let users evaluate the policy:

```julia
using LinearAlgebra

function POMDPs.action(policy::QMDPPolicy, b::DiscreteBelief)
    alphas = policy.alphas
    ihi = 0
    vhi = -Inf
    (ns, na) = size(alphas)
    @assert length(b.b) == ns "Length of belief and alpha-vector size mismatch"
    # see which action gives the highest util value
    for ai = 1:na
        util = dot(alphas[:,ai], b.b)
        if util > vhi
            vhi = util
            ihi = ai
        end
    end
    # map the index to action
    return policy.action_map[ihi]
end
```

## Belief Updates

Let's now talk about how we deal with beliefs. Since QMDP is a discrete POMDP solver, we can assume that the user will represent their belief as a probablity distribution over states. That means that we can also use a discrete belief to work with our policy!
Lucky for us, the JuliaPOMDP organization contains tools that we can use out of the box for working with discrete beliefs. The POMDPToolbox package contains a `DiscreteBelief` type that does exactly what we need. The [`updater`](@ref) function allows us to declare that the `DiscreteUpdater` is the default updater to be used with a QMDP policy:

```julia
using BeliefUpdaters # remeber to load the package that implements discrete beliefs for us
POMDPs.updater(p::QMDPPolicy) = DiscreteUpdater(p.pomdp) 
```
These are all the functions that you'll need to have a working POMDPs.jl solver. Let's now use existing benchmark models to evaluate it.

## Evaluating the Solver

We'll use the POMDPModels package from JuliaPOMDP to initialize a Tiger POMDP problem and solve it with QMDP.

```julia
using POMDPModels
using POMDPSimulators

# initialize model and solver
pomdp = TigerPOMDP()
solver = QMDPSolver()

# compute the QMDP policy
policy = solve(solver, pomdp)

# initalize updater and belief
b_up = updater(policy)
init_dist = initialstate_distribution(pomdp)

# create a simulator object for recording histories
sim_hist = HistoryRecorder(max_steps=100)

# run a simulation
r = simulate(sim_hist, pomdp, policy, b_up, init_dist)
```

That's all you need to define a solver and evaluate its performance!

## Defining Requirements

If you share your solver, in order to make it easy to use, specifying requirements as described [here](@ref specifying_requirements) is highly recommended.

\[1\] *Decision Making Under Uncertainty: Theory and Application* by
Mykel J. Kochenderfer, MIT Press, 2015
























