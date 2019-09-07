@deprecate generate_s(args...) gen(DBNOut(:sp), args...)
@deprecate generate_o(args...) gen(DBNOut(:o), args...)
@deprecate generate_sr(args...) gen(DBNOut(:sp,:r), args...)
@deprecate generate_so(args...) gen(DBNOut(:sp,:o), args...)
@deprecate generate_sor(args...) gen(DBNOut(:sp,:o,:r), args...)
generate_or(args...) = error("POMDPs.jl v0.8 no longer supports generate_or") # there is no equivalent for this in the new system, but AFAIK no one used it.

const old_generate = Dict(:sp => generate_s,
                    :o => generate_o,
                    (:sp,:r) => generate_sr,
                    (:sp,:o) => generate_so,
                    (:sp,:o,:r) => generate_sor)

const new_dbnvars = Dict(generate_s => DBNVar{:sp},
                         generate_o => DBNVar{:o},
                         generate_sr => DBNOut{(:sp,:r)},
                         generate_so => DBNOut{(:sp,:o)},
                         generate_sor => DBNOut{(:sp,:o,:r)})


GenerateFunctions = Union{(typeof(f) for f in values(old_generate))...}

function implemented_by_user(g::GenerateFunctions, TT::TupleType)
    m = which(g, TT)
    return m.module != POMDPs
end

function implemented(g::GenerateFunctions, TT::TupleType)
    if implemented_by_user(g, TT)
        return true
    end
    return implemented(gen, Tuple{new_dbnvars[g], TT.parameters...})
end
