module IDS.IDSAStochastic where 

{-

Building on top of the honeypot and the standard IDSA games, we can introduce any data structure to iterate over.

By encoding the state as a data structure, we can modify the payoff module accordingly without changing the logic. While the players 
have complete knowledge of the format of the game, we shouldn't have to completely redefine a game in its entierety for this change 

-}

