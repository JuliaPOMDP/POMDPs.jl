"""
    Return(x::Symbol)
    Return(::Symbol, ::Symbol,...)
    Return{x::Symbol}()
    Return{x::NTuple{N, Symbol})

Specify what `gen` should return.

`Return` is a "value type". See the documentation of `Val` for more conceptual details.

# Arguments
- `x`: a `Symbol` or `Tuple` of `Symbol`s that are genvars. Use `list_genvars()` to list all genvars.

# Examples
Let `m` be a `POMDP`, `s` be a state of `m`, `a` be an action of `m`, and `rng` be an `AbstractRNG`.
- `gen(Return(:sp), m, s, a, rng)` returns the next state.
- `gen(Return(:sp, :r), m, s, a, rng)` returns a `Tuple` containing the next state and reward.
- `gen(Return{:sp}(), m, s, a, rng)` returns the next state.
- `gen(Return{(:sp,:o,:r)}(), m, s, a, rng)` returns a `Tuple` containing the next state, observation, and reward.
- `gen(Return{(:sp,)}(), m, s, a, rng)` returns a `Tuple` containing only the next state (but this will typically not be used).
"""
struct Return{x} end

function Return(x::Symbol)
    if x == :s
        @warn("Return(:s) is not normally used. Did you mean Return(:sp)? To suppress this warning, use Return{:s}().")
    end
    Return{x}()
end

function Return(args...)
    for a in args
        @assert a isa Symbol
        if a == :s
            @warn("Return(:s) is not normally used. Did you mean Return(:sp)? To suppress this warning, use Return{:s}().")
        end
    end
    Return{args}()
end
