using Distributions

mdp = SimpleGridWorld(tprob = 1)
hist = simulate(HistoryRecorder(), mdp, RandomPolicy(mdp), GWPos(3,3))

## Test the playback simulator
playback = PlaybackPolicy(collect(action_hist(hist)), RandomPolicy(mdp))
@test all(playback.actions .== action_hist(hist))
@test playback.backup_policy isa RandomPolicy
@test playback.i == 1
@test_throws AssertionError logpdf(playback, hist)

hist2 = simulate(HistoryRecorder(), mdp, playback, GWPos(3,3))
@test hist == hist2

## Test log probability
Distributions.logpdf(p::RandomPolicy, h) = length(h)*log(1. / length(actions(p.problem)))
playback = PlaybackPolicy(collect(action_hist(hist)), RandomPolicy(mdp), logpdfs = -ones(length(hist)))
hist2 = simulate(HistoryRecorder(), mdp, playback, GWPos(3,3))
@test logpdf(playback, hist2) == -1*length(hist2)

playback = PlaybackPolicy([], RandomPolicy(mdp))
@test logpdf(playback, hist2) == length(hist2)*log(0.25)

