{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveGeneric #-}

module IDS.IDSModel where 
import Test.QuickCheck
import Graphics.Rendering.Chart.Easy
import Graphics.Rendering.Chart.Backend.Diagrams(toFile)

{-
Problem statement: given an unknown visitor type and observing a visitor move, 
for different defensive action spaces determine the payoff. Here, b is a defensive action space

-}

data IDSParams = IDSParams {
   probDetected :: Double,
   costOfAttack :: Double,
   costOfDefense :: Double,
   attackImpact :: Double,
   priorDistributionAttacker :: Double,
   computingResources :: Double,
   basePayoff :: Double,
   computationReductionUnderAttack :: Double
} deriving Show

type IDSParamsSimple = IDSParams 

type IDSParamsHP = IDSParams

exampleData :: IDSParams
exampleData = IDSParams {
    probDetected = 0.2,
    costOfAttack = 20,
    costOfDefense = 10,
    attackImpact = 10,
    priorDistributionAttacker = 0.5,
    computingResources = 100,
    basePayoff = 100,
    computationReductionUnderAttack = 70
}

probAttacker prob = IDSParams {
    probDetected = 0.2,
    costOfAttack = 20,
    costOfDefense = 10,
    attackImpact = 10,
    priorDistributionAttacker = prob,
    computingResources = 100,
    basePayoff = 100,
    computationReductionUnderAttack = 70
}

probDetectedParams prob =  IDSParams {
    probDetected = prob,
    costOfAttack = 20,
    costOfDefense = 10,
    attackImpact = 10,
    priorDistributionAttacker = 0.5,
    computingResources = 100,
    basePayoff = 100,
    computationReductionUnderAttack = 70
}


data HoneypotAllocation = HighInteractionHP | LowInteractionHP | Normal deriving (Eq, Ord, Show)

data VisitorMove = Access | DoesNotAccess deriving (Eq,Ord, Show)

data VisitorType = Attacker | User deriving (Eq, Ord, Show)

data AggregatorMove = Open | Close deriving (Eq, Ord, Show)


totalGen :: Gen (IDSParams)
totalGen = 
    do 
        probDetected <- choose (0,1)
        return IDSParams {
                probDetected = probDetected,
                costOfAttack = 20,
                costOfDefense = 10,
                attackImpact = 10,
                priorDistributionAttacker = 0.5,
                computingResources = 100,
                basePayoff = 100,
                computationReductionUnderAttack = 70
        }

-- hpGen :: Gen (IDSParams HoneypotAllocation)
-- hpGen = 
--     do 


instance Arbitrary (IDSParams) where 
    arbitrary = totalGen

