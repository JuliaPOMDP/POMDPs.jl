struct IMDP <: MDP{Float64, Int} end

function POMDPs.transition(m::IMDP, s, a)
    ImplicitDistribution(s, a) do s, a, rng
        return s + a + rand(rng)
    end
end

m = IMDP()

td = transition(m, 1.0, 1)
@test 2 <= rand(td) <= 3
@test all(2 <= sp <= 3 for sp in rand(td, 2))

impldist(m) = ImplicitDistribution(m) do m, rng
    return rand(rng, m)
end
@test rand(impldist(Int)) isa Int
