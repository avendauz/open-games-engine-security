
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
import IDS.IDSModel (exampleData)
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


main :: IO () 
main = hspec $ do 
    describe "impact of linear influence networks" $ do 
        