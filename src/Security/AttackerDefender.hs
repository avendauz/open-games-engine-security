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
import OpenGames.Preprocessor
import OpenGames.Engine.BayesianGamesNonState




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
    inputs: ;
    feedback: ;
    :----------------------------:
    inputs : ;
    feedback: ;
    operation: dependentDecision attackerName getActionSpace;
    outputs: attackerDecision;
    returns : ;

    :----------------------------:
    outputs: attackerDecision;
    returns : attackerPayoff;

|]

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

attackerDefenderGame getAttackerActionSpace getDefenderActionSpace = [opengame|
   inputs    :  ;
   feedback  :  ;

   :----------------------------:

   inputs    : ;
   feedback  :      ;
   operation : attackerLeader "Alice" getAttackerActionSpace;
   outputs   : attackerDecision ;
   returns   : attacker;

   inputs    : defenseResourceAllocation, visitorDecision;
   feedback  :      ;
   operation : defenderFollower "A" getDefenderActionSpace;
   outputs   : defenderDecision ;
   returns   : aggregatorPayoff;

:----------------------------:

   outputs   :;
   returns   : ;
|]
