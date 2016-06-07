# Frequently Asked Questions (FAQ)

## How do I save my policies?

We reccomend using [JLD](https://github.com/JuliaIO/JLD.jl) to save the whole policy object. This is the simplest, and
failry efficient way to save Julia objects. JLD uses HDF5 format underneath. If you've already computed a policy, you
can simply run:

```julia
using JLD
save("my_policy.jld", "policy", policy) 
```
