#############################
# Interface for distributions
#############################

"""
    rand(rng::AbstractRNG, d::Any)

Return a random element from distribution or space `d`.

If `d` is a state or transition distribution, the sample will be a state; if `d` is an action distribution, the sample will be an action or if `d` is an observation distribution, the sample will be an observation.
"""
function rand end

"""
    pdf(d::Any, x::Any)

Evaluate the probability density of distribution `d` at sample `x`.
"""
function pdf end

"""
    mode(d::Any)

Return the most likely value in a distribution d.
"""
function mode end

"""
    mean(d::Any)

Return the mean of a distribution d.
"""
function mean end

"""
    support(d::Any)

Return an iterable object containing the possible values that can be sampled from distribution d. Values with zero probability may be skipped.
"""
function support end
