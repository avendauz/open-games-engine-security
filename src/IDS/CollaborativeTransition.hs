{-# LANGUAGE MultiParamTypeClasses #-}
module IDS.CollaborativeTransition where 
import OpenGames.Engine.OpticClass


data WebsiteState a = WebsiteHacked | Protected (WebsiteState a)

class ActionByComponent s where 
    attackerAction :: s -> [a]
    defenderAction :: s -> [d]

class StateByComponent s where 
    nextState :: Component -> Stochastic s

data Component = WebServer | FileServer | Workstation deriving (Eq, Ord, Show)

data AttackerActions =  HTTPD | FTPD | CONTINUE | DEFACE | SNIFFER | DOS | CRACKFSROOT | CRACK
    deriving (Eq, Ord, Show)


class TransitionSystem a d where 
    next :: s -> (a, d) -> Stochastic s