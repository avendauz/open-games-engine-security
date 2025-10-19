{-# LANGUAGE LambdaCase #-}
module IDS.IDSAStrategies where 
import IDS.IDSModel

import OpenGames.Preprocessor
import OpenGames.Engine.BayesianGamesNonState

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

totalGameStrategies = const $ visitorStrategy ::- defenderStrategy ::- Nil
totalGameStrategiesMixed openProb = visitorStrategy ::- defenderStrategyMixed openProb ::- Nil

fixedDefenderStrat prob = visitorStrategyMixed prob ::- defenderStrategy ::- Nil

testBothMixed prob1 prob2 = visitorStrategyMixed prob1 ::- defenderStrategyMixed prob2 ::- Nil 

repeatedStrategies = convertVisitorStrategy visitorStrategy ::- convertDefenderStrategy defenderStrategy ::- Nil

visitorStrategy :: Kleisli Stochastic VisitorType VisitorMove
visitorStrategy = Kleisli (\case {
    Attacker -> playDeterministically Access;
    User -> playDeterministically Access
})

visitorStrategyMixed :: Double -> Kleisli Stochastic VisitorType VisitorMove 
visitorStrategyMixed prob = Kleisli (\case {
    Attacker -> distFromList [(Access, prob), (DoesNotAccess, 1- prob)];
    User -> playDeterministically Access
})

defenderStrategy :: Kleisli Stochastic VisitorMove AggregatorMove
defenderStrategy = Kleisli (\case {
    Access -> playDeterministically Open;
    DoesNotAccess -> playDeterministically Close;
})

defenderStrategyMixed :: Double -> Kleisli Stochastic VisitorMove AggregatorMove 
defenderStrategyMixed openProb = Kleisli (\case {
    Access -> distFromList [(Open, openProb), (Close, 1-openProb)];
    DoesNotAccess -> playDeterministically Close
})

hpDefenderStrategy :: Kleisli Stochastic VisitorMove HoneypotAllocation 
hpDefenderStrategy = Kleisli (\case {
    Access -> distFromList [(HighInteractionHP, 0.3), (LowInteractionHP, 0.1), (Normal, 0.6)];
    DoesNotAccess -> playDeterministically Normal;
})


convertVisitorStrategy :: Kleisli Stochastic VisitorType VisitorMove -> Kleisli Stochastic (VisitorType, VisitorMove, AggregatorMove) VisitorMove
convertVisitorStrategy x = Kleisli (\case {
    (User, _, _) -> runKleisli x User ;
    (Attacker, _ , _) -> runKleisli x Attacker
})

convertDefenderStrategy :: Kleisli Stochastic VisitorMove AggregatorMove -> Kleisli Stochastic (VisitorMove, AggregatorMove) AggregatorMove
convertDefenderStrategy x = Kleisli (runKleisli x . fst)
