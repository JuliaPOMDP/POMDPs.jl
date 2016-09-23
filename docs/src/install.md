# Installation

If you have a running Julia distriubtion (Julia 0.4 or greater), you have everything you need to install POMDPs.jl. To install the package, simply
run the following from the Julia REPL:
```julia
Pkg.add("POMDPs") # installs the POMDPs.jl package
```

Once you have POMDPs.jl installed, you can install any package that is part of the JuliaPOMDP community by running:
```julia
using POMDPs
POMDPs.add("SARSOP") # installs the SARSOP solver
```

The code above will download and install all dependencies automatically. All JuliaPOMDP packages have been tested on
Linux and OS X, and most have been tested on Windows.

To get a list of all the availible packages run:
```julia
POMDPs.available() # prints a list of all the availible packages that can be installed with POMDPs.add
```

Due to the modular nature of the framework, you can choose to only install select solvers/support tools. However,
if you want to install all of the supported JuliaPOMDP packages you can run the following code:

```julia
POMDPs.add_all() # installs all the JuliaPOMDP packages (may take a few minutes)
```

If you want to avoid any non-Julia dependencies, run:
```julia
POMDPs.add_all(native_only=true)
```
