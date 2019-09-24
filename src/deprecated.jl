@deprecate generate_s(args...) gen(DDNOut(:sp), args...)
@deprecate generate_o(args...) gen(DDNNode(:o), args...) # this one should be DDNNode because the arguments are not s and a
@deprecate generate_sr(args...) gen(DDNOut(:sp,:r), args...)
@deprecate generate_so(args...) gen(DDNOut(:sp,:o), args...)
@deprecate generate_sor(args...) gen(DDNOut(:sp,:o,:r), args...)
generate_or(args...) = error("POMDPs.jl v0.8 no longer supports generate_or") # there is no equivalent for this in the new system, but AFAIK no one used it.

const old_generate = Dict(:sp => generate_s,
                    :o => generate_o,
                    (:sp,:r) => generate_sr,
                    (:sp,:o) => generate_so,
                    (:sp,:o,:r) => generate_sor)

const new_ddnvars = Dict(generate_s => DDNNode{:sp},
                         generate_o => DDNNode{:o},
                         generate_sr => DDNOut{(:sp,:r)},
                         generate_so => DDNOut{(:sp,:o)},
                         generate_sor => DDNOut{(:sp,:o,:r)})


GenerateFunctions = Union{(typeof(f) for f in values(old_generate))...}

function implemented_by_user(g::GenerateFunctions, TT::TupleType)
    m = which(g, TT)
    return m.module != POMDPs
end

function implemented(g::GenerateFunctions, TT::TupleType)
    if implemented_by_user(g, TT)
        return true
    end
    return implemented(gen, Tuple{new_ddnvars[g], TT.parameters...})
end

@deprecate sampletype Random.gentype
@deprecate n_states(m) length(states(m))
@deprecate n_actions(m) length(actions(m))
@deprecate n_observations(m) length(observations(m))

"""
The version 0.7 DDNStructure just has the nodenames
"""
struct DDNStructureV7{nodenames} end

nodenames(d::DDNStructureV7) = nodenames(typeof(d))
nodenames(::Type{D}) where D <: DDNStructureV7 = D.parameters[1]
outputnames(d::DDNStructureV7) = outputnames(typeof(d))
function outputnames(::Type{D}) where D <: DDNStructureV7
    tuple(Iterators.filter(sym->!(sym in (:s, :a)), nodenames(D))...)
end
