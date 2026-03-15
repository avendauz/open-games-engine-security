{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE LambdaCase #-}

module IDS.CollaborativeIDSModel where 

import IDS.IDSModel
import Data.HashMap (Map)
import OpenGames.Engine.Engine
{-
Payoffs based on downtime? 

Module for including the resources available?

-}
data State = Healthy | Compromised deriving (Eq, Ord, Show)
{-
AAttacker = {Attack_httpd,
Attack_ftpd,
Continue_attacking,
Deface_website_leave,
Install_sniﬀer,
Run_DOS_virus,
Crack_ﬁle_server_root_password,
Crack_workstation_root_password,
Capture_data,
Shutdown_network,
φ},
-}


-- data AttackerWebserver
data CollaborativeIDSParams a = CIDSParams {
    probCompromisedTransition :: Double,
    costOfDeployment :: a -> Double,
    trustValue :: Map String Double

}

attackerStrategy :: Kleisli Stochastic Component AttackerActions
attackerStrategy = Kleisli (\case 
    WebServer -> playDeterministically HTTPD ; 
    FileServer -> playDeterministically SNIFFER;
    Workstation -> playDeterministically CRACKFSROOT;
    )  

-- instance ActionByComponent 
-- transitionBetweenComponents :: Component -> a ->  Component
