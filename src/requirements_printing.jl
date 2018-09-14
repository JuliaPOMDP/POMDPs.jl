function show_heading(io::IO, requirer)
    print(io, "INFO: POMDPs.jl requirements for ")
    printstyled(io, handle_method(requirer), color=:blue)
    println(io, " and dependencies. ([✔] = implemented correctly; [X] = missing)")
end

function show_requirer(io::IO, r::AbstractRequirementSet)
    print(io, "For ")
    printstyled(io, "$(handle_method(r.requirer))", color=:blue)
    if r.parent == nothing
        println(io, ":")
    else
        println(io, " (in $(handle_method(r.parent))):")
    end
end

function show_checked_list(io::IO, cl::AbstractVector{T}) where T <: Tuple
    for item in cl
        if first(item)
            printstyled(io, "  [✔] $(format_method(item[2], item[3]))", color=:green)
            println(io)
        else
            printstyled(io, "  [X] $(format_method(item[2], item[3]))", color=:red)
            println(io)
        end
    end
end

function show_incomplete(io, r::RequirementSet)
    @assert r.exception != nothing
    extype = typeof(r.exception)
    printstyled(io, "  WARNING: Some requirements may not be shown because a $(extype) was thrown.", color=:yellow)
    println(io)
end

handle_method(str::Any) = string(str)
handle_method(str::Req) = format_method(str...)
short_method(str::Any) = string(str)
short_method(str::Req) = string(first(str))

function format_method(f::Function, argtypes::TupleType; module_names=false, color=nothing)
    fname = f
    typenames = argtypes.parameters
    if !module_names
        fname = typeof(f).name.mt.name
        mless_typenames = []
        for t in argtypes.parameters
            if isa(t, Union)
                str = "Union{"
                for (i, tt) in enumerate(fieldnames(typeof(t)))
                    str = string(str, getfield(t, tt), i<length(fieldnames(typeof(t))) ? ',' : '}')
                end
                push!(mless_typenames, str)
            elseif isa(t, UnionAll)
                push!(mless_typenames, string(t))
            else
                push!(mless_typenames, t.name.name)
            end
        end
        typenames = mless_typenames
    end
    str = "$fname("
    len = length(typenames)
    for (i, t) in enumerate(typenames)
        str = string(str, "::$t")
        if i < len
            str = string(str, ", ")
        end
    end
    str = string(str, ")")
end
