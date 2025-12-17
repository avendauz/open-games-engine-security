module IDS.CollaborativeIDSModel where 

import IDS.IDSModel
import Data.HashMap (Map)

data State = Healthy | Compromised deriving (Eq, Ord, Show)

data CollaborativeIDSParams a = CIDSParams {
    probCompromisedTransition :: Double,
    costOfDeployment :: a -> Double,
    trustValue :: Map String Double

}

transitionBetweenStates :: VisitorType -> VisitorMove -> HoneypotAllocation -> State -> State 
transition