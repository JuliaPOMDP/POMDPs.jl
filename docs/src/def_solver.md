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

Before thinking about how we can compute a policy, let us first think of how we can write the optimal value function for a
POMDP. Recall that in an MDP, the optimal value function simply represents the maximum expected utility from a given state. The idea is similar in a POMDP, but now we can think of the optimal value function with respect to a belief, and not just a single state. Since our belief is a probability distribution over the states, we can write the value function as follows:

$U^{*}(b) = \max_{a} \sum_{s} b(s)R(s,a)$

If we let $\alpha_{a}$ represent $R(:,a)$ as a vector, and $b$ represent our distribution over state (i.e. belief),
then we can write above as

$U^{*}(b) = \max_{a} \alpha_{a}^{T}b$

The $\alpha_{a}$ in the equation above is what's often called an alpha vector. These alpha vectors can be though of as
compact representations of a POMDP policy. Just as in an MDP, we often want to compute the Q-matrix, in a POMDP, we
want to compute these alpha vectors. Note that an alpha vectors can be though of as a part of a piecewise linear and
convex approximation to a POMDP value function (which is itself convex). Also note that using $R(:,a)$ as an
approximation for an alpha vectors will often give you a very poor approximation. So now that we know that we must
compute these alpha vectors, how do we do it?


## QMDP Algorithm

One of the simplest algorithms for
computing these alpha vectors is known as QMDP. It uses the Q-matrix $Q(s,a)$ obtained by solving the MDP associated with
the POMDP, and setting each alpha vector equal to the columns of that matrix $\alpha_{a} = Q(:, s)$. If you are familiar
with the value iteration algorithm for MDPs, the procedure for finding these alpha vectors is identical. Let's first
initialize the alpha vectors $\alpha_{a}^{0} = 0$ for all $s$, and then iterate

