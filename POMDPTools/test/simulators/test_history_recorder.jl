let
problem = BabyPOMDP()
policy = RandomPolicy(problem, rng=MersenneTwister(2))
steps=10
sim = HistoryRecorder(max_steps=steps, rng=MersenneTwister(3))
POMDPLinter.@show_requirements simulate(sim, problem, policy, updater(policy), initialstate_distribution(problem))
r1 = simulate(sim, problem, policy, updater(policy), initialstate_distribution(problem))
policy.rng = MersenneTwister(2)
Random.seed!(sim.rng, 3)
r2 = simulate(sim, problem, policy)

@test length(state_hist(r1)) == steps+1
@test length(action_hist(r1)) == steps
@test length(observation_hist(r1)) == steps
@test length(belief_hist(r1)) == steps+1
@test length(state_hist(r2)) == steps+1
@test length(action_hist(r2)) == steps
@test length(observation_hist(r2)) == steps
@test length(belief_hist(r2)) == steps+1
@test length(info_hist(r2)) == steps
@test length(ainfo_hist(r2)) == steps
@test length(uinfo_hist(r2)) == steps

@test exception(r1) == nothing
@test exception(r2) == nothing
@test backtrace(r1) == nothing
@test backtrace(r2) == nothing

@test n_steps(r1) == n_steps(r2)
@test undiscounted_reward(r1) == undiscounted_reward(r2)
@test discounted_reward(r1) == discounted_reward(r2)

@test length(collect(r1)) == n_steps(r1)
@test length(collect(r2)) == n_steps(r2)

display(r1)
println()

for tuple in r1
    @test length(tuple) == length(POMDPSimulators.default_spec(problem))
end

for ui in eachstep(r2, "update_info")
    @test ui == nothing
end

@test r1[1] == first(r1)
@test r1[end] == last(r1)

# test that complete step is returned
step = first(eachstep(r2))
for key in POMDPSimulators.default_spec(problem)
    @test haskey(step, key)
    @test first(r2[key]) == step[key]
end

problem = LegacyGridWorld()
policy = RandomPolicy(problem, rng=MersenneTwister(2))
steps=10
sim = HistoryRecorder(max_steps=steps, rng=MersenneTwister(3))
POMDPLinter.@show_requirements simulate(sim, problem, policy, initialstate(problem, sim.rng))
r1 = simulate(sim, problem, policy, initialstate(problem, sim.rng))

@test length(state_hist(r1)) <= steps + 1 # less than or equal because it may reach the goal too fast
@test length(action_hist(r1)) <= steps
@test length(reward_hist(r1)) <= steps

@test r1[end] == last(r1)
@test r1[1] == first(r1)
for tuple in r1
    @test length(tuple) == length(POMDPSimulators.default_spec(problem))
    @test isa(tuple.s, statetype(problem))
    @test isa(tuple.a, actiontype(problem))
    @test isa(tuple.r, Float64)
    @test isa(tuple.sp, statetype(problem))
end

display(r1)
println()

step = first(eachstep(r1))
for key in POMDPSimulators.default_spec(problem)
    @test haskey(step, key)
    @test first(r1[key]) == step[key]
end

@test length(collect(r1)) == n_steps(r1)

hv = view(r1, 2:length(r1))
@test n_steps(hv) == n_steps(r1)-1
@test undiscounted_reward(r1) == undiscounted_reward(hv) + first(reward_hist(r1))

# iterators
rsum = 0.0
len = 0
for (s, a, r, sp, ai, t) in eachstep(hv, (:s,:a,:r,:sp,:action_info,:t))
    @test isa(s, statetype(problem))
    @test isa(a, actiontype(problem))
    @test isa(r, Float64)
    @test isa(sp, statetype(problem))
    @test isa(ai, Nothing)
    @test isa(t, Int)
    rsum += r
    len += 1
end
@test len == length(hv)
@test rsum == undiscounted_reward(hv)

# it = eachstep(hv, "(r,sp,s,a)")
# @test eltype(collect(it)) == Tuple{Float64, statetype(problem), statetype(problem), actiontype(problem)}
tuples = collect(eachstep(hv, "(r, sp, s, a)"))
@test sum(first(t) for t in tuples) == undiscounted_reward(hv)
@test sum(t.r for t in tuples) == undiscounted_reward(hv)
tuples = collect(eachstep(hv, "r,sp,s,a,t"))
@test sum(first(t) for t in tuples) == undiscounted_reward(hv)
@test sum(t.r for t in tuples) == undiscounted_reward(hv)

hi = HistoryIterator(hv, :r)
@inferred POMDPSimulators.step_tuple(hi, 1)
@test collect(hi) == collect(reward_hist(hv))
@test collect(eachstep(hv, "r")) == collect(reward_hist(hv)) # why isn't collect able to infer the type here??

# test show_progress
gw = SimpleGridWorld()
hr = HistoryRecorder(show_progress=true, max_steps=100)
println("Should be a progress bar below:")
@test length(simulate(hr, gw, FunctionPolicy(s->:left), rand(hr.rng, initialstate(gw)))) <= 100

# test capture_exception
gw = SimpleGridWorld()
hr = HistoryRecorder(show_progress=true, capture_exception=true, max_steps=100, rng=MersenneTwister(2))
counter = []
error_policy = FunctionPolicy(function (s)
                                  push!(counter, true)
                                  if length(counter) <= 3
                                      sleep(0.1) # so that the progress bar gets shown
                                      return :left
                                  else
                                      error("Policy Error")
                                  end
                              end)
println("Should be a progress bar below:")
exhist = simulate(hr, gw, error_policy, rand(hr.rng, initialstate(gw)))
@test 2 <= length(exhist) <= 10
@test exception(exhist) !== nothing

# test showprogress without max_steps
gw = SimpleGridWorld()
hr = HistoryRecorder(show_progress=true)
@test_throws ErrorException simulate(hr, gw, FunctionPolicy(s->:left), rand(hr.rng, initialstate(gw)))

#=
function f(hv)
    rs = 0.0
    for (r,a) in HistoryIterator{typeof(hv), (:r,:a)}(hv)
        rs += r
    end
    return rs
end
@code_warntype f(hv)
hi = HistoryIterator{typeof(r1), (:r,)}(r1)
t = step_tuple(hi, 1)
@code_warntype step_tuple(hi, 1)
=#
end
