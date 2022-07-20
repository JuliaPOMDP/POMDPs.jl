# a belief that just stores the previous observation
# maintained by @zsunberg

# policies based on the previous observation only are often pretty good
# e.g. for the crying baby problem
"""
Updater that stores the most recent observation as the belief. If an initial distribution is provided, it will pass that as the initial belief.
"""
struct PreviousObservationUpdater <: Updater end

initialize_belief(u::PreviousObservationUpdater, d::Any) = d

update(bu::PreviousObservationUpdater, old_b, action, obs) = obs
