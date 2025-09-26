module IDS.HierarchalIDSModel where 



data HIDSParams = HIDSParams {
   probDetected :: Double,
   costOfAttack :: Double,
   costOfDefense :: Double,
   attackImpact :: Double,
   priorDistributionDefender :: Double,
   priorDistributionAttacker :: Double,
   computingResources :: Double,
   basePayoff :: Double,
   computationReductionUnderAttack :: Double,
   totalDefensiveResources :: Double
}

exampleHIDSParams = HIDSParams {
    probDetected = 0.2,
    costOfAttack = 20,
    costOfDefense = 10,
    attackImpact = 10,
    priorDistributionDefender = 0.5, 
    priorDistributionAttacker = 0.5,
    computingResources = 100,
    basePayoff = 100,
    computationReductionUnderAttack = 70,
    totalDefensiveResources = 100
}

data HoneypotAllocation = HighInteractionHP | LowInteractionHP | Normal deriving (Eq, Show)


data IDSMove = Report | AllClear deriving (Eq, Ord, Show)
