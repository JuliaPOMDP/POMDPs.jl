struct Return{x} end

function Return(x::Symbol)
    if x == :s
        @warn("Return(:s) is not normally used. Did you mean Return(:sp)? To suppress this warning, use Return{:s}().")
    end
    Return{x}()
end

function Return(args...)
    for a in args
        @assert a isa Symbol "All arguments to Return(...) must be symbols. Got $a"
        if a == :s
            @warn("Return(:s) is not normally used. Did you mean Return(:sp)? To suppress this warning, use Return{:s}().")
        end
    end
    Return{args}()
end
