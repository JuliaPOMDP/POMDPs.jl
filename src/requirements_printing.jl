function show_heading(io::IO, requirer)
    print(io, "INFO: Requirements for ")
    if isa(requirer, Req)
        print_with_color(:blue, io, format_method(requirer...))
    else
        print_with_color(:blue, io, string(requirer))
    end
    println(io, " and dependencies are printed below. Methods with a [✔] were implemented correctly; methods with a [X] are missing.")
end

function show_requirer(io::IO, r::AbstractRequirementSet)
    print_with_color(:blue, io, "# $(handle_method(r.requirer))")
    if isnull(r.parent)
        println(io, ":")
    else
        println(io, " (required by $(short_method(get(r.parent)))):")
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

handle_method(str::Any) = str
handle_method(str::Req) = format_method(str...)
short_method(str::Any) = str
short_method(str::Req) = first(str)

function format_method(f::Function, argtypes::TupleType)
    str = "$f("
    len = length(argtypes.parameters)
    for (i, t) in enumerate(argtypes.parameters)
        str = string(str, " ::$t")
        if i < len
            str = string(str, ",")
        end
    end
    str = string(str, ")")
end


