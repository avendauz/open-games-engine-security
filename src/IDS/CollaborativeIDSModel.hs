module IDS.CollaborativeIDSModel where 

import IDS.IDSModel
import Data.HashMap (HashMap)

data State = Healthy | Compromised deriving (Eq, Ord, Show)


data CollaborativeIDSParams a = CIDSParams {
    probCompromisedTransition :: Double,
    costOfDeployment :: a -> Double,
    trustValue :: HashMap String Double,

}

-- transitionBetweenStates :: VisitorType -> VisitorMove -> HoneypotAllocation -> State -> State 
-- transition