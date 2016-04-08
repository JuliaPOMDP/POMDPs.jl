# implements some default zero-argument constructors for bitstypes that do not have them (see issue #65)

# don't need these anymore since create_state was brought back
#=
Base.Bool() = zero(Bool)
Base.Int() = zero(Int)
Base.Float64() = zero(Float64)
=#
