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
repeatedStrategies = convertVisitorStrategy visitorStrategy ::- convertDefenderStrategy defenderStrategy ::- Nil

visitorStrategy :: Kleisli Stochastic VisitorType VisitorMove
visitorStrategy = Kleisli (\case {
    Attacker -> playDeterministically Access;
    User -> playDeterministically Access
})

defenderStrategy :: Kleisli Stochastic VisitorMove AggregatorMove
defenderStrategy = Kleisli (\case {
    Access -> playDeterministically Open;
    DoesNotAccess -> playDeterministically Close;
})


convertVisitorStrategy :: Kleisli Stochastic VisitorType VisitorMove -> Kleisli Stochastic (VisitorType, VisitorMove, AggregatorMove) VisitorMove
convertVisitorStrategy x = Kleisli (\case {
    (User, _, _) -> runKleisli x User ;
    (Attacker, _ , _) -> runKleisli x Attacker
})

convertDefenderStrategy :: Kleisli Stochastic VisitorMove AggregatorMove -> Kleisli Stochastic (VisitorMove, AggregatorMove) AggregatorMove
convertDefenderStrategy x = Kleisli (runKleisli x . fst)
