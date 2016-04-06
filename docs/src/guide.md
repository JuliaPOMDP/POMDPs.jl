# Package Guide 

## Installation

The package can be installed by cloning the code from the github repository
[POMDPs.jl](https://github.com/JuliaPOMDP/POMDPs.jl)

Installation with POMDPs.jl:
```julia
Pkg.clone("https://github.com/JuliaPOMDP/POMDPs.jl.git")
```

The package is currently not registered in meta-data. 

## Usage

POMDPs serves as the interface used by a number of packages under the [JuliaPOMDP]() framework. It is essentially the
agreed upon API used by all the other packages in JuliaPOMDP. If you are using this framework, you may be trying to
accomplish one or more of the following three goals:

- Solve a decision or planning problem with stochastic dynamics (MDP) or partial observability (POMDP)
- Evaluate a solution in simulation
- Test your custom algorithm for solving MDPs or POMDPs against other state-of-the-art algorithms

If you are attempting to complete the first two goals, take a look at these Jupyer Notebook tutorials:

* [MDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/GridWorld.ipynb) for beginners gives an overview of using Value Iteration and Monte-Carlo Tree Search with the classic grid world problem
* [POMDP Tutorial](http://nbviewer.ipython.org/github/sisl/POMDPs.jl/blob/master/examples/Tiger.ipynb) gives an overview of using SARSOP and QMDP to solve the tiger problem

If you are trying to write your own algorithm for solving MDPs or POMDPs with this interface take a look at the API
section of this guide. 

## Example Simulation Implementation


This reference simulation implementation shows how the various functions will be used. Please note that this example is
written for clarity and not efficiency.

```julia
type ReferenceSimulator
    rng::AbstractRNG
    max_steps
end

function simulate(simulator::ReferenceSimulator, pomdp::POMDP, policy::Policy, updater::BeliefUpdater, initial_belief::Belief)

    s = create_state(pomdp)
    o = create_observation(pomdp)
    rand(sim.rng, initial_belief, s)
    
    b = convert_belief(updater, initial_belief)

    step = 1
    disc = 1.0
    r = 0.0

    while step <= sim.max_steps && !isterminal(pomdp, s)
        a = action(policy, b)

        sp = create_state(pomdp)
        trans_dist = transition(pomdp, s, a)
        rand(sim.rng, trans_dist, sp)

        r += disc*reward(pomdp, s, a, sp)

        obs_dist = observation(pomdp, s, a, sp)
        rand(sim.rng, obs_dist, o)

        b = update(updater, b, a, o)

        s = sp
        disc *= discount(pomdp)
        step += 1
    end

end

```
