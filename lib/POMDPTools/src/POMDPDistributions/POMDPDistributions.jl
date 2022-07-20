module POMDPDistributions

import Distributions
import Distributions: support, pdf, mode, mean # should use Random.pdf directly in the code instead of importing like this
import Random
using Random: AbstractRNG

using UnicodePlots: barplot

export
    weighted_iterator
include("weighted_iteration.jl")

export
    SparseCat
include("sparse_cat.jl")

export
    BoolDistribution
include("bool.jl")

export
    Deterministic
include("deterministic.jl")

export
    Uniform,
    UnsafeUniform
include("uniform.jl")

export
    ImplicitDistribution
include("implicit.jl")

export
    showdistribution
include("pretty_printing.jl")

end
