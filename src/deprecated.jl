@deprecate generate_s(args...) gen(DBNVar(:sp), args...)
@deprecate generate_o(args...) gen(DBNVar(:o), args...)
@deprecate generate_sr(args...) gen(DBNTuple(:sp,:r), args...)
@deprecate generate_so(args...) gen(DBNTuple(:sp,:o), args...)
@deprecate generate_or(args...) gen(DBNTuple(:o,:r), args...)
@deprecate generate_sor(args...) gen(DBNTuple(:sp,:o,:r), args...)

const old_generate = Dict(:sp => generate_s,
                    :o => generate_o,
                    (:sp,:r) => generate_sr,
                    (:sp,:o) => generate_so,
                    (:o,:r) => generate_or,
                    (:sp,:o,:r) => generate_sor)

const new_dbnvars = Dict(generate_s => DBNVar{:sp},
                         generate_o => DBNVar{:o},
                         generate_sr => DBNTuple{(:sp,:r)},
                         generate_so => DBNTuple{(:sp,:o)},
                         generate_or => DBNTuple{(:o,:r)},
                         generate_sor => DBNTuple{(:sp,:o,:r)})


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