$\alpha_{a}^{k+1}(s) = R(s,a) + \gamma \sum_{s'} T(s'|s,a) \max_{a'} \alpha_{a'}^{k}(s')$

After enough iterations, the alpha vectors converge to the QMDP approximation.

Remember that QMDP is just an approximation method, and does not guarantee that the alpha vectors you obtain actually
represent your POMDP value function. Specifically, QMDP has trouble in problems with information gathering actions
(because we completely ignored the observation function when computing our policy). However, QMDP works very well in problems where a particular choice of action has
little impact on the reduction in state uncertainty.


## Requirements for a Solver

Before getting into the implementation details, let's first go through what a POMDP solver must be able to do and support. We need three custom types that inherit from abstract types in POMDPs.jl. These type are Solver, Policy, and Updater. It is usaully useful to have a custom type that represents the belief used by your policy as well.

The requirements are as follows:

```julia
# types
QMDPSolver
QMDPPolicy
DiscreteUpdater # already implemented for us in POMDPToolbox
DiscreteBelief # already implemented for us in POMDPToolbox
# methods
create_policy(solver::QMDPSolver, pomdp::POMDP) # initalizes a QMDP policy
create_belief(up::DiscreteUpdater) # initializes a QMDP belief
updater(p::QMDPPolicy) # initializes a QMDP belief udpater
initialize_belief(bu::QMDPUpdater, initial_state_dist::AbstractDistribution) # returns a QMDP belief
solve(solver::QMDPSolver, pomdp::POMDP) # solver the POMDP and returns a policy
update{A,O}(bu::DiscreteUpdater, belief_old::DiscreteBelief, action::A, obs::O) # returns an updated belied (already implemented)
action(policy::QMDPPolicy, b::DiscreteBelief) # returns a QMDP action
```

You can find the implementations of these types and methods below.


## Defining the Solver and Policy Types

Let's first define the Solver type. The QMDP solver type should contain all the information needed to compute a policy (other than the problem itself). This information can be though of as the hyperparameters of the solver. In QMDP, we only need two hyper-parameters. We may want to set the maximum number of iterations that the algorithm runs for, and a tolerance value (also known as the Bellman residual). Both of these quantities define terminating criteria for the algorithm. The algorithm stops either when the maximum number of iterations has been reached or when the infinity norm of the diference in utility values between two iterations goes below the tolerance value. The type definition has the form:

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

Now, let's define a policy type. In general, the policy should contain all the information needed to map a belief to an action. As mentioned earlier, we need alpha vectors to be part of our policy. We can represent the alpha vectors using a matrix of size $\mathcal{S} \times \mathcal{A}$. Recall that in POMDPs.jl, the actions can be represented in a number of ways (Int64, concrete types, etc), so we need a way to map these actions to integers so we can index into our alpha matrix. The type looks like:

```julia
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
    space = actions(pomdp)
    for a in iterator(space)
        push!(am, a)
    end
    return QMDPPolicy(alphas, am, pomdp)
end
# initalization function (required by POMDPs.jl)
POMDPs.create_policy(solver::QMDPSolver, pomdp::POMDP) = QMDPPolicy(pomdp)
```

Now that we have our solver and policy types, we can write the solve function to compute the policy.


## Writing the Solve Function

The solve function takes in a solver, a POMDP, and an optional policy argument. Let's compute those alpha vectors!

```julia
function POMDPs.solve(solver::QMDPSolver, pomdp::POMDP, policy::QMDPPolicy=create_policy(solver, pomdp))

    # get solver parameters
    max_iterations = solver.max_iterations
    tolerance = solver.tolerance
    discount_factor = discount(pomdp)

    # intialize the alpha-vectors
    alphas = policy.alphas

    # pre-allocate the transtion distirbution and the interpolants
    # we use the POMDPs.jl function for initializing a transition distribution
    dist = create_transition_distribution(pomdp)

    # initalize space
    sspace = states(pomdp)  # returns a discrete state space object of the pomdp
    aspace = actions(pomdp) # returns a discrete action space object

    # main loop
    for i = 1:max_iterations
        residual = 0.0
        # state loop
        # the iterator function returns an iterable object (array, iterator, etc) over a discrete space
        for (istate, s) in enumerate(iterator(sspace))
            old_alpha = maximum(alphas[istate,:]) # for residual
            max_alpha = -Inf
            # action loop
            # alpha(s) = R(s,a) + discount_factor * sum(T(s'|s,a)max(alpha(s'))
            for (iaction, a) in enumerate(iterator(aspace))
                # the transition function modifies the dist argument to a distribution availible from that state-action pair
                dist = transition(pomdp, s, a, dist) # fills distribution over neighbors
                q_new = 0.0
                for sp in iterator(sspace)
                    # pdf returns the probability mass of sp in dist
                    p = pdf(dist, sp)
                    p == 0.0 ? continue : nothing # skip if zero prob
                    # returns the reward from s-a-sp triple
                    r = reward(pomdp, s, a, sp)
    
                    # state_index returns an integer
                    sidx = state_index(pomdp, sp)
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

At each iteration, the algorithm iterates over the state space and computes an alpha vector for each action. There is a check at the end to see if the Bellman residual has been statisfied. The solve function assumes the following POMDPs.jl functions are implemented by the user of QMDP:

```julia
create_transition_distribution(pomdp) # initializes a transition distribution that we can sample and call pdf on
states(pomdp) # returns a state space object of the pomdp
actions(pomdp) # returns the action space object of the pomdp
iterator(space) # returns an iterable object (array or iterator), used for discrete spaces only
transition(pomdp, s, a, dist) # modifies and returns dist (optional argument) to be the transition distribution for the s, a pair
reward(pomdp, s, a, sp) # returns real valued reward from s, a, sp triple
pdf(dist, sp) # returns the probability of sp being in dist
state_index(pomdp, sp) # returns the integer index of sp (for discrete state spaces)
```

Now that we have a solve function, let's let users interface with our policy.

## Creating an Updater

Let's now talk about how we deal with beliefs. Since QMDP is a discrete POMDP solver, we can assume that the user will represent their belief as a probaiblity distribution over states. That means that we can also use a discrete belief to work with our policy!
Lucky for us, the JuliaPOMDP organization contains tools that we can use out of the box for working with discrete beliefs. The POMDPToolbox package conatins a DiscreteBelief type that does exactly what we need. Let's define the helper functions the deal with beliefs and updaters:

```julia
using POMDPToolbox # remeber to load the package that implements discrete beliefs for us
POMDPs.create_belief(bu::DiscreteUpdater) = DiscreteBelief(n_states(bu.du.pomdp)) # initializes a QMDP belief
POMDPs.updater(p::QMDPPolicy) = DiscreteUpdater(p.pomdp) # initialize the QMDP updater
```

Now we need a function that turns the initial distribution over state of the POMDP to our discrete belief.

```julia
function POMDPs.initialize_belief(bu::DiscreteUpdater, initial_state_dist::AbstractDistribution, new_belief::QMDPBelief=create_belief(bu))
    pomdp = bu.du.pomdp
    for (si, s) in enumerate(iterator(states(pomdp)))
        new_belief.b[si] = pdf(initial_state_dist, s) # DiscreteBelief has a field called b which is an array of probabilities
    end
    return new_belief
end
```

The function above assumes that the `initial_state_dist` is a distribution that implements a pdf function.

Lastly, let's define the action function which maps the belief to an action using the QMDP policy.

```julia
function POMDPs.action(policy::QMDPPolicy, b::QMDPBelief)
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

These are all the functions that you'll need to have a working POMDPs.jl solver. Let's now use existing benchmark models to evaluate it.


## Evaluating the Solver

We'll use the POMDPModels package from JuliaPOMDP to initialize a Tiger POMDP problem and solve it with QMDP.

```julia
using POMDPModels

# initialize model and solver
pomdp = TigerPOMDP()
solver = QMDPSolver()

# compute the QMDP policy
policy = solve(solver, pomdp)

# initalize updater and belief
b_up = updater(policy)
b = initialize_belief(b_up, initial_state_dist(pomdp)

# create a simulator object for recording histories
sim_hist = HistoryRecorder(max_steps=100)

# run a simulation
r = simulate(sim_hist, pomdp, policy, b_up, b)
```

That's all you need to define a solver and evaluate its performance!






















