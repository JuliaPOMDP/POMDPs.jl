#############################
# Interface for distributions
#############################

"""
    rand{T}(rng::AbstractRNG, d::Any)

Return a random element from distribution or space `d`. The sample can be a state, action or observation.
"""
Base.rand

"""
    pdf(d::Any, x::Any)

Evaluate the probability density of distribution `d` at sample `x`.
"""
function pdf end # maybe eventually this should be Distributions.pdf

"""
    mode(d::Any)

Return the most likely value in a distribution d.
"""
function mode end

"""
    mean(d::Any)

Return the mean of a distribution d.
"""
Base.mean

"""
    iterator(d::Any)

Return an iterable type (array or custom iterator) that iterates over possible values of distribution or space `d`. Values with zero probability may be skipped.
"""
function iterator end

iterator(a::AbstractArray) = a
