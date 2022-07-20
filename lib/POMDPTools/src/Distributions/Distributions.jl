module Distributions

export
    weighted_iterator
include("distributions/weighted_iteration.jl")

export
    SparseCat
include("distributions/sparse_cat.jl")

export
    BoolDistribution
include("distributions/bool.jl")

export
    Deterministic
include("distributions/deterministic.jl")

export
    Uniform,
    UnsafeUniform
include("distributions/uniform.jl")

export
    ImplicitDistribution
include("distributions/implicit.jl")

export
    showdistribution
include("distributions/pretty_printing.jl")

end
