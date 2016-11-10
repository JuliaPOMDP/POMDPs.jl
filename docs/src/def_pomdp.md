# Defining a POMDP

The expressive nature of POMDPs.jl gives problem writers the flexiblity to write their problem in many forms. In this
section we will take a look at two ways to write a discrete problem, and a way of writing a continuous problem.

## Functional Form POMDP
Custom POMDP problems are defined by implementing the functions specified by the POMDPs api.
These functions, such as ```transition```, ```reward```, and ```observation```, capture the problem formulation and allow the problem to be used by the POMDPs solvers and simulators.

In this example we show how to implement the famous Tiger Problem.
Suppose that once implemented, we want to solve Tiger problems using the SARSOP solver.
To see what functions SARSOP needs us to implement, check out its documentation [here](#href).

In this implementation of the problem we will assume that the agent get a reward of -1 for listening at the door,
a reward of -100 for encountering the tiger, and a reward of 10 for escaping. The probability of hearing the tiger
when listing at the tiger's door is 85%, and the discount factor is a parameter in the TigerPOMDP object.

We define the Tiger POMDP type:

```julia
using POMDPs
type TigerPOMDP <: POMDP{Bool, Int64, Bool}
    discount_factor::Float64
end
TigerPOMDP() = TigerPOMDP(0.95) # default contructor
discount(pomdp::TigerPOMDP) = pomdp.discount_factor
```

Notice that the ```TigerPOMDP``` inherits from the abstract ```POMDP``` type provided by POMDPs.jl.
Our type is defined ```TigerPOMDP <: POMDP{Bool, Int64, Bool}```, indicating that our states are ```Bools```, actions are ```Int64```, and observations are ```Bool```.
In our problem there are only two states (whether the tiger is behind the left or right door), three actions (go left, go right, and listen), and two observations (hear the tiger behind the left or right door). We thus use booleans for the states and observations, and integers for the actions.
Note that states, actions, and observations can use arrays, strings, complex data structures, or even custom types.

We will now implement the state, action, and observation spaces.
There is a special ```AbstractSpace``` type in POMDPs.jl which all spaces inherit from.
We define the state, action, and observation spaces below as well as functions for intializing them and sampling from them.

```julia
# STATE SPACE
const TIGER_ON_LEFT = true
const TIGER_ON_RIGHT = false

type TigerStateSpace <: AbstractSpace end
states(::TigerPOMDP) = TigerStateSpace()
iterator(space::TigerStateSpace) = [TIGER_ON_LEFT, TIGER_ON_RIGHT]
n_states(::TigerPOMDP) = 2
dimensions(::TigerStateSpace) = 1
rand(rng::AbstractRNG, space::TigerStateSpace, s::Bool) = rand([TIGER_ON_LEFT, TIGER_ON_RIGHT]) # sample random state
create_state(::TigerPOMDP) = TIGER_ON_LEFT
state_index(::TigerPOMDP, s::Bool) = s + 1

# ACTION SPACE
const OPEN_LEFT = 0
const OPEN_RIGHT = 1
const LISTEN = 2

type TigerActionSpace <: AbstractSpace end
actions(::TigerPOMDP) = TigerActionSpace()
iterator(space::TigerActionSpace) = [OPEN_LEFT,OPEN_RIGHT,LISTEN]
n_actions(::TigerPOMDP) = 3
dimensions(::TigerActionSpace) = 1
rand(rng::AbstractRNG, space::TigerActionSpace, a::Int64) = rand(rng, [OPEN_LEFT,OPEN_RIGHT,LISTEN]) # sample random action
create_action(::TigerPOMDP) = OPEN_LEFT

# OBSERVATION SPACE
const OBSERVE_LEFT = true
const OBSERVE_RIGHT = false

type TigerObservationSpace <: AbstractSpace end
observations(::TigerPOMDP) = TigerObservationSpace()
iterator(space::TigerObservationSpace) = [OBSERVE_LEFT, OBSERVE_RIGHT]
n_observations(::TigerPOMDP) = 2
dimensions(::TigerObservationSpace) = 1
rand(rng::AbstractRNG, space::TigerObservationSpace, s::Bool) = rand([TIGER_ON_LEFT, TIGER_ON_RIGHT]) # sample random observation
create_observation(::TigerPOMDP) = OBSERVE_LEFT
```

Before we can implement the core ```transition```, ```reward```, and ```observation``` functions we need to define how distributions over states and observations work for the Tiger POMDP.
We need to sample from these distributions and compute their likelihoods.
Are states and observations are binary, so we can use Bernoulli distributions:

```julia
type TigerDistribution <: AbstractDistribution # inherits from a POMDPs.jl abstract type
    p_true::Float64
end
TigerDistribution() = TigerDistribution(0.5) # default constructor
iterator(d::TigerDistribution) = [true, false]

# returns the probability mass for discrete distributions
function pdf(d::TigerDistribution, v::Bool)
    if v
        return d.p_true
    else
        return 1 - d.p_true
    end
end

# sample from the distribution
rand(rng::AbstractRNG, d::TigerDistribution, s::Bool) = rand(rng) ≤ d.p_true

# convenient initialization functions
create_transition_distribution(::TigerPOMDP) = TigerDistribution()
create_observation_distribution(::TigerPOMDP) = TigerDistribution()
```

We can now define our transition, observation, and reward functions.
Transition and observation return the distribution over the next state and observation, and reward returns the scalar reward.

```julia
function transition(pomdp::TigerPOMDP, s::Bool, a::Int64, d::TigerDistribution=create_transition_distribution(pomdp))
    if a == OPEN_LEFT || a == OPEN_RIGHT
        d.p_true = 0.5 # reset the tiger's location, which is what SARSOP wants
    elseif s == TIGER_ON_LEFT
        d.p_true = 1.0 # tiger is on left
    else
        d.p_true = 0.0  # tiger is on right
    end
    d
end

function observation(pomdp::TigerPOMDP, a::Int64, sp::Bool, d::TigerDistribution=create_observation_distribution(pomdp))
    # obtain correct observation 85% of the time
    if a == LISTEN
        d.p_true = sp == TIGER_ON_LEFT ? 0.85 : 0.15
    else
        d.p_true = 0.5 # reset the observation - we did not listen
    end
    d
end
observation(pomdp::TigerPOMDP, s::Bool, a::Int64, sp::Bool, d::TigerDistribution=create_observation_distribution(pomdp)) =
    observation(pomdp, a, sp, d) # convenience function

function reward(pomdp::TigerPOMDP, s::Bool, a::Int64)
    # rewarded for escaping, penalized for listening and getting caught
    r = 0.0
    if a == LISTEN
        r -= 1.0 # action penalty
    elseif (a == OPEN_LEFT && s == TIGER_ON_LEFT) ||
           (a == OPEN_RIGHT && s == TIGER_ON_RIGHT)
        r -= 100.0 # eaten by tiger
    else
        r += 10.0 # opened the correct door
    end
    r
end
reward(pomdp::TigerPOMDP, s::Bool, a::Int64, sp::Bool) = reward(pomdp, s, a) # convenience function
```

The last thing we need for the Tiger POMDP is an initial distribution over the state space.
In POMDPs.jl we make a strong distinction between this distribution and a belief.
In most literature these two concepts are considered the same. However, in more general terms, a belief is something that is mapped to an action using a POMDP policy.
If the policy is represented as something other than alpha-vectors (a policy graph, tree, or a recurrent neural network to give a few examples), it
may not make sense to think of a belief as a probability distribution over the state space.
Thus, in POMDPs.jl we abstract the concept of a belief beyond a probability distribution, allowing users to use what makes the most sense.

In order to reconcile this difference, each policy has a function called ```initialize_belief``` which takes in an
initial state distirubtion and a policy, and converts the
distribution into what we call a belief in POMDPs.jl. As the problem writer we must provide ```initial_state_distribution```:

```julia
initial_state_distribution(pomdp::TigerPOMDP) = TigerDistribution(0.5)
```

We have fully defined the Tiger POMDP.
We can use now use JuliaPOMDP solvers to compute and evaluate a policy:

```julia
using QMDP, POMDPToolbox

pomdp = TigerPOMDP()
solver = QMDPSolver()
policy = solve(solver, pomdp)

init_dist = initial_state_distribution(pomdp)
hist = HistoryRecorder(max_steps=100) # from POMDPToolbox
r = simulate(hist, pomdp, policy, belief_updater, init_dist) # run 100 step simulation
```

Please note that you do not need to define all the functions for most solvers.
If you want to use a specific solver, you usually only need a subset of what is above.

## POMDPs in Tabular Form

The ```DiscretePOMDP``` problem representation allows you to specify discrete POMDP problems in tabular form.
If you can write the transition probabilities, observation probabilities, and rewards in matrix form, you can use the ```DiscreteMDP``` or
```DiscretePOMDP``` types from ```POMDPModels``` which automatically implements all required functionality.
Let us do this with the Tiger POMDP:

```julia
using POMDPModels

# write out the matrix forms

# REWARDS
R = [-1. -100 10; -1 10 -100] # |S|x|A| state-action pair rewards

# TRANSITIONS
T = zeros(2,3,2) # |S|x|A|x|S|, T[s', a, s] = p(s'|a,s)
T[:,:,1] = [1. 0.5 0.5; 0 0.5 0.5]
T[:,:,2] = [0. 0.5 0.5; 1 0.5 0.5]

# OBSERVATIONS
O = zeros(2,3,2) # |O|x|A|x|S|, O[o, a, s] = p(o|a,s)
O[:,:,1] = [0.85 0.5 0.5; 0.15 0.5 0.5]
O[:,:,2] = [0.15 0.5 0.5; 0.85 0.5 0.5]

discount = 0.95
pomdp = DiscretePOMDP(T, R, O, discount)

# solve the POMDP the same way
solver = SARSOPSolver()
policy = solve(solver, pomdp)
```

It is often easiest to define smaller problems in tabular form. However, for larger problems it can be
tedious and the functional form may be preffered. You can usually use any supported POMDP solver to sovle these types of problems (the performance of the policy may vary however - SARSOP will usually outperform QMDP).

## Continous POMDP

Within the POMDPs.jl interface, we can also define problems with continuous spaces.
There are a few solvers that can handle these types of problems, namely, MCVI and POMCP (with some tuning).

LIGHT-DARK PROBLEM HERE. WHAT SHOULD WE SAY ABOUT BOUNDS?















