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

