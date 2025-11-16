%include polycode.fmt

\begin{code}

repeatedStage actionSpaceAttacker attackerName actionSpaceDefender defenderName payoffGame = [opengame|
   inputs : visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: [(payoffIndexer previousPayoffs 0) + attackerPayoff, (payoffIndexer previousPayoffs 1) + defenderPayoff];
   :----------------------------:

   inputs: visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   operation: attackerLeader attackerName actionSpaceAttacker;
   outputs: attackerDecision;
   returns: (payoffIndexer previousPayoffs 0) + attackerPayoff;

   inputs: prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   operation: defenderFollower defenderName actionSpaceDefender;
   outputs: defenderDecision;
   returns: (payoffIndexer previousPayoffs 1) + defenderPayoff;

   inputs: visitorType, attackerDecision, defenderDecision;
   feedback: ;
   operation: payoffGame;
   outputs: attackerPayoff, defenderPayoff;
   returns : ;
   :----------------------------:

   outputs: visitorType, attackerDecision, defenderDecision;
   returns: previousPayoffs;
|]


repeatedPayoffGame params payoffReader1 payoffReader2 = [opengame|
   inputs : visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   :----------------------------:

   inputs: visitorType, prevAttackerDecision, prevDefenderDecision;
   feedback: ;
   operation: liftStochastic (\(x,y,z) -> playDeterministically (calculateCurrAttackerPayoff x y z, calculateCurrDefenderPayoff x y z));
   outputs: payoff1, payoff2;
   returns: ;

   :----------------------------:

   outputs: payoff1, payoff2;
   returns: ;

 |] where calculateCurrAttackerPayoff x y z = runPayoff params (payoffReader1 x y z)
          calculateCurrDefenderPayoff x y z = runPayoff params (payoffReader2 x y z)

\end{code}
