struct DDNOut{names} end

DDNOut(name::Symbol) = DDNOut{name}()
DDNOut(names...) = DDNOut{names}()
DDNOut(names::Tuple) = DDNOut{names}() # XXX port to 0.8

const old_generate = Dict(:sp => generate_s,
                    (:sp,:r) => generate_sr,
                    (:sp,:o) => generate_so,
                    (:sp,:o,:r) => generate_sor)

@generated function gen(::DDNOut{x}, m, s, a, rng) where x
    quote
        $(old_generate[x])(m, s, a, rng)
    end
end

struct DDNNode{name} end
DDNNode(name::Symbol) = DDNNode{name}()
gen(::DDNNode{:o}, m, s, rng) = generate_o(m, s, rng)

function implemented(gen, TT::TupleType)
    if TT.parameters[1] <: DDNNode{:o}
        return implemented(generate_o, Tuple{TT.parameters[2:end]...})
    else
        @assert TT.parameters[1] <: DDNOut
        names = TT.parameters[1].parameters[1]
        return implemented(old_generate[names], Tuple{TT.parameters[2:end]...})
    end
end

"""
The version 0.7 DDNStructure just has the nodenames
"""
struct DDNStructureV7{nodenames} end

nodenames(d::DDNStructureV7) = nodenames(typeof(d))
nodenames(::Type{D}) where D <: DDNStructureV7 = D.parameters[1]
outputnames(d::DDNStructureV7) = outputnames(typeof(d)) # XXX Port to 0.8
function outputnames(::Type{D}) where D <: DDNStructureV7
    tuple(Iterators.filter(sym->!(sym in (:s, :a)), nodenames(D))...)
end

DDNStructure(::Type{M}) where M <: MDP = DDNStructureV7{(:s,:a,:sp,:r)}()
DDNStructure(::Type{M}) where M <: POMDP = DDNStructureV7{(:s,:a,:sp,:o,:r)}()
DDNStructure(m::Union{MDP,POMDP}) = DDNStructure(typeof(m))

"""
    history(b)

Return the action-observation history associated with belief `b`.

The history should be an `AbstractVector` full of `NamedTuples` with keys `:a` and `:o`, i.e. `history(b)[end][:a]` should be the last action taken leading up to `b`, and `history(b)[end][:o]` should be the last observation received.

It is acceptable to return only part of the history if that is all that is available, but it should always end with the current observation. For example, it would be acceptable to return a structure containing only the last three observations in a length 3 `Vector{NamedTuple{(:o,),Tuple{O}}`.
"""
function history end

"""
    currentobs(b)

Return the latest observation associated with belief `b`.

If a solver or updater implements `history(b)` for a belief type, `currentobs` has a default implementation.
"""
currentobs(b) = history(b)[end].o
@impl_dep currentobs(::B) where B history(::B)
