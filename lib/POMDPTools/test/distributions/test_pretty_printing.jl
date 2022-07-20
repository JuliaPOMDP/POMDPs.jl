d = SparseCat([1,2], [0.5, 0.5])
@test occursin("SparseCat", sprint(showdistribution, d))

d = SparseCat(1:50, fill(1/50, 50))
iob = IOBuffer()
io = IOContext(iob, :limit=>true, :displaysize=>(10, 7))
showdistribution(io, d)
str = String(take!(iob))
@test occursin("SparseCat", str)
@test occursin("<everything else>", str)

# test that it doesn't print <everything else> when there are enough lines
d = SparseCat([:a], 1.0)
iob = IOBuffer()
io = IOContext(iob, :limit=>true, :displaysize=>(10, 7))
showdistribution(io, d)
str = String(take!(iob))
@test occursin("SparseCat", str)
@test !occursin("<everything else>", str)
