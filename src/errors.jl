###############################################################
# This macro automatically generates a function body that
# throws an error if the interface function is not implemented.
###############################################################

"""
Provide a default function implementation that throws an error when called.
"""
macro pomdp_func(signature)
    if signature.head == :(=) # in this case a default implementation has already been supplied
        return esc(signature)
    end
    @assert signature.head == :call

    # get the names of all the arguments
    args = [strip_arg(expr) for expr in signature.args[2:end]]

    # get the name of the function
    fname = strip_curly(signature.args[1])

    error_format = "POMDPs.jl: No implementation of $fname for "

    # add each of the arguments to error string
    for (i,a) in enumerate(args)
        error_format *= "$a::%s"
        if i == length(args)-1
            error_format *= ", and "
        elseif i != length(args)
            error_format *= ", "
        else
            error_format *= ".\n"
        end
    end

    error_format = string(error_format, "NOTE: This is often due to incorrect importing; consider using `importall POMDPs`.\n\n")

    # if you are modifying this and want to debug, it might be helpful to print
    # println(error_string)
    
    argtypes = [:(typeof($a)) for a in args]

    body = quote
        warn(@sprintf($error_format, $(argtypes...)))
        throw(MethodError($fname, ($(args...),))) # this is abuse of this Error and may break in the future
    end

    return Expr(:function, esc(signature), esc(body))
end

"""
Strip anything extra (type annotations, default values, etc) from an argument.

For now this cannot handle keyword arguments (it will throw an error).
"""
strip_arg(arg::Symbol) = arg # once we have a symbol, we have stripped everything, so we can just return it
function strip_arg(arg_expr::Expr) 
    if arg_expr.head == :parameters # keyword argument
        error("strip_arg can't handle keyword args yet (parsing arg expression $(arg_expr))")
    elseif arg_expr.head == :(::) # argument is type annotated, remove the annotation
        return strip_arg(arg_expr.args[1])
    elseif arg_expr.head == :kw # argument has a default value, remove the default
        return strip_arg(arg_expr.args[1])
    else
        error("strip_arg encountered something unexpected. arg_expr was $(arg_expr)")
    end
end

"""
Strip parameters from a function name
"""
strip_curly(fname::Symbol) = fname # if it is a symbol, we can just leave it untouched
function strip_curly(fname::Expr)
    if fname.head == :curly
        return fname.args[1]
    else
        error("strip_curly encountered something unexpected. fname was $(fname)")
    end
end
