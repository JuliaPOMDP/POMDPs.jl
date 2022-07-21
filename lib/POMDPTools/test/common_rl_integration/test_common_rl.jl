const RL = CommonRLInterface

@testset "MDP to Env" begin
    struct RLTestMDP <: MDP{Int, Int} end

    POMDPs.actions(m::RLTestMDP) = [-1, 1]
    POMDPs.transition(m::RLTestMDP, s, a) = Deterministic(clamp(s + a, 1, 3))
    POMDPs.initialstate(m::RLTestMDP) = Deterministic(1)
    POMDPs.isterminal(m::RLTestMDP, s) = s == 3
    POMDPs.reward(m::RLTestMDP, s, a, sp) = sp

    env = convert(RL.AbstractEnv, RLTestMDP())

    @test !RL.provided(RL.observations, env)
    POMDPs.states(m::RLTestMDP) = 1:3
    @test RL.provided(RL.observations, env)
    @test all(only.(RL.observations(env)) .== states(RLTestMDP()))

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

    @test convert(MDP, env) isa RLTestMDP
end

@testset "POMDP to Env" begin
    struct RLTestPOMDP <: POMDP{Int, Int, Int} end

    POMDPs.actions(m::RLTestPOMDP) = [-1, 1]
    POMDPs.states(m::RLTestPOMDP) = 1:3
    POMDPs.transition(m::RLTestPOMDP, s, a) = Deterministic(clamp(s + a, 1, 3))
    POMDPs.observation(m::RLTestPOMDP, s, a, sp) = Deterministic(sp + 1)
    POMDPs.initialstate(m::RLTestPOMDP) = Deterministic(1)
    POMDPs.initialobs(m::RLTestPOMDP, s) = Deterministic(s + 1)
    POMDPs.isterminal(m::RLTestPOMDP, s) = s == 3
    POMDPs.reward(m::RLTestPOMDP, s, a, sp) = sp

    env = convert(RL.AbstractEnv, RLTestPOMDP())

    @test !RL.provided(RL.observations, env)
    POMDPs.observations(m::RLTestPOMDP) = 2:4
    @test RL.provided(RL.observations, env)
    @test all(only.(RL.observations(env)) .== observations(RLTestPOMDP()))


    @test RL.actions(env) == [-1, 1]
    @test RL.valid_actions(env) == [-1, 1]
    @test RL.observe(env) == [2]
    @test RL.state(env) == (1,2)
    RL.setstate!(env, RL.state(env))
    @test RL.act!(env, 1) == 2
    @test !RL.terminated(env)

    RL.reset!(env)
    @test RL.observe(env) == [2]
    @test RL.act!(env, 1) == 2
    @test RL.act!(env, 1) == 3
    @test RL.observe(env) == [4]
    @test RL.terminated(env)

    RL.setstate!(env, (2,3))
    @test RL.observe(env) == [3]

    env2 = RL.clone(env)
    @test RL.act!(env2, 1) == 3
    @test RL.observe(env2) == [4]
    @test RL.observe(env) == [3]

    @test convert(POMDP, env) isa RLTestPOMDP
end

@testset "Env to MDP" begin
    mutable struct MDPEnv <: RL.AbstractEnv
        s::Int
    end

    RL.reset!(env::MDPEnv) = env.s = 1
    RL.actions(env::MDPEnv) = [-1, 1]
    RL.observe(env::MDPEnv) = [env.s]
    RL.terminated(env::MDPEnv) = env.s >= 3
    function RL.act!(env::MDPEnv, a)
        r = env.s
        env.s = max(1, env.s + a)
        return r
    end

    m1 = convert(MDP, MDPEnv(1))
    @test m1 isa OpaqueRLEnvMDP
    @test simulate(RolloutSimulator(), m1, FunctionPolicy(s->1)) == 3.0

    RL.@provide RL.state(env::MDPEnv) = env.s
    RL.@provide RL.setstate!(env::MDPEnv, s) = env.s = s

    env = MDPEnv(1)
    m2 = convert(MDP, env)
    @test m2 isa RLEnvMDP
    @test simulate(RolloutSimulator(), m2, FunctionPolicy(s->1)) == 3.0

    RL.setstate!(env, 1)
    @test isterminal(m2, 3)
    @test RL.state(env) == 1

    @test convert(RL.AbstractEnv, m1) isa MDPEnv
end

@testset "Env to POMDP" begin
    mutable struct POMDPEnv <: RL.AbstractEnv
        s::Int
    end

    RL.reset!(env::POMDPEnv) = env.s = 1
    RL.actions(env::POMDPEnv) = [-1, 1]
    RL.observe(env::POMDPEnv) = [env.s > 0]
    RL.terminated(env::POMDPEnv) = env.s >= 3
    function RL.act!(env::POMDPEnv, a)
        r = env.s
        env.s = max(1, env.s + a)
        return r
    end

    m1 = convert(POMDP, POMDPEnv(1))
    @test m1 isa OpaqueRLEnvPOMDP
    @test simulate(RolloutSimulator(), m1, FunctionPolicy(s->1)) == 3.0

    RL.@provide RL.state(env::POMDPEnv) = env.s
    RL.@provide RL.setstate!(env::POMDPEnv, s) = env.s = s

    env = POMDPEnv(1)
    m2 = convert(POMDP, env)
    @test m2 isa RLEnvPOMDP
    @test simulate(RolloutSimulator(), m2, FunctionPolicy(s->1)) == 3.0

    RL.setstate!(env, 1)
    @test isterminal(m2, 3)
    @test RL.state(env) == 1

    @test convert(RL.AbstractEnv, m1) isa POMDPEnv
end
