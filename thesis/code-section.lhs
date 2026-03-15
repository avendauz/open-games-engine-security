%include polycode.fmt
\begin{code}
defenderLeader defenderName getActionSpace = [opengame|

inputs    :  ;
feedback  :  ;

:----------------------------:
inputs    : ;
feedback  :      ;
operation : dependentDecision defenderName getActionSpace;
outputs   : defenderDecision;
returns   : defenderPayoff ;
:----------------------------:

outputs   : defenderDecision;
returns   : defenderPayoff;

|]

\end{code}