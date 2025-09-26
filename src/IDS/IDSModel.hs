{-# LANGUAGE MultiParamTypeClasses #-}
module IDS.IDSModel where 


class IDSAPayoff a b where 
    unifyPayoff :: IDSParams a -> VisitorType -> VisitorMove -> b -> (Double, Double)

data IDSParams a = IDSParams {
   probDetected :: a -> Double,
   costOfAttack :: Double,
   costOfDefense :: a -> Double,
   attackImpact :: Double,
   priorDistributionDefender :: Double,
   priorDistributionAttacker :: Double,
   computingResources :: Double,
   basePayoff :: Double,
   computationReductionUnderAttack :: Double
}

type IDSParamsSimple = IDSParams ()

type IDSParamsHP = IDSParams HoneypotAllocation

exampleData = IDSParams {
    probDetected = const 0.2,
    costOfAttack = 20,
    costOfDefense = const 10,
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

