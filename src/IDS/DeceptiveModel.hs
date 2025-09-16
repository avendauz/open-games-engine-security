module IDS.DeceptiveModel where 
import Test.QuickCheck 
import Security.Evaluator

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
} deriving (Show)

exampleDeceptionParams = DeceptionParams {
    probActive = (10  + 5) / (10 + 5 + 8 + 4) ,
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
temp probActive = DeceptionParams {
    probActive = probActive,
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

-- checks: 
attackerRewardCheck = (>) <$> attackerSuccess <*> attackerProbeSuccess 
visitorRewardCheck = (>) <$> attackerCaughtByHonepot <*> attackerProbeCaughtByHoneypot

parameterRestrictions params = all ($ params) [attackerRewardCheck, visitorRewardCheck]


totalGen :: Gen DeceptionParams
totalGen = 
    do 
        probActive <- choose (0,1)
        attackerSuccess <- choose (0,20)
        attackerProbeSuccess <- choose (0,20)
        --attackerProbeCaughtByHoneypot <- choose (0,20)
        (suchThatParamsSatisfy parameterRestrictions . pure) DeceptionParams {
            probActive = probActive,
            attackerSuccess = attackerSuccess,
            attackerProbeSuccess = attackerProbeSuccess,
            --attackerProbeCaughtByHoneypot = attackerProbeCaughtByHoneypot,
            attackerProbeCaughtByHoneypot = 0,
            attackerCaughtByHonepot = 20,
            defenderAdmitsUser = 10,
            defenderCatchesAttacker = 8,
            defenderPenaltyForAttack = 4,
            defenderHoneypotCost = 3,
            defenderProbingCost = 4,
            deviation = 0.2
        }

instance Arbitrary DeceptionParams where 
    arbitrary = totalGen

propDeception :: DeceptionParams -> Bool
propDeception params = attackerSuccess params > attackerProbeSuccess params
