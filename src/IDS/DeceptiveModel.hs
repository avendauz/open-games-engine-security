module IDS.DeceptiveModel where 

data DeceptiveType = Passive | Active deriving (Eq, Ord, Show)

data DefenderRouting = Regular | Honeypot deriving (Eq, Ord, Show)

data AttackerDeceptiveMove = Normal | Suspicious deriving (Eq, Ord, Show)

data DeceptionParams = DeceptionParams {
    probActive :: Double, 
    attackerSuccess:: Double ,
    attackerProbeSuccess:: Double,
    attackerProbeCaughtByHoneypot :: Double ,
    attackerCaughtByHonepot :: Double,
    defenderAdmitsUser :: Double,
    defenderCatchesAttacker :: Double,
    defenderPenaltyForAttack :: Double,
    defenderHoneypotCost :: Double, 
    defenderProbingCost :: Double,
    deviation :: Double
}

exampleDeceptionParams = DeceptionParams {
    probActive = 0.5,
    attackerSuccess = 10,
    attackerProbeSuccess = 5,
    attackerProbeCaughtByHoneypot = 5,
    attackerCaughtByHonepot = 20,
    defenderAdmitsUser = 10,
    defenderCatchesAttacker = 8,
    defenderPenaltyForAttack = 4,
    defenderHoneypotCost = 3,
    defenderProbingCost = 4,
    deviation = 0.2
}
