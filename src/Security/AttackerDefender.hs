{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
module Security.AttackerDefender where 

import OpenGames.Engine.Engine hiding (StochasticStatefulOptic
                                      , StochasticStatefulBayesianOpenGame(..)
                                      , Agent(..)
                                      , dependentDecision
                                      , dependentEpsilonDecision
                                      , fromFunctions
                                      , fromLens
                                      , uniformDist
                                      , distFromList
                                      , pureAction
                                      , playDeterministically
                                      , discount
                                      , nature
                                      )

import           Data.Tuple.Extra (uncurry3)

import OpenGames.Preprocessor
import OpenGames.Engine.BayesianGamesNonState



-- natureVisitor :: Stochastic a -> OpenGame
--      StochasticOptic StochasticContext '[] '[] () () a ()
-- natureVisitor probAttacker = [opengame|
--    inputs : ;
--    feedback : ;
--    :----------------------------:

--    inputs : ;
--    feedback: ;
--    operation : nature b;
--    outputs   : visitorType;
--    returns : ;
--     :----------------------------:
--    outputs : visitorType;
--    returns : ;
-- |]



defenderFollower :: (Ord b, Show a, Show b, Eq a) => String -> (a -> [b]) -> OpenGame
     StochasticOptic
     StochasticContext
     '[Kleisli Stochastic a b]
     '[[DiagnosticInfoBayesian a b]]
     a
     ()
     b
     Double
defenderFollower defenderName getActionSpace = [opengame|

   inputs    :  attackerDecision;
   feedback  :  ;

   :----------------------------:
   inputs    : attackerDecision;
   feedback  :      ;
   operation : dependentDecision defenderName getActionSpace;
   outputs   : defenderDecision;
   returns   : defenderPayoff ;
   :----------------------------:

   outputs   : defenderDecision;
   returns   : defenderPayoff;
|]


attackerLeader attackerName getActionSpace = [opengame| 
    inputs: visitorType ;
    feedback: ;
    :----------------------------:
    inputs : visitorType ;
    feedback: ;
    operation: dependentDecision attackerName getActionSpace;
    outputs: attackerDecision;
    returns : attackerPayoff ;

    :----------------------------:
    outputs: attackerDecision;
    returns : attackerPayoff;

|]


calculatePayoff _ _ _ = playDeterministically (10, -10)



defenderLeader defenderName getActionSpace = [opengame|

   inputs    :  ;
   feedback  :  ;

   :----------------------------:
   inputs    : ;
   feedback  :      ;
   operation : dependentDecision defenderName getActionSpace;
   outputs   : defenderDecision;
   returns   : defenderPayoff ;
   :----------------------------:

   outputs   : defenderDecision;
   returns   : defenderPayoff;

 |]

-- attackerDefenderGame getAttackerActionSpace getDefenderActionSpace = [opengame|
--    inputs    :  ;
--    feedback  :  ;

--    :----------------------------:

--    inputs    : ;
--    feedback  :      ;
--    operation : attackerLeader "Alice" getAttackerActionSpace;
--    outputs   : attackerDecision ;
--    returns   : attacker;

--    inputs    : defenseResourceAllocation, visitorDecision;
--    feedback  :      ;
--    operation : defenderFollower "A" getDefenderActionSpace;
--    outputs   : defenderDecision ;
--    returns   : aggregatorPayoff;

-- :----------------------------:

--    outputs   :;
--    returns   : ;
-- |]
