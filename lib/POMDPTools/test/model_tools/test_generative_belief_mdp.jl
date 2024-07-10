let
    @testset "GenerativeBeliefMDP" begin
        @testset "Baby" begin
            pomdp = BabyPOMDP()
            up = updater(pomdp)

            bmdp = GenerativeBeliefMDP(pomdp, up)
            b = rand(initialstate(bmdp))
            @test rand(b) isa statetype(pomdp)

            @test simulate(RolloutSimulator(max_steps=10), bmdp, RandomPolicy(bmdp)) <= 0
        end

        terminal_test_m = QuickPOMDP(
            states = 1:2,
            actions = 1:2,
            observations = 1:2,
            transition = (s, a) -> Deterministic(1),
            observation = (a, sp) -> Deterministic(sp),
            reward = s -> 0.0,
            isterminal = ==(1),
            initialstate = Deterministic(2)
        )

        @testset "Terminal Default" begin
            up = DiscreteUpdater(terminal_test_m)
            bm = GenerativeBeliefMDP(terminal_test_m, up)

            hist = collect(stepthrough(bm, RandomPolicy(bm), "s,sp", max_steps=10))
            @test length(hist) == 1
            @test only(hist).s == DiscreteBelief(terminal_test_m, [0.0, 1.0])
            @test only(hist).sp == DiscreteBelief(terminal_test_m, [1.0, 0.0])
            @test !isterminal(bm, only(hist).s)
            @test isterminal(bm, only(hist).sp)
        end

        @testset "Terminal Uninformative Update" begin
            struct UninformativeUpdater{M} <: Updater
                m::M
            end

            POMDPs.update(up::UninformativeUpdater, b, a, o) = Uniform(states(up.m))
            POMDPs.initialize_belief(up::UninformativeUpdater, d::Deterministic) = Uniform(rand(d))

            up = UninformativeUpdater(terminal_test_m)

            # default terminal behavior
            bm = GenerativeBeliefMDP(terminal_test_m, up)
            hist = collect(stepthrough(bm, RandomPolicy(bm), "s,sp"))
            @test isterminal(bm, last(hist).sp)

            behavior = TerminalStateTerminalBehavior()
            bm = GenerativeBeliefMDP(terminal_test_m, up)
            hist = collect(stepthrough(bm, RandomPolicy(bm), "s,sp"))
            @test last(hist).sp === terminalstate
            @test isterminal(bm, last(hist).sp)

            behavior = ContinueTerminalBehavior(terminal_test_m, up)
            bm = GenerativeBeliefMDP(terminal_test_m, up, terminal_behavior=behavior)
            hist = collect(stepthrough(bm, RandomPolicy(bm), "s,sp", max_steps=10))
            @test length(hist) == 10
        end

    end
end
