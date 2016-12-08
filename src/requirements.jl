typealias TupleType Type

type RequirementsList
    requirer::String
    list::Vector{Tuple{Function, TupleType}}
end
RequirementsList(requirer::String) = RequirementsList(requirer, Array(Tuple{Function, TupleType}, 0))

function Base.push!(r::RequirementsList, func::Function, argtypes::TupleType)
    push!(r.list, (func, argtypes))
end

"""
    @try_with_reqs begin
        # some expressions
    end reqs

Run some expressions. If these expressions throw a method error, the `RequirementsList` `reqs` will be printed and the error will be rethrown.
"""
macro try_with_reqs(expression, list)
    block = quote
        try
            $expression
        catch exception
            if isa(exception, MethodError)
                check_requirements($list, output = true)
                print_with_color(:red, "Note: There may be additional requirements that can be determined when the following error is fixed.\n")
                println()
                rethrow(exception)
            else
                rethrow(exception)
            end
        end
    end
    return esc(block)
end

typealias CheckedList Vector{Tuple{Bool, Function, TupleType}}

"""
    check_requirements(r::RequirementsList; output::Union{Bool,Symbol}=:ifmissing)

Check whether the methods in `r` have implementations with `method_exists()` and print out a formatted list showing which are missing (output can be supressed with `output=false`). Return true if all methods have implementations.
"""
function check_requirements(r::RequirementsList; output::Union{Bool,Symbol}=:ifmissing)
    checked = CheckedList()
    missing = false
    for fp in r.list
        exists = method_exists(first(fp), last(fp))
        if !exists
            missing = true
        end
        push!(checked, (exists, first(fp), last(fp)))
    end
    if output == :ifmissing
        shouldprint = missing
    else
        shouldprint = output
    end
    if shouldprint
        println()
        print("WARNING: ")
        print_with_color(:blue, r.requirer)
        println(" requires the methods below. Methods with a [✔] were implemented correctly; methods with a [X] are missing.")
        println()
        print_checked_list(checked)
        println()
    end
    return !missing
end

function print_checked_list(cl::CheckedList)
    for item in cl
        if first(item)
            print_with_color(:green, "[✔] $(format_method(item[2], item[3]))")
            println()
        else
            print_with_color(:red, "[X] $(format_method(item[2], item[3]))")
            println()
        end
    end
end

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

#=
function get_requirements(s::Union{Solver, Simulator}, p::Union{POMDP,MDP})

end
=#
