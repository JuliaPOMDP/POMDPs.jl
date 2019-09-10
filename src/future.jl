struct DDNOut{names} end

DDNOut(name::Symbol) = DDNOut{name}()
DDNOut(names...) = DDNOut{names}()

const old_generate = Dict(:sp => generate_s,
                    (:sp,:r) => generate_sr,
                    (:sp,:o) => generate_so,
                    (:sp,:o,:r) => generate_sor)

@generated function gen(::DDNOut{x}, m, s, a, rng) where x
    quote
        $(old_generate[x])(m, s, a, rng)
    end
end

"""
The version 7 DDNStructure just has the nodenames
"""
struct DDNStructureV7{nodenames} end

nodenames(d::DDNStructureV7) = nodenames(typeof(d))
nodenames(::Type{D}) where D <: DDNStructureV7

DDNStructure(::Type{M}) where M <: MDP = DDNStructureV7{(:s,:a,:sp,:r)}()
DDNStructure(::Type{M}) where M <: POMDP = DDNStructureV7{(:s,:a,:sp,:r,:o)}()
