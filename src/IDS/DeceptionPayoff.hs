{-# LANGUAGE LambdaCase #-}

module IDS.DeceptionPayoff where 
import Security.ParameterBuilder
import IDS.DeceptiveModel
import Test.QuickCheck
import Control.Monad.Reader
import Control.Applicative
import Data.Bifunctor
-- satisfying: 

-- unifyPayoff :: DeceptionParams -> DeceptiveType -> AttackerDeceptiveMove -> DefenderRouting -> (Double, Double)
-- unifyPayoff params deceptionType deceptionMove defensiveRouting = 
--     join bimap (runPayoff params) (visitorPayoff deceptionType deceptionMove defensiveRouting, defenderPayoff deceptionType deceptionMove defensiveRouting)

visitorPayoffDeceptive :: DeceptiveType -> AttackerDeceptiveMove -> DefenderRouting -> PayoffReader DeceptionParams
visitorPayoffDeceptive = \case {
    Active -> activePayoff ;
    Passive -> passivePayoff
}

activePayoff :: AttackerDeceptiveMove -> DefenderRouting -> PayoffReader DeceptionParams
activePayoff Suspicious Regular = asks attackerSuccess
activePayoff Suspicious Honeypot = asks $ (*(-1)) <$> attackerCaughtByHonepot
activePayoff Normal Regular = asks attackerSuccess 
activePayoff Normal Honeypot = asks $ (*(-1)) <$> attackerCaughtByHonepot

passivePayoff :: AttackerDeceptiveMove -> DefenderRouting -> PayoffReader DeceptionParams
passivePayoff Suspicious Regular = asks attackerProbeSuccess
passivePayoff Suspicious Honeypot = asks $ (*(-1)) <$> attackerProbeCaughtByHoneypot
passivePayoff Normal Regular = asks $ (*(-1)) <$> attackerSuccess 
passivePayoff Normal Honeypot = pure 0


defenderPayoffDeceptive :: DeceptiveType -> AttackerDeceptiveMove -> DefenderRouting -> PayoffReader DeceptionParams
defenderPayoffDeceptive = \case {
    Active -> defenderAgainstActivePayoff;
    Passive -> defenderAgainstPassivePayoff
}

defenderAgainstActivePayoff :: AttackerDeceptiveMove -> DefenderRouting -> PayoffReader DeceptionParams 
defenderAgainstActivePayoff Suspicious Regular = asks $ (*(-1)) <$> defenderPenaltyForAttack
defenderAgainstActivePayoff Suspicious Honeypot = asks defenderCatchesAttacker
defenderAgainstActivePayoff Normal Regular = asks $ (*(-1)) <$> defenderPenaltyForAttack
defenderAgainstActivePayoff Normal Honeypot = asks defenderCatchesAttacker

defenderAgainstPassivePayoff :: AttackerDeceptiveMove -> DefenderRouting -> PayoffReader DeceptionParams
defenderAgainstPassivePayoff Suspicious Regular = asks $ (*(-1)) <$> defenderProbingCost 
defenderAgainstPassivePayoff Suspicious Honeypot = pure 0
defenderAgainstPassivePayoff Normal Regular = asks defenderAdmitsUser 
defenderAgainstPassivePayoff Normal Honeypot = asks $ (*(-1)) <$> defenderHoneypotCost