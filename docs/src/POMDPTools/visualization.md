# Visualization

POMDPTools contains a basic visualization interface consisting of the `render` function.

Problem writers should implement a method of this function so that their problem can be visualized in a variety of contexts including jupyter notebooks, web browsers, or saved as images or animations.

```@docs
render
```

Sometimes it is important to have control over how the problem is rendered with different mimetypes. One way to handle this is to have render return a custom type, e.g.
```julia
struct MyProblemVisualization
    mdp::MyProblem
    step::NamedTuple
end

POMDPTools.render(mdp, step) = MyProblemVisualization(mdp, step)
```
and then implement custom `show` methods, e.g.
```julia
show(io::IO, mime::MIME"text/html", v::MyProblemVisualization)
```
