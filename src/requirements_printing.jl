function show_heading(io::IO, requirer)
    print(io, "INFO: POMDPs.jl requirements for ")
    printstyled(io, handle_method(requirer), color=:blue)
    println(io, " and dependencies. ([✔] = implemented correctly; [X] = not implemented; [?] = could not determine)")
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
        if ismissing(first(item))
            printstyled(io, "  [?] $(format_method(item[2], item[3]))", color=:yellow)
            println(io)
        elseif first(item) == true
            printstyled(io, "  [✔] $(format_method(item[2], item[3]))", color=:green)
            println(io)
        else
            @assert first(item) == false
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
                str = string(t.name.name)
                if !isempty(t.parameters)
                    ps = map(t.parameters) do p
                        if p isa Symbol
                            return Meta.quot(p)
                        else
                            return p
                        end
                    end
                    str = string(str, "{$(ps...)}")
                end
                push!(mless_typenames, str)
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

logger_context(::AbstractLogger) = IOContext()
logger_context(l::ConsoleLogger) = IOContext(l.stream)
logger_context(l::SimpleLogger) = IOContext(l.stream)
logger_context() = logger_context(current_logger())

"""
Return a String with the req checked if it is implemented.
"""
function schecked(req::Req; kwargs...)
    checked_list = [(implemented(req), req...)]
    sprint(show_checked_list, checked_list; kwargs...)
end
