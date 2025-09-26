{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
module IDS.IDSAPayoffHP where
import Security.ParameterBuilder
import Control.Monad.Reader

import           Data.Tuple.Extra (uncurry3)
import IDS.IDSModel
import Data.Bifunctor
import Control.Applicative

instance IDSAPayoff HoneypotAllocation HoneypotAllocation where 
    unifyPayoff params visitorType visitorMove aggMove = join bimap (runPayoff params) (visitorPayoff visitorType visitorMove aggMove,defenderPayoff visitorType visitorMove aggMove)

visitorPayoff :: VisitorType -> VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
visitorPayoff = \case {
    Attacker -> attackerPayoff ;
    User ->  userPayoff
}

defenderPayoff :: VisitorType -> VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
defenderPayoff = \case {
    Attacker -> defenderUnderAttackPayoff ;
    User -> defenderNormalPayoff;
}


attackerPayoff :: VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
attackerPayoff Access hp = attackerAccessPayoff hp
attackerPayoff DoesNotAccess HighInteractionHP = (* (-1)) <$> attackerAccessPayoff HighInteractionHP
attackerPayoff DoesNotAccess LowInteractionHP = (* (-1.5)) <$> attackerAccessPayoff LowInteractionHP
attackerPayoff DoesNotAccess Normal = (* (-2.5)) <$> attackerAccessPayoff Normal

userPayoff :: VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
userPayoff Access HighInteractionHP = do
    computingResources <- asks computingResources
    costOfDefense <- ($ HighInteractionHP ) <$> asks costOfDefense
    return $ (computingResources - costOfDefense) / computingResources
userPayoff Access LowInteractionHP = do
    computingResources <- asks computingResources
    costOfDefense <- ($ LowInteractionHP ) <$> asks costOfDefense
    return $ (computingResources - costOfDefense) / computingResources
userPayoff Access Normal = do
    computingResources <- asks computingResources
    costOfDefense <- ($ Normal ) <$> asks costOfDefense
    return $ (computingResources - costOfDefense) / computingResources
userPayoff _ _ = return 0


attackerAccessPayoff :: HoneypotAllocation -> PayoffReader IDSParamsHP
attackerAccessPayoff HighInteractionHP =
     do
        costOfAttack <- asks costOfAttack
        basePayoff <- asks basePayoff
        probDetected <- ($ HighInteractionHP) <$> asks probDetected
        return $ (basePayoff - costOfAttack) * (1 - probDetected) - costOfAttack * probDetected     
attackerAccessPayoff LowInteractionHP =
     do
        costOfAttack <- asks costOfAttack
        basePayoff <- asks basePayoff
        probDetected <- ($ LowInteractionHP) <$> asks probDetected
        return $ (basePayoff - costOfAttack) * (1 - probDetected) - costOfAttack * probDetected    
attackerAccessPayoff Normal =
     do
        costOfAttack <- asks costOfAttack
        basePayoff <- asks basePayoff
        probDetected <- ($ Normal) <$> asks probDetected
        return $ (basePayoff - costOfAttack) * (1 - probDetected) - costOfAttack * probDetected    

defenderUnderAttackPayoff :: VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
defenderUnderAttackPayoff Access hp = defenderAccessPayoff hp
defenderUnderAttackPayoff DoesNotAccess _ = pure 0

defenderNormalPayoff :: VisitorMove -> HoneypotAllocation -> PayoffReader IDSParamsHP
defenderNormalPayoff Access hp =  (-) <$> asks computingResources <*> asks (($ hp) . costOfDefense)
defenderNormalPayoff DoesNotAccess _ = asks $ (* (-1)) . computingResources

defenderAccessPayoff :: HoneypotAllocation -> PayoffReader IDSParamsHP
defenderAccessPayoff hp =
    do
        params <- ask
        costOfDefense <- asks $ ($ hp ) . costOfDefense
        probDetection <- asks $ ($ hp) . probDetected
        computingResources <- asks computingResources
        computationReductionUnderAttack <- asks computationReductionUnderAttack
        return $ (computingResources - costOfDefense) * (probDetection + (1 - probDetection) * computationReductionUnderAttack)

calculateExpectedValueOfAttack :: HoneypotAllocation -> IDSParamsHP -> Double
calculateExpectedValueOfAttack hp params =
   attackImpact params * (basePayoff params - costOfAttack params) * (1 - probDetected params hp)
   - costOfAttack params * probDetected params hp
