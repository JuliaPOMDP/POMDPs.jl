@deprecate generate_s(args...) gen(Val(:s), args...)
@deprecate generate_o(args...) gen(Val(:o), args...)
@deprecate generate_sr(args...) gen(Val((:s,:r)), args...)
@deprecate generate_so(args...) gen(Val((:s,:o)), args...)
@deprecate generate_or(args...) gen(Val((:o,:r)), args...)
@deprecate generate_sor(args...) gen(Val((:s,:o,:r)), args...)

const old_generate = Dict(:sp => generate_s,
                    :o => generate_o,
                    (:sp,:r) => generate_sr,
                    (:sp,:o) => generate_so,
                    (:o,:r) => generate_or,
                    (:sp,:o,:r) => generate_sor)

GenerateFunctions = Union{(typeof(f) for f in values(old_generate))...}

function implemented(g::GenerateFunctions, TT::TupleType)
    m = which(g, TT)
    return m.module != POMDPs
end
