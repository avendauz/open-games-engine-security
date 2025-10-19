{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveGeneric #-}

module IDS.IDSModel where 
import Test.QuickCheck
import Graphics.Rendering.Chart.Easy
import Graphics.Rendering.Chart.Backend.Diagrams(toFile)

class IDSAPayoff a b where 
    unifyPayoff :: IDSParams a -> VisitorType -> VisitorMove -> b -> (Double, Double)

data IDSParams a = IDSParams {
   probDetected :: a -> Double,
   costOfAttack :: Double,
   costOfDefense :: a -> Double,
   attackImpact :: Double,
   priorDistributionAttacker :: Double,
   computingResources :: Double,
   basePayoff :: Double,
   computationReductionUnderAttack :: Double
} 

type IDSParamsSimple = IDSParams ()

type IDSParamsHP = IDSParams HoneypotAllocation

exampleData :: IDSParams ()
exampleData = IDSParams {
    probDetected = const 0.2,
    costOfAttack = 20,
    costOfDefense = const 10,
    attackImpact = 10,
    priorDistributionAttacker = 0.5,
    computingResources = 100,
    basePayoff = 100,
    computationReductionUnderAttack = 70
}

probAttacker prob = IDSParams {
    probDetected = const 0.2,
    costOfAttack = 20,
    costOfDefense = const 10,
    attackImpact = 10,
    priorDistributionAttacker = prob,
    computingResources = 100,
    basePayoff = 100,
    computationReductionUnderAttack = 70
}


data HoneypotAllocation = HighInteractionHP | LowInteractionHP | Normal deriving (Eq, Show)

data VisitorMove = Access | DoesNotAccess deriving (Eq,Ord, Show)

data VisitorType = Attacker | User deriving (Eq, Ord, Show)

data AggregatorMove = Open | Close deriving (Eq, Ord, Show)


totalGen :: Gen (IDSParams ())
totalGen = 
    do 
        probDetected <- choose (0,1)
        return IDSParams {
                probDetected = const probDetected,
                costOfAttack = 20,
                costOfDefense = const 10,
                attackImpact = 10,
                priorDistributionAttacker = 0.5,
                computingResources = 100,
                basePayoff = 100,
                computationReductionUnderAttack = 70
        }

instance Arbitrary (IDSParams ()) where 
    arbitrary = totalGen

