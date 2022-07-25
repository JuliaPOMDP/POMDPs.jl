POMDPTools.render(m::BabyPOMDP, step) = string(step)

ds = DisplaySimulator(max_steps=2,
                      extra_initial=true,
                      extra_final=true,
                      rng=MersenneTwister(4))
m = BabyPOMDP()
@test simulate(ds, m, Starve()) ≈ 0.0

POMDPTools.render(m::SimpleGridWorld, step::Union{NamedTuple,Dict}) = string(step)

ds = DisplaySimulator(max_steps=1,
                      extra_initial=true,
                      extra_final=true,
                      rng=MersenneTwister(4))
m = SimpleGridWorld()
@test simulate(ds, m, FunctionPolicy(s->first(actions(m)))) ≈ 0.0
