"""
    showdistribution([io], [mime], d)

Show a UnicodePlots.barplot representation of a distribution.

# Keyword Arguments

- `title::String=string(typeof(d))*" distribution"`: title for the barplot. 
"""
function showdistribution(io::IO, mime::MIME"text/plain", d; title=string(typeof(d))*" distribution")
    limited = get(io, :limit, false)
    strings = String[]
    probs = Float64[]

    rows = first(get(io, :displaysize, displaysize(io)))
    rows -= 6 # Yuck! This magic number is also in Base.print_matrix

    if limited && rows > 1 && length(support(d)) >= rows
        for (x,p) in Iterators.take(weighted_iterator(d), rows-1)
            push!(strings, sprint(show, x)) # maybe this should have conext=:compact=>true
            push!(probs, p)
        end

        push!(strings, "<everything else>")
        push!(probs, 1.0-sum(probs))
    else
        for (x,p) in weighted_iterator(d)
            push!(strings, sprint(show, x))
            push!(probs, p)
        end
    end
    show(io, mime, barplot(strings, probs, title=title))
end

showdistribution(io::IO, d; kwargs...) = showdistribution(io, MIME("text/plain"), d; kwargs...)
showdistribution(d; kwargs...) = showdistribution(stdout, d; kwargs...)
