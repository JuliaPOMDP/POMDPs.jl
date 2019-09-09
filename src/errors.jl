struct DistributionNotImplemented <: Exception
    sym::Symbol
    gen_firstarg::Union{DBNVar, DBNOut}
    func::Function
    modeltype::Type
    dep_argtypes::NamedTuple
end

function Base.showerror(io, ex::DistributionNotImplemented)
    # using hard break at 88 here
    println(io, """
        POMDPs.jl could not find an implementation for DDN Node :$(ex.sym). It appears
        that this was called from gen($(ex.gen_firstarg), ...).  Consider the following
        options:

    """)

    argstring = string("::", ex.modeltype, string((", ::$T" for T in ex.dep_argtypes)...))

    i = 1
    if ex.gen_firstarg isa DBNOut
        println(io, "$i) Implement POMDPs.gen($argstring, ::AbstractRNG) to return a NamedTuple with key :$(ex.sym).\n")
        gen_analysis(io, ex)
        i += 1
    end
    println(io, "$i) Implement POMDPs.gen(::DBNVar{:$(ex.sym)}, $argstring, ::AbstractRNG):\n")
    showerror(io, MethodError(gen, (DBNVar{ex.sym}, ex.modeltype, ex.dep_argtypes..., AbstractRNG)))
    i += 1
    println(io, "$i) Implement $(ex.func)($argstring):\n")
    showerror(io, MethodError(transition, (ex.modeltype, ex.dep_argtypes...)))

    println(io, "\nThis error message is designed to help POMDPs.jl problem implementers. If it was misleading or you believe there is an inconsistency, please file an issue: https://github.com/JuliaPOMDP/POMDPs.jl/issues/new")
end

function distribution_impl_error(sym, func, modeltype, dep_argtypes)
    st = stacktrace()
    println("begin")
    acceptable = (:distribution_impl_error, nameof(func), nameof(gen))
    gen_firstarg = nothing # The first argument to the `gen` call that is furthest down in the stack trace

    for sf in stacktrace() # step up the stack trace

        # if it is a macro from dbn_struct.jl or gen_impl.jl it is ok
        if sf.func === Symbol("macro expansion")
            bn = basename(String(sf.file))
            if !(bn in ["dbn_struct.jl", "gen_impl.jl"])
                break
                # the call stack includes a macro from some other package
            end

        # if it is not a function we know about, give up
        elseif !(sf.func in acceptable)
            break

        # if it is gen, check to see if it's the DBNVar version
        elseif sf.func === nameof(gen)
            println("\n\n\n\n")
            sig = sf.linfo.def.sig
            if sig isa UnionAll &&
                sig.body.parameters[1] == typeof(gen) &&
                sig.body.parameters[2] <: Union{DBNVar, DBNOut}
                # bingo!
                gen_firstarg = sig.body.parameters[2]() # create an instance of the type
            end
        end
    end

    if gen_firstarg === nothing
        throw(MethodError(transition, (modeltype, dep_argtypes...)))
    else
        throw(DistributionNotImplemented(:sp, gen_firstarg, func, modeltype, dep_argtypes))
    end
end

function gen_analysis(io, ex::DistributionNotImplemented)
    argtypes = (ex.modeltype, ex.dep_argtypes..., AbstractRNG)
    rts = Base.return_types(gen, argtypes)
    @assert length(rts) > 0 # there should always be the default NamedTuple() impl.
    if length(rts) == 1
        rt = first(rts)
        if rt == typeof(NamedTuple()) && !implemented(gen, argtypes)
            showerror(io, MethodError(gen, argtypes))
        else
            println(io, "This method was implemented and the return type was inferred to be $rt. Is this type always a NamedTuple with key :$(ex.sym)?")
        end
    else
        println(io, "(POMDPs.jl could not determine if this method was implemented correctly. [Base.return_types(gen, argtypes) = $(rts)])")
    end
end

transition(m, s, a) = distribution_impl_error(:sp, transition, typeof(m), (s=typeof(s), a=typeof(a)))
observation(m, a, sp) = distribution_impl_error(:sp, observation, typeof(m), (a=typeof(a), sp=typeof(sp)))
