const RL = CommonRLInterface

struct RLTestMDP <: MDP{Int, Int} end

POMDPs.actions(m::RLTestMDP) = [-1, 1]
POMDPs.states(m::RLTestMDP) = 1:3
POMDPs.transition(m::RLTestMDP, s, a) = Deterministic(clamp(s + a, 1, 3))
POMDPs.initialstate(m::RLTestMDP) = Deterministic(1)
POMDPs.isterminal(m::RLTestMDP, s) = s == 3
POMDPs.reward(m::RLTestMDP, s, a, sp) = sp

env = convert(RL.AbstractEnv, RLTestMDP())

@test RL.actions(env) == [-1, 1]
@test RL.valid_actions(env) == [-1, 1]
@test RL.observe(env) == [1]
@test RL.state(env) == [1]
@test RL.act!(env, 1) == 2
@test !RL.terminated(env)

RL.reset!(env)
@test RL.observe(env) == [1]
@test RL.act!(env, 1) == 2
@test RL.act!(env, 1) == 3
@test RL.observe(env) == [3]
@test RL.terminated(env)

RL.setstate!(env, [2])
@test RL.observe(env) == [2]

env2 = RL.clone(env)
@test RL.act!(env2, 1) == 3
@test RL.observe(env2) == [3]
@test RL.observe(env) == [2]
