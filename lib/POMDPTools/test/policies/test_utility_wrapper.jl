let
    using POMDPModels

    mdp = LegacyGridWorld()
    policy = RandomPolicy(mdp)
    counts = Dict(a=>0 for a in actions(mdp))

    # with a payload
    statswrapper = PolicyWrapper(policy, payload=counts) do policy, counts, s
        a = action(policy, s)
        counts[a] += 1
        return a
    end

    h = simulate(HistoryRecorder(max_steps=100), mdp, statswrapper)
    for (a, count) in payload(statswrapper)
        println("policy chose action $a $count of $(n_steps(h)) times.")
    end

    # without a payload
    errwrapper = PolicyWrapper(policy) do policy, s
        a = try
            a = action(policy, s)
        catch ex
            @warn("Caught error in policy; using default")
            a = :left
        end
        return a
    end

    h = simulate(HistoryRecorder(max_steps=100), mdp, errwrapper)
end
