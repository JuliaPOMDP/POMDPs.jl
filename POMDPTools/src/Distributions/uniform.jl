struct Uniform{T<:AbstractSet}
    set::T
end

"""
    Uniform(collection)

Create a uniform categorical distribution over a collection of objects.

The objects in the collection must be unique (this is tested on construction), and will be stored in a `Set`. To avoid this overhead, use `UnsafeUniform`.
"""
function Uniform(c)
    set = Set(c)
    if length(c) > length(set)
        error("""
              Error constructing Uniform($c).

              Objects must be unique (that is, length(Set(c)) == length(c)).
              """
             )
    end
    return Uniform(set)
end

support(d::Uniform) = d.set
sampletype(::Type{Uniform{T}}) where T = eltype(T)
Random.gentype(::Type{Uniform{T}}) where T = eltype(T)

function pdf(d::Uniform, s)
    if s in d.set
        return 1.0/length(d.set)
    else
        return 0.0
    end
end

Base.show(io::IO, m::MIME"text/plain", d::Uniform) = showdistribution(io, m, d, title="Uniform distribution")

"""
    UnsafeUniform(collection)

Create a uniform categorical distribution over a collection of objects.

No checks are performed to ensure uniqueness or check whether an object is actually in the set when evaluating the pdf.
"""
struct UnsafeUniform{T}
    collection::T
end

pdf(d::UnsafeUniform, s) = 1.0/length(d.collection)
support(d::UnsafeUniform) = d.collection
sampletype(::Type{UnsafeUniform{T}}) where T = eltype(T)
Random.gentype(::Type{UnsafeUniform{T}}) where T = eltype(T)

# Common Implementations

const Unif = Union{Uniform,UnsafeUniform}

rand(rng::AbstractRNG, d::Unif) = rand(rng, support(d))
mean(d::Unif) = mean(support(d))
mode(d::Unif) = mode(support(d))

function weighted_iterator(d::Unif)
    p = 1.0/length(support(d))
    return (x=>p for x in support(d))
end

Base.show(io::IO, m::MIME"text/plain", d::UnsafeUniform) = showdistribution(io, m, d, title="UnsafeUniform distribution")
