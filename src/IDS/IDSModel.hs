module IDS.IDSModel where 



data IDSParams = IDSParams {
   probDetected :: Double,
   costOfAttack :: Double,
   costOfDefense :: Double,
   attackImpact :: Double,
   priorDistributionDefender :: Double,
   priorDistributionAttacker :: Double,
   computingResources :: Double,
   basePayoff :: Double,
   computationReductionUnderAttack :: Double
}

exampleData = IDSParams {
    probDetected = 0.2,
    costOfAttack = 20,
    costOfDefense = 10,
    attackImpact = 10,
    priorDistributionDefender = 0.5, 
    priorDistributionAttacker = 0.5,
    computingResources = 100,
    basePayoff = 100,
    computationReductionUnderAttack = 70
}

data HoneypotAllocation = HighInteractionHP | LowInteractionHP | Normal deriving (Eq, Show)

data VisitorMove = Access | DoesNotAccess deriving (Eq,Ord, Show)

data VisitorType = Attacker | User deriving (Eq, Ord, Show)

data AggregatorMove = Open | Close deriving (Eq, Ord, Show)

