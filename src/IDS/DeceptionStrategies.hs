{-# LANGUAGE LambdaCase #-}
module IDS.DeceptionStrategies where 
import IDS.DeceptiveModel

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

deceptiveStrategies deviation = visitorStrategy deviation ::- defenderStrategy ::- Nil


visitorStrategy :: Double -> Kleisli Stochastic DeceptiveType AttackerDeceptiveMove
visitorStrategy deviation = Kleisli (\case {
    Passive -> distFromList [(Normal, deviation), (Suspicious, 1 - deviation)];
    Active -> playDeterministically Normal
})

defenderStrategy :: Kleisli Stochastic AttackerDeceptiveMove DefenderRouting
defenderStrategy = Kleisli (\case {
    Normal -> playDeterministically Regular;
    Suspicious -> playDeterministically Honeypot;
})
