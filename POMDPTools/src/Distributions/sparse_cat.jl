"""
    SparseCat(values, probabilities)

Create a sparse categorical distribution.

`values` is an iterable object containing the possible values (can be of any type) in the distribution that have nonzero probability. `probabilities` is an iterable object that contains the associated probabilities.

This is optimized for value iteration with a fast implementation of `weighted_iterator`. Both `pdf` and `rand` are order n.
"""
struct SparseCat{V, P}
    vals::V
    probs::P
end

function rand(rng::AbstractRNG, d::SparseCat)
    r = sum(d.probs)*rand(rng)
    tot = zero(eltype(d.probs))
    for (v, p) in d
        tot += p
        if r < tot
            return v
        end
    end
    if sum(d.probs) <= 0.0
        error("""
              Tried to sample from a SparseCat distribution with probabilities that sum to $(sum(d.probs)).

              vals = $(d.vals)

              probs = $(d.probs)
              """)
    end
    error("Error sampling from SparseCat distribution with vals $(d.vals) and probs $(d.probs)") # try to help with type stability
end

# slow linear search :(
function pdf(d::SparseCat, s)
    for (v, p) in d
        if v == s
            return p
        end
    end
    return zero(eltype(d.probs))
end

function pdf(d::SparseCat{V,P}, s) where {V<:AbstractArray, P<:AbstractArray}
    for (i,v) in enumerate(d.vals)
        if v == s
            return d.probs[i]
        end
    end
    return zero(eltype(d.probs))
end



support(d::SparseCat) = d.vals

weighted_iterator(d::SparseCat) = d

# iterator for general SparseCat
# this has some type stability problems
function Base.iterate(d::SparseCat)
    val, vstate = iterate(d.vals)
    prob, pstate = iterate(d.probs)
    return ((val=>prob), (vstate, pstate))
end
function Base.iterate(d::SparseCat, dstate::Tuple)
    vstate, pstate = dstate
    vnext = iterate(d.vals, vstate)
    pnext = iterate(d.probs, pstate)
    if vnext == nothing || pnext == nothing
        return nothing 
    end
    val, vstate_next = vnext
    prob, pstate_next = pnext
    return ((val=>prob), (vstate_next, pstate_next))
end

# iterator for SparseCat with indexed members
const Indexed = Union{AbstractArray, Tuple, NamedTuple}

function Base.iterate(d::SparseCat{V,P}, state::Integer=1) where {V<:Indexed, P<:Indexed}
    if state > length(d)
        return nothing 
    end
    return (d.vals[state]=>d.probs[state], state+1)
end

Base.length(d::SparseCat) = min(length(d.vals), length(d.probs))
Base.eltype(D::Type{SparseCat{V,P}}) where {V, P} = Pair{eltype(V), eltype(P)}
sampletype(D::Type{SparseCat{V,P}}) where {V, P} = eltype(V)
Random.gentype(D::Type{SparseCat{V,P}}) where {V, P} = eltype(V)

function mean(d::SparseCat)
    vsum = zero(eltype(d.vals))
    for (v, p) in d
        vsum += v*p
    end
    return vsum/sum(d.probs)
end

function mode(d::SparseCat)
    bestp = zero(eltype(d.probs))
    bestv = first(d.vals)
    for (v, p) in d
        if p >= bestp
            bestp = p
            bestv = v
        end 
    end
    return bestv
end

Base.show(io::IO, m::MIME"text/plain", d::SparseCat) = showdistribution(io, m, d, title="SparseCat distribution")
