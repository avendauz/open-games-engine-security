module IDS.IDSASpec where 




import Test.QuickCheck
import OpenGames.Engine.BayesianGamesNonState
import OpenGames.Engine.Engine
import OpenGames.Preprocessor hiding (line)

import Test.Hspec
import IDS.IDSA
import IDS.IDSAStrategies
import Security.ParameterBuilder
import IDS.IDSAPayoff
import IDS.IDSAPayoffHP
import OpenGames.Engine.Diagnostics
import IDS.IDSModel (exampleData, IDSParams (IDSParams), probAttacker, probDetectedParams)
{-
The defender wants to allow only the right users
to access regular systems and trap those with malicious intents.
-}


-- main :: IO ()
-- main = hspec $ do
--   describe "Prelude.head" $ do
--     it "returns the first element of a list" $ do
--       head [23 ..] `shouldBe` (23 :: Int)

--     it "returns the first element of an *arbitrary* list" $
--       property $ \x xs -> head (x:xs) == (x :: Int)

mixedStrategyParams = [0, 0.05 .. 1.0]

testMixedStrats params visitorProb prob = generateEquilibrium $ evaluate (idsAGame params) (visitorStrategyMixed visitorProb ::- defenderStrategyMixed prob ::- Nil ) (instantiateContext visitorPayoff defenderPayoff params)

showIdsGame params = generateOutput $ evaluate (idsAGame params) (totalGameStrategies params) (instantiateContext visitorPayoff defenderPayoff params)

showIdsHPGame params = generateOutput $ evaluate (idsHPGame params) (totalHPGameStrategies params) (instantiateContext visitorPayoffHP defenderPayoffHP params)
getIDSPayoff params = let [a,b] = generatePayoff $ evaluate (idsAGame params) (totalGameStrategies params) (instantiateContext visitorPayoff defenderPayoff params) in tail b 
getIDSHPPayoff i j params = let [c, d] = generatePayoff $ evaluate (idsHPGame params) (testingHPStrats i j) (instantiateContext visitorPayoffHP defenderPayoffHP params) in tail d 

main :: IO () 
main = hspec $ do 
    describe "IDSA vs IDSHP params" $ do        
        -- it "should never be an equilibrium to not defend" $ 
        --     property $ \params -> generateEquilibrium $ evaluate (idsAGame params) (totalGameStrategies params) (instantiateContext visitorPayoff defenderPayoff params)

        -- {-
        -- Result 1: for probDetected = 0.9484, given that the visitor always accesses, is in equilibrium, despite never defending
        -- -}
        -- it "should have some equilibrium for mixed strategies for a 75% chance of a visitor choosing to access" $ 
        --     property $ \params -> or $ map (testMixedStrats params 0.75) mixedStrategyParams

        -- {-
        -- Result 2: this test fails for a probDetected 0.85. Now we can try refining our model to find the bounds for which 
        -- this test passes
        -- -}

        -- it "should have some equilibrium for mixed strategies for a 75% chance of an attacker, up to some probability of detection" $ do 
        --    ( or $ map (\p -> or $ map (testMixedStrats (probDetectedParams p) 0.75) mixedStrategyParams) mixedStrategyParams )`shouldBe` True 

        
        it "improves performance by having more defensive resources for some strategies" $ 
            property $ \params -> or [getIDSHPPayoff x y params > getIDSPayoff params | x <- [0, 0.1 .. 1], y <- [0, 0.1 .. 1]]
    describe "repeated games" $ do 
        it "should have a stationary equilibrium" $ property $ 
            \x -> doRepeatedEvaluation exampleData x 3