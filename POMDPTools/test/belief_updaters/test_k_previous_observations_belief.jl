using POMDPs
using POMDPModels
using Test


function test_initial_belief(b0, o0)
    for i=1:5
        if b0[i] != o0
            return false
        end
    end
    return true
end

function test_hist(belief_hist)
    for i=1:length(belief_hist)-1
        if hist.belief_hist[i][2:end] != hist.belief_hist[i+1][1:end-1]
            return false
        end
    end
    return true
end


rng = MersenneTwister(0)
pomdp = RandomPOMDP()

# test constructor
up = KMarkovUpdater(5)

o0 = rand(rng, observations(pomdp))
b0 = initialize_belief(up, fill(o0, up.k))

@test typeof(b0[1]) == typeof(o0)
@test length(b0) == up.k == 5
@test test_initial_belief(b0, o0)

# generate random observation and stack them
o = rand(rng, observations(pomdp))
b = b0
bp = update(up, b, rand(rng, actions(pomdp)), o)
@test bp[end] == o
@test length(bp) == up.k == 5
@test bp[1:end-1] == fill(o0, length(bp)-1)
@test history(bp)[end].o == currentobs(bp)

# check that b is unchanged
@test b == initialize_belief(up, fill(o0, up.k))

b = bp
op = rand(rng, observations(pomdp))
bp = update(up, bp, rand(rng, actions(pomdp)), op)
@test bp[end] == op
@test bp[end-1] == o
@test length(bp) == up.k == 5
@test bp[1:end-2] == fill(o0, length(bp)-2)

# test with history recorder
pomdp = BabyPOMDP()
s0 = rand(rng, initialstate(pomdp))
# o0 = initialobs(pomdp, s0, rng)
o0 = rand(rng, initialobs(pomdp, s0)) # for POMDPs 0.9

initial_obs_vec = fill(o0, up.k)
@test_throws ErrorException initialize_belief(up, o0)
@test_throws ErrorException initialize_belief(up, fill(o0, up.k-1))
@test_throws ErrorException update(up, initial_obs_vec, rand(rng, actions(pomdp)), 1.0)


# solver = RandomSolver(rng=rng)
# policy = solve(solver, pomdp)
# hist = simulate(hr, pomdp, policy, up, initial_obs_vec, s0)
# @test hist.belief_hist[1] == fill(o0, up.k)
# @test test_hist(hist.belief_hist)
# @test_throws ErrorException simulate(hr, pomdp, policy, up)
