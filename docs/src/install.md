# Installation

If you have a running Julia distribution (Julia 0.4 or greater), you have everything you need to install POMDPs.jl. To install the package, simply
run the following from the Julia REPL:
```julia
import Pkg
Pkg.add("POMDPs") # installs the POMDPs.jl package
```

Once you have POMDPs.jl installed, you can install any package that is part of the JuliaPOMDP community by running:
```julia
using POMDPs, Pkg
POMDPs.add_registry()
Pkg.add("SARSOP") # installs the SARSOP solver
```

The code above will download and install all dependencies automatically. All JuliaPOMDP packages have been tested on
Linux and OS X, and most have been tested on Windows.

To get a list of all the available packages run:
```julia
POMDPs.available() # prints a list of all the available packages that can be installed with POMDPs.add
```

