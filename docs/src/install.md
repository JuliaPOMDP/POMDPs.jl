# Installation

If you have a running Julia distribution (Julia 0.4 or greater), you have everything you need to install POMDPs.jl. To install the package, simply
run the following from the Julia REPL:
```julia
import Pkg
Pkg.add("POMDPs") # installs the POMDPs.jl package
```

Some auxiliary packages and older versions of solvers may be found in the JuliaPOMDP registry. To install this registry, run:
```julia
using Pkg; pkg"registry add https://github.com/JuliaPOMDP/Registry"
```

Note: to use this registry, [JuliaPro](https://juliacomputing.com/products/juliapro) users must also run `edit(normpath(Sys.BINDIR,"..","etc","julia","startup.jl"))`, comment out the line `ENV["DISABLE_FALLBACK"] = "true"`, save the file, and restart JuliaPro as described in [this issue](https://github.com/JuliaPOMDP/POMDPs.jl/issues/249).
