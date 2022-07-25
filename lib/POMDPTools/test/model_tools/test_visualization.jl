m = BabyPOMDP()

for step in stepthrough(m, Starve(), "s,a,o", max_steps=1)
    gfx = render(m, step)
    dummy_stream = IOBuffer()
    show(dummy_stream, MIME("text/plain"), gfx)
end
