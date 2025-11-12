{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
module IDS.IDSAPayoffHP where
import Security.ParameterBuilder
import Control.Monad.Reader

import           Data.Tuple.Extra (uncurry3)
import IDS.IDSModel
import Data.Bifunctor
import Control.Applicative
import IDS.IDSAPayoff


visitorPayoffHP :: VisitorType -> VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
visitorPayoffHP = \case {
    Attacker -> attackerPayoffHP ;
    User ->  userPayoffHP
}

defenderPayoffHP :: VisitorType -> VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
defenderPayoffHP = \case {
    Attacker -> defenderUnderAttackPayoffHP;
    User -> defenderNormalPayoffHP;
}


attackerPayoffHP :: VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
attackerPayoffHP Access hp = attackerAccessPayoffHP hp
attackerPayoffHP DoesNotAccess HighInteractionHP = (* (-1)) <$> attackerAccessPayoffHP HighInteractionHP
attackerPayoffHP DoesNotAccess LowInteractionHP = (* (-1.5)) <$> attackerAccessPayoffHP LowInteractionHP
attackerPayoffHP DoesNotAccess Normal = (* (-2.5)) <$> attackerAccessPayoffHP Normal

augmentCostOfDefense :: HoneypotAllocation -> (PayoffReader IDSParams -> PayoffReader IDSParams) 
augmentCostOfDefense HighInteractionHP = local (\params -> params {costOfDefense = costOfDefense params * 2})
augmentCostOfDefense LowInteractionHP = local (\params -> params {costOfDefense = costOfDefense params * 1.5})
augmentCostOfDefense Normal = id

augmentComputingResources :: HoneypotAllocation -> (PayoffReader IDSParams -> PayoffReader IDSParams)
augmentComputingResources HighInteractionHP = local (\params -> params {computingResources = computingResources params * 0.7})
augmentComputingResources LowInteractionHP = local (\params -> params {computingResources = computingResources params * 0.5})
augmentComputingResources Normal = id
-- have an informed individual check this separately

augmentDetectionProb :: HoneypotAllocation -> (PayoffReader IDSParams -> PayoffReader IDSParams)
augmentDetectionProb HighInteractionHP = local (\params -> params {probDetected = 0.8})
augmentDetectionProb LowInteractionHP = local (\params -> params {probDetected = 0.65})
augmentDetectionProb Normal = local (\params -> params {probDetected = 0.5})




userPayoffHP :: VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
userPayoffHP Access allocation = augmentCostOfDefense allocation $ userPayoff Access Open
userPayoffHP _ _ = return 0



attackerAccessPayoffHP :: HoneypotAllocation -> PayoffReader IDSParamsHP
attackerAccessPayoffHP allocation = augmentDetectionProb allocation $ attackerAccessPayoff 

defenderUnderAttackPayoffHP :: VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
defenderUnderAttackPayoffHP Access hp = (augmentCostOfDefense hp . augmentDetectionProb hp) defenderAccessPayoff 
defenderUnderAttackPayoffHP DoesNotAccess _ = pure 0

defenderNormalPayoffHP :: VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
defenderNormalPayoffHP Access hp =  augmentCostOfDefense hp $ asks ((-) . computingResources) <*> asks costOfDefense
defenderNormalPayoffHP DoesNotAccess _ = asks $ (* (-1)) . computingResources


-- calculateExpectedValueOfAttack :: HoneypotAllocation -> IDSParamsHP -> Double
-- calculateExpectedValueOfAttack hp params =
--    attackImpact params * (basePayoff params - costOfAttack params) * (1 - probDetected params hp)
--    - costOfAttack params * probDetected params hp
