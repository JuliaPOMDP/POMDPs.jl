# [POMDPTools: the standard library for POMDPs.jl](@id pomdptools_section)

The POMDPs.jl package does nothing more than define an *interface* or *language* for interacting with and solving (PO)MDPs; it does not contain any implementations. In practice, defining and solving POMDPs is made vastly easier if some commonly-used structures are provided. The POMDPTools package contains these implementations. Thus, the relationship between POMDPs.jl and POMDPTools is similar to the relationship between a programming language and its [standard library](https://en.wikipedia.org/wiki/Standard_library).

The contents of the library are outlined below:

```@contents
Pages = ["distributions.md", "beliefs.md"]
```
