m = BabyPOMDP()

for step in stepthrough(m, Starve(), "s,a,o", max_steps=1)
    gfx = render(m, step)
    show(stdout, MIME("text/plain"), gfx)
end
