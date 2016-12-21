function show_heading(io::IO, requirer)
    print(io, "INFO: POMDPs.jl requirements for ")
    print_with_color(:blue, io, handle_method(requirer))
    println(io, " and dependencies. ([✔] = implemented correctly; [X] = missing)")
end

function show_requirer(io::IO, r::AbstractRequirementSet)
    print(io, "For ")
    print_with_color(:blue, io, "$(handle_method(r.requirer))")
    if isnull(r.parent)
        println(io, ":")
    else
        println(io, " (in $(handle_method(get(r.parent)))):")
    end
end

function show_checked_list(io::IO, cl::CheckedList)
    for item in cl
        if first(item)
            print_with_color(:green, io, "  [✔] $(format_method(item[2], item[3]))")
            println(io)
        else
            print_with_color(:red, io, "  [X] $(format_method(item[2], item[3]))")
            println(io)
        end
    end
end

function show_incomplete(io, r::RequirementSet)
    @assert !isnull(r.exception)
    extype = typeof(get(r.exception))
    print_with_color(:red, io, "  WARNING: Some requirements may not be shown because a $(extype) was thrown.")
    println(io)
end

handle_method(str::Any) = string(str)
handle_method(str::Req) = format_method(str...)
short_method(str::Any) = string(str)
short_method(str::Req) = string(first(str))

function format_method(f::Function, argtypes::TupleType; module_names=false)
    fname = f
    typenames = argtypes.parameters
    if !module_names
        # begin
            fname = typeof(f).name.mt.name
            mless_typenames = [] 
            for t in argtypes.parameters
                if isa(t, Union)
                    str = "Union{"
                    for (i, tt) in enumerate(t.types)
                        str = string(str, tt.name.name, i<length(t.types)?',':'}')
                    end
                    push!(mless_typenames, str)
                else
                    push!(mless_typenames, t.name.name)
                end
            end
            typenames = mless_typenames
        # end
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


