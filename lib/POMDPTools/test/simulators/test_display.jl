ds = DisplaySimulator(max_steps=10,
                      extra_initial=true,
                      extra_final=true,
                      rng=MersenneTwister(4))
m = BabyPOMDP()
@test simulate(ds, m, Starve()) ≈ 0.0

ds = DisplaySimulator(max_steps=1,
                      extra_initial=true,
                      extra_final=true,
                      rng=MersenneTwister(4))
m = SimpleGridWorld()
@test simulate(ds, m, FunctionPolicy(s->first(actions(m)))) ≈ 0.0
