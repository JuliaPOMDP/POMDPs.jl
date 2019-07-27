@deprecate generate_s(args...) gen(Return(:sp), args...)
@deprecate generate_o(args...) gen(Return(:o), args...)
@deprecate generate_sr(args...) gen(Return(:sp,:r), args...)
@deprecate generate_so(args...) gen(Return(:sp,:o), args...)
@deprecate generate_or(args...) gen(Return(:o,:r), args...)
@deprecate generate_sor(args...) gen(Return(:sp,:o,:r), args...)

const old_generate = Dict(:sp => generate_s,
                    :o => generate_o,
                    (:sp,:r) => generate_sr,
                    (:sp,:o) => generate_so,
                    (:o,:r) => generate_or,
                    (:sp,:o,:r) => generate_sor)

const new_genvars = Dict(generate_s => :sp,
                    generate_o => :o,
                    generate_sr => (:sp,:r),
                    generate_so => (:sp,:o),
                    generate_or => (:o,:r),
                    generate_sor => (:sp,:o,:r))


GenerateFunctions = Union{(typeof(f) for f in values(old_generate))...}

function implemented_by_user(g::GenerateFunctions, TT::TupleType)
    m = which(g, TT)
    return m.module != POMDPs
end

function implemented(g::GenerateFunctions, TT::TupleType)
    if implemented_by_user(g, TT)
        return true
    end
    return implemented(gen, Tuple{Return{new_genvars[g]}, TT.parameters...})
end
