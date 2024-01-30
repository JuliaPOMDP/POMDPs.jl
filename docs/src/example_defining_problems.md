# Defining a POMDP
As mentioned in the [Defining POMDPs and MDPs](@ref defining_pomdps) section, there are verious ways to define a POMDP using POMDPs.jl. In this section, we provide more examples of how to define a POMDP using the different interfaces.

There is a large variety of problems that can be expressed as MDPs and POMDPs and different solvers require different components of the POMDPs.jl interface to be defined. Therefore, these examples are not intended to cover all possible use cases. When deeloping a problem and you have an idea of what solver(s) you would like to use, it is recommended to use [POMDPLinter](https://github.com/JuliaPOMDP/POMDPLinter.jl) to help you to determine what components of the POMDPs.jl interface need to be defined. Reference the [Checking Requirements](@ref) section for an example of using POMDPLinter.

## CryingBaby Problem Definition
For the examples, we will use the CryingBaby problem from [Algorithms for Decision Making](https://algorithmsbook.com/) by Mykel J. Kochenderfer, Tim A. Wheeler, and Kyle H. Wray.

!!! note 
    This craying baby problem follows the description in Algorithms for Decision Making and is different than `BabyPOMDP` defined in [POMDPModels.jl](https://github.com/JuliaPOMDP/POMDPModels.jl).

From [Appendix F](https://algorithmsbook.com/files/appendix-f.pdf) of Algorithms for Decision Making:
> The crying baby problem is a simple POMDP with two states, three actions, and two observations. Our goal is to care for a baby, and we do so by choosing at each time step whether to feed the baby, sing to the baby, or ignore the baby.
> 
> The baby becomes hungry over time. We do not directly observe whether the baby is hungry; instead, we receive a noisy observation in the form of whether the baby is crying. The state, action, and observation spaces are as follows:
> ```math 
> \begin{align*}
> \mathcal{S} &= \{\text{sated}, \text{hungry} \}\\
> \mathcal{A} &= \{\text{feed}, \text{sing}, \text{ignore} \} \\
> \mathcal{O} &= \{\text{crying}, \text{quiet} \}
> \end{align*}
> ```
>
> Feeding will always sate the baby. Ignoring the baby risks a sated baby becoming hungry, and ensures that a hungry baby remains hungry. Singing to the baby is an information-gathering action with the same transition dynamics as ignoring, but without the potential for crying when sated (not hungry) and with an increased chance of crying when hungry.
>
> The transition dynamics are as follows:
> ```math 
> \begin{align*}
> & T(\text{sated} \mid \text{hungry}, \text{feed}) = 100\% \\
> & T(\text{hungry} \mid \text{hungry}, \text{sing}) = 100\% \\
> & T(\text{hungry} \mid \text{hungry}, \text{ignore}) = 100\% \\
> & T(\text{sated} \mid \text{sated}, \text{feed}) = 100\% \\
> & T(\text{hungry} \mid \text{sated}, \text{sing}) = 10\% \\
> & T(\text{hungry} \mid \text{sated}, \text{ignore}) = 10\%
> \end{align*}
> ```
> 
> The observation dynamics are as follows:
> ```math 
> \begin{align*}
> & O(\text{crying} \mid \text{feed}, \text{hungry}) = 80\% \\
> & O(\text{crying} \mid \text{sing}, \text{hungry}) = 90\% \\
> & O(\text{crying} \mid \text{ignore}, \text{hungry}) = 80\% \\
> & O(\text{crying} \mid \text{feed}, \text{sated}) = 10\% \\
> & O(\text{crying} \mid \text{sing}, \text{sated}) = 0\% \\
> & O(\text{crying} \mid \text{ignore}, \text{sated}) = 10\% 
> \end{align*}
> ```
> 
> The reward function assigns ``−10`` reward if the baby is hungry, independent of the action taken. The effort of feeding the baby adds a further ``−5`` reward, whereas singing adds ``−0.5`` reward. As baby caregivers, we seek the optimal infinite-horizon policy with discount factor ``\gamma = 0.9``. 

## [QuickPOMDP Interface](@id quick_crying)
```julia
using POMDPs
using POMDPTools
using QuickPOMDPs

quick_crying_baby_pomdp = QuickPOMDP(
    states = [:sated, :hungry],
    actions = [:feed, :sing, :ignore],
    observations = [:quiet, :crying],
    initialstate = Deterministic(:sated),
    discount = 0.9,
    transition = function (s, a)
        if a == :feed
            return Deterministic(:sated)
        elseif s == :sated # :sated and a != :feed
            return SparseCat([:sated, :hungry], [0.9, 0.1])
        else # s == :hungry and a != :feed
            return Deterministic(:hungry)
        end
    end,
    observation = function (a, sp)
        if sp == :hungry
            if a == :sing
                return SparseCat([:crying, :quiet], [0.9, 0.1])
            else # a == :ignore || a == :feed
                return SparseCat([:crying, :quiet], [0.8, 0.2])
            end
        else # sp = :sated
            if a == :sing
                return Deterministic(:quiet)
            else # a == :ignore || a == :feed
                return SparseCat([:crying, :quiet], [0.1, 0.9])
            end
            
        end
    end,
    reward = function (s, a)
        r = 0.0
        if s == :hungry
            r += -10.0
        end
        if a == :feed
            r += -5.0
        elseif a == :sing
            r+= -0.5
        end
        return r
    end
)
```

## [Explicit Interface](@id explicit_crying)
```julia
using POMDPs
using POMDPTools

struct CryingBabyState
    hungry::Bool
end

struct CryingBabyPOMDP <: POMDP{CryingBabyState, Symbol, Symbol}
    p_sated_to_hungry::Float64
    p_cry_feed_hungry::Float64
    p_cry_sing_hungry::Float64
    p_cry_ignore_hungry::Float64
    p_cry_feed_sated::Float64
    p_cry_sing_sated::Float64
    p_cry_ignore_sated::Float64
    reward_hungry::Float64
    reward_feed::Float64
    reward_sing::Float64
    discount_factor::Float64
end

function CryingBabyPOMDP(;
    p_sated_to_hungry=0.1,
    p_cry_feed_hungry=0.8,
    p_cry_sing_hungry=0.9,
    p_cry_ignore_hungry=0.8,
    p_cry_feed_sated=0.1,
    p_cry_sing_sated=0.0,
    p_cry_ignore_sated=0.1,
    reward_hungry=-10.0,
    reward_feed=-5.0,
    reward_sing=-0.5,
    discount_factor=0.9
)
    return CryingBabyPOMDP(p_sated_to_hungry, p_cry_feed_hungry,
        p_cry_sing_hungry, p_cry_ignore_hungry, p_cry_feed_sated,
        p_cry_sing_sated, p_cry_ignore_sated, reward_hungry,
        reward_feed, reward_sing, discount_factor)
end

POMDPs.actions(::CryingBabyPOMDP) = [:feed, :sing, :ignore]
POMDPs.states(::CryingBabyPOMDP) = [CryingBabyState(false), CryingBabyState(true)]
POMDPs.observations(::CryingBabyPOMDP) = [:crying, :quiet]
POMDPs.stateindex(::CryingBabyPOMDP, s::CryingBabyState) = s.hungry ? 2 : 1
POMDPs.obsindex(::CryingBabyPOMDP, o::Symbol) = o == :crying ? 1 : 2
POMDPs.actionindex(::CryingBabyPOMDP, a::Symbol) = a == :feed ? 1 : a == :sing ? 2 : 3

function POMDPs.transition(pomdp::CryingBabyPOMDP, s::CryingBabyState, a::Symbol)
    if a == :feed
        return Deterministic(CryingBabyState(false))
    elseif s == :sated # :sated and a != :feed
        return SparseCat([CryingBabyState(false), CryingBabyState(true)], [1 - pomdp.p_sated_to_hungry, pomdp.p_sated_to_hungry])
    else # s == :hungry and a != :feed
        return Deterministic(CryingBabyState(true))
    end
end

function POMDPs.observation(pomdp::CryingBabyPOMDP, a::Symbol, sp::CryingBabyState)
    if sp.hungry
        if a == :sing
            return SparseCat([:crying, :quiet], [pomdp.p_cry_sing_hungry, 1 - pomdp.p_cry_sing_hungry])
        elseif a== :ignore
            return SparseCat([:crying, :quiet], [pomdp.p_cry_ignore_hungry, 1 - pomdp.p_cry_ignore_hungry])
        else # a == :feed
            return SparseCat([:crying, :quiet], [pomdp.p_cry_feed_hungry, 1 - pomdp.p_cry_feed_hungry])
        end
    else # sated
        if a == :sing
            return SparseCat([:crying, :quiet], [pomdp.p_cry_sing_sated, 1 - pomdp.p_cry_sing_sated])
        elseif a== :ignore
            return SparseCat([:crying, :quiet], [pomdp.p_cry_ignore_sated, 1 - pomdp.p_cry_ignore_sated])
        else # a == :feed
            return SparseCat([:crying, :quiet], [pomdp.p_cry_feed_sated, 1 - pomdp.p_cry_feed_sated])
        end
    end
end

function POMDPs.reward(pomdp::CryingBabyPOMDP, s::CryingBabyState, a::Symbol)
    r = 0.0
    if s.hungry
        r += pomdp.reward_hungry
    end
    if a == :feed
        r += pomdp.reward_feed
    elseif a == :sing
        r += pomdp.reward_sing
    end
    return r
end

POMDPs.discount(pomdp::CryingBabyPOMDP) = pomdp.discount_factor

POMDPs.initialstate(::CryingBabyPOMDP) = Deterministic(CryingBabyState(false))

explicit_crying_baby_pomdp = CryingBabyPOMDP()
```

## [Generative Interface](@id gen_crying)
This crying baby problem should not be implemented using the generative interface. However, this exmple is provided for pedagogical purposes.

```julia
using POMDPs
using POMDPTools
using Random

struct GenCryingBabyState
    hungry::Bool
end

struct GenCryingBabyPOMDP <: POMDP{CryingBabyState, Symbol, Symbol}
    p_sated_to_hungry::Float64
    p_cry_feed_hungry::Float64
    p_cry_sing_hungry::Float64
    p_cry_ignore_hungry::Float64
    p_cry_feed_sated::Float64
    p_cry_sing_sated::Float64
    p_cry_ignore_sated::Float64
    reward_hungry::Float64
    reward_feed::Float64
    reward_sing::Float64
    discount_factor::Float64
    
    GenCryingBabyPOMDP() = new(0.1, 0.8, 0.9, 0.8, 0.1, 0.0, 0.1, -10.0, -5.0, -0.5, 0.9)    
end

function POMDPs.gen(pomdp::GenCryingBabyPOMDP, s::CryingBabyState, a::Symbol, rng::AbstractRNG)
    
    if a == :feed
        sp = GenCryingBabyState(false)
    else 
        sp = rand(rng) < pomdp.p_sated_to_hungry ? GenCryingBabyState(true) : GenCryingBabyState(false)
    end
    
    if sp.hungry
        if a == :sing
            o = rand(rng) < pomdp.p_cry_sing_hungry ? :crying : :quiet
        elseif a== :ignore
            o = rand(rng) < pomdp.p_cry_ignore_hungry ? :crying : :quiet
        else # a == :feed
            o = rand(rng) < pomdp.p_cry_feed_hungry ? :crying : :quiet
        end
    else # sated
        if a == :sing
            o = rand(rng) < pomdp.p_cry_sing_sated ? :crying : :quiet
        elseif a== :ignore
            o = rand(rng) < pomdp.p_cry_ignore_sated ? :crying : :quiet
        else # a == :feed
            o = rand(rng) < pomdp.p_cry_feed_sated ? :crying : :quiet
        end
    end
    
    r = 0.0
    if sp.hungry
        r += pomdp.reward_hungry
    end
    if a == :feed
        r += pomdp.reward_feed
    elseif a == :sing
        r += pomdp.reward_sing
    end
    
    return (sp=sp, o=o, r=r) 
end

POMDPs.initialstate(::GenCryingBabyPOMDP) = Deterministic(GenCryingBabyState(false))

gen_crying_baby_pomdp = GenCryingBabyPOMDP()
```

## [Probability Tables](@id tab_crying)
For this implementaion we will use the following indexes:
- States
    - `:sated` = 1
    - `:hungry` = 2
- Actions
    - `:feed` = 1
    - `:sing` = 2
    - `:ignore` = 3
- Observations
    - `:crying` = 1
    - `:quiet` = 2

```julia
using POMDPModels

T = zeros(2, 3, 2) # |S| x |A| x |S'|, T[sp, a, s] = p(sp | a, s)
T[:, 1, :] = [1.0 1.0; 
              0.0 0.0]
T[:, 2, :] = [0.9 0.0; 
              0.1 1.0]
T[:, 3, :] = [0.9 0.0; 
              0.1 1.0]

O = zeros(2, 3, 2) # |O| x |A| x |S'|, O[o, a, sp] = p(o | a, sp)
O[:, 1, :] = [0.1 0.8; 
              0.9 0.2]
O[:, 2, :] = [0.0 0.9;
              1.0 0.1]
O[:, 3, :] = [0.1 0.8;
              0.9 0.2]

R = zeros(2, 3) # |S| x |A|
R = [-5.0 -0.5 0.0;
     -15.0 -10.5 0.0]
     
discount = 0.9

tabular_crying_baby_pomdp = TabularPOMDP(T, R, O, discount)
```