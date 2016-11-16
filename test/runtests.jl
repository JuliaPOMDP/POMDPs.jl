using Base.Test

using POMDPs
type A <: POMDP{Int,Bool,Bool} end
@test_throws MethodError n_states(A())
@test_throws MethodError state_index(A(), 1)

@test POMDPs.strip_arg(:a) == :a
@test POMDPs.strip_arg(parse("a::Int")) == :a
kw_expr = Expr(:kw, parse("a::Int"), false, Any)
@test POMDPs.strip_arg(kw_expr) == :a
@test POMDPs.strip_curly(parse("f")) == :f
@test POMDPs.strip_curly(parse("f{S,A}")) == :f

POMDPs.@pomdp_func testfunc(a, b::Int, c::Bool=false)
@test_throws MethodError testfunc(1,2)
