let
    pomdp = BabyPOMDP()
    up = updater(pomdp)

    bmdp = GenerativeBeliefMDP(pomdp, up)
    b = initialstate(bmdp, Random.GLOBAL_RNG)
end
