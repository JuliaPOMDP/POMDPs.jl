using Base.Test

using POMDPs
type A <: POMDP{Bool,Bool,Bool} end
@test_throws ErrorException discount(A())

@test POMDPs.strip_arg(:a) == :a
@test POMDPs.strip_arg(parse("a::Int")) == :a
kw_expr = Expr(:kw, parse("a::Int"), false, Any)
@test POMDPs.strip_arg(kw_expr) == :a

POMDPs.@pomdp_func testfunc(a, b::Int, c::Bool=false)
@test_throws ErrorException testfunc(1,2)
