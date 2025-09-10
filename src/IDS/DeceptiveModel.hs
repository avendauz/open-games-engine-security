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

