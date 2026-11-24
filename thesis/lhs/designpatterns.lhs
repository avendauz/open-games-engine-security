\section{Modularity in game theoretic cybersecurity modelling}
\label{sec:designPatterns}
\subsection{Overview}

The stark reality of designing effective cybersecurity games is bridging real-world security concerns with an accurate representation in a game-theoretic terms. Numerous models have been constructed and analyzed according to specific security problems, thus tying the models to their specification. Furthermore, these models often extend or adapt previously existing constructions by making new assumptions, using different payoff schemes, or integrating the model into an automated defensive infrastructure. Although this informal relationship between these models have been surveyed, there has yet to be a generalized framework for mechanizing this relationship as a standardized game formulation process. On the other hand, as a software tool, open games can accommodate the security models setting, but not without specific Haskell setup-code for running and evaluating a model. Insofar that for investigating a large problem, an open games user can end up with a huge series of top-down Haskell scripts representing a specific simulation, with few structural or helper modules to tie everything together. In order to effectively develop a game formulation process using this tool, we need to identify compositional trends in cybersecurity games, then implement a small Haskell library to provide templates and helper functions for leveraging these compositional trends. Finally, we can follow a cybersecurity-games-as-code approach to iteratively test, generate, and improve models.
This culminates to a metamodelling design process over the \textit{open-games-hs} software. The structure of the chapter is summarized as follows: 
\begin{itemize}
	\item Section \ref{designPatterns:state} is a review detailing the need for such a design process
	\item Section \ref{designPatterns:directTranslation} details a direct translation of models from literature to serve as a baseline and identify key issues (model reuse, scalability, replicability) that should be addressed 
	\item Section \ref{designPatterns:library} is an introduction of three Haskell modules and one testing framework which encapsulate the design patterns that address those key issues 
	\item Section \ref{designPatterns:discussion} discusses project structure using the patterns defined in Section \ref{designPatterns:library} and project maintenance techniques with version control
	\item Section \ref{designPatterns:Iterative} proposes a test-driven, iterative modelling process
\end{itemize}


\subsection{State-of-the-art}
\label{designPatterns:state}
Using game theory to inform cybersecurity problems has seen growth in recent years with the development of a number of different models for evaluating Denial-of-Service attacks on cloud infrastructures, intrusion detection systems, and advanced persistent threats. Refer to the following surveys \cite{Pawlick2019}, \cite{Hausken2024}, \cite{Manshaei2013} for an overview of the wide collection of game-theoretic models. 

A general procedure for developing these models can be (roughly) summarized in the following steps: 
\begin{enumerate}
	\item Detail the security scenario and system, vectors of attack, and defensive capabilities
	\item Develop abstractions  and parameters for the players, actions, and payoff in a game-theoretic setting according to the security scenario
	\item Solve for a solution concept (i.e. Nash equilibrium, Subgame perfect Nash Equilibrium) using methods such as linear programming or Q-learning (for stochastic or repeated games)
	\item Deploy new strategies or technologies in the system according to the solution concept above
	\item Conduct simulations with a fixed strategy, determine the highest expected utility for players and evaluate system performance under these conditions
\end{enumerate}

However, the most recent concerns with evolving attacker threats and dynamic security situations requires more complex game-theoretic models. These games can be part of a larger automated defensive system to update defensive strategies in real time as part of a larger infrastructure such as in \cite{Jin2018}, \cite{Zhu2012}. The progression of these models often relies on the extension and variation of these game-theoretic models. For example, we may need to consider scaling the number of players or repeating strategic interactions. The models presented in \cite{Chen2009}, \cite{Nochenson2012} suggest the use of the models as a basis for extensions and increased-complexity for other security scenarios. Similarly in \cite{Pawlick2015}, the signalling game structure is derived from \cite{Carroll2009}, with adjustments to the utilities. We'll see later how these models written in open games allow for easy extensionality.

According to \cite{Collins2025} evaluating 86 different game-theoretic models in cybersecurity, there already exists a sense of homogeneity between these models, where 76\% of models only cover a two-player security interaction, and 79\% use Nash (or variants of) equilibrium solution concepts for analysis. The authors also recommended a formal method for modellers to state their assumptions of the model that follow more in-line with cybersecurity concepts. Expanding on this idea in particular, we propose that code-based methods for stating assumptions allows for clear, testable specifications. Only 24 of the 86 studies shown consider "multiple variants" of the constructed model. The specification of two criterion: (1) "Efficacy of Modelling" and (2) "Practicality of Solutions" serve as a framework for evaluating the tractability of game-theoretic models' representation of the underlying real cyber-interaction. The resulting recommendations should then be considered: \label{topic:collinsrec}
\begin{enumerate}
	\item The need for a game space abstraction 
	\item Allow for more flexible assumptions
\end{enumerate}

In that same vein, \cite{Egan2025}, \cite{Liang2013} call for better scalability of models, in particular addressing models that account for more than two player games. This falls more closely to tractable game models that more accurately reflect collaborative or networked defensive systems, but requires more complex equilibrium solutions. Similar to other game formulation methods, each model has a large input dataset of parameters to consider. 

Is the open-games-hs software equipped to address some of these issues? This thesis draws on a key motivation proposed by Zahn in \cite{ZahnCybercat}, towards the synthesis of an encoded library of microeconomic models. The process of developing the "correct" model is therefore framed as a software engineering problem. The open-games-engine has demonstrated its use verifying the most recognizable game theory problems like Prisoner's Dilemma, to auction mechanisms. A series of these models have been met with production-level directions, and a codebase of models have grown. While this thesis departs from the application of this field towards cybersecurity, the bulk of the work that is presented here is an attempt to give guidelines for using the open-games-engine effectively. Specifically, the interdisciplinary and workflow possibilities that are provided by producing models in this environment, achieving easy maneuverability and testing that fits naturally with the requirements for synthesizing effective security models. 

\cite{20squares} has a series of completed projects for auctions and blockchain staking protocols. Capturing the complexity of models with open games is shown in these previous projects, but this chapter will deliberate on formalizing common techniques used to generate these models. We invite readers to refer to the README for \cite{20squares} projects for the syntax of the open-games DSL and common operators that can be used. 

Most recently, \cite{tan2022a} demonstrates the open-games-engine use-case for modular law and contracting clauses as a software library \textit{Clause2Game}. His thesis strongly ties software engineering methodologies to clause law methodologies, which is reminiscent of our approach. For example, the resultant data sets already begin to hint at the need for a methodology for "closing games" with equilibrium analysis driven by random initial conditions using |Test.QuickCheck.Gen|. We hope that by explicitly providing a metamodelling, iterative process, this would be applicable beyond the field of security and pertain to collaboration between domain experts and game theory / open-games modellers. But overall, the open-games-hs software can be adapted to fit the modelling needs of the target discipline.  

Extensions to the original thesis \cite{HedgesThesis} on compositional game theory has been explored over recent years specifically to accommodate a wider scope of solution concepts and games. Whether it's describing subgame perfect equilibrium in a market entry game (\cite{hedges2017morphismsopengames}) or a methodology for translating games from extensive-form into open games (\cite{capucci2021translating}), there is still a major gap between these developments and \textit{open-games-hs}. While an exciting prospect (but out of the scope of this thesis), adding a pipeline for doing value-iteration to learn optimal policies for open games (\cite{hedgeslearning}) is possible. Further connections with control theory \cite{rodriguezsakamoto2026categorical} has continued to shed light on new avenues to take when doing game theoretic modelling with open games.  


%\subsubsection{Qualitative to quantitiative parameterization}
%\cite{Rass2017}
%This necessitates collaboration between a domain expert (e.g. cybersecurity expert) and a game-theorist to translate sensible payoff schemes and parameters. 
%
%On the other hand, databases such as NIST and CSVV are directly used in \cite{MacQueen2020} \cite{Furuncu2015}. Diving deeper into \cite{Chen2009}, the work does not consider correlation between attack targets and leaves it for future work. The theoretical basis for the payoffs involving reputation, punishment for loss contrasts with other payoffs using server downtime or capital expenditure from NIST (CVSS) metrics. 

\subsection{Direct translation}
\label{designPatterns:directTranslation}
This study begins by following a procedure to first naively translate models from literature without any design patterns or meta-modelling structure. 

\begin{enumerate}
	\item Identify pre-existing security game models in literature 
	\item Implement these models to reproduce the expected results using open games
	\item Identify and generalize constructions used across models
	\item Analyze flexibility of models and analytical techniques 
\end{enumerate}

For the first step, we minimized our game type search to a particular subset of two-player cybersecurity games, in the broad setting with a defender in the role of deploying resources for protecting a computer network. An attacker also broadly falls to a role of attempting to access or control this computer network. We did not place restrictions on selecting these models to align by the technologies being assessed or a fixed type of cybersecurity attack, with the eventual aim to abstract these away from the game formulation. By reviewing the aforementioned surveys, we found that that many games falling under this classification can then be organized by a game-type (Bayesian, Stochastic etc.) each with their own notations, parameter restrictions, and payoff formulations. 

In the second step, the unstructured approach is used to establish a baseline for this study by hardcoding each of these specifications into a Haskell module. To maintain expressiveness and readability, we use appropriate variable names and global-scope constants for model-specific values. However, we wrote each of these modules in isolation, without considering any relationship or replicability in other modules. 

In the following chapter, we primarily focus on the third point by codifying specific design patterns for a more generalized game construction process. We chose four models from literature as detailed in Table \ref{table:baseline} to serve as the baseline for direct translation from the corresponding paper to its representation as open games. 

For the final step, no metric has been established for conducting a comparative analysis with other tools. We leave this for a future behavioural study, for security modellers across disciplines and skillsets to follow the presented design patterns to generate models. Possible metrics could involve productivity or real-system performance determined by the findings extracted from a model. 

\begin{figure}
	\label{figure:DirectTranslation}
	\centering 
	\includegraphics[width=\linewidth]{DirectTranslation.png}
	\caption{Flowchart of direct translation design process with game dependencies}
\end{figure}

Ultimately, direct translation is a non-uniform process at first glance, since the structure and parameters of the game are highly-dependent on the game type. Each source game model comes with its own specification in differing formats. A natural language description of the game formulation is the initial descriptor of the model, but later use tables for storing game parameters, conditions, and graphical notations like extensive-form game trees as in \textbf{Honey} and transition graphs as in \textbf{IDSMark}. In \ref{figure:DirectTranslation}, the red arrows demonstrate the process of a modeller reading the source game formulation and directly implementing it into an open game. However, we can't establish a relationship between the analyses on the far left to any analysis in the open-game-engine on the far right. The open-game-engine analysis is only dependent on the types and functions required to make the open game code block executable such as strategies. 

The black dotted lines in the "Game model specification" represent a qualitative or quantitative dependency from one game to another. An example \label{example:quantDepend} of an explicit quantitative dependency is where \cite{Pawlick2015} specifically adapts a signalling game from \cite{Carroll2009} by maintaining the same game structure and payoff scheme. For a qualitative dependency, we note a similar game formulation between \textbf{Decep} and \textbf{Honey} centered around the uncertainty of the attacker's type and the problem of the defender to act according to some prior belief. We immediately recognize near-identical |Nature| operators, data types corresponding to whether a server is a honeypot or normal, and the payoffs using constants such as probability of detection associated with a specific detection library. At the game formulation level, any such adaptation would then be conducted by-hand, citing a particular security specification. We would like to show that the blue dotted lines in "Open games DSL" and "Open games engine" can be explicitly established thus allowing reproducibility and consistency in-code rather than by-hand. \footnote{We would also like any upstream changes in dependencies to be reflected in the resultant models}

Examining the resultant modules shows clear repetition along various facets, such as the DSL formulation since every game is two players, with the same attacker-followed-by-defender sequencing, with the exception of \textbf{IDSMark} which requires more operators to accommodate the repeated move structure. At the specification level, there is no implementable common language for these models to easily interchange the non-moving parts of the model such as the environment constants used to calculate payoffs or the action spaces. But after translation, the relationships between the components of the games can now be in a Haskell environment for which standard programming techniques can be applied. Recalling the explicit quantitative dependency mentioned in the previous paragraph (\ref{example:quantDepend}), the function implementing the payoff scheme should be the same for both models as open games.

\begin{table}[h!]
\centering
\setlength{\tabcolsep}{4pt} % Reduces space between columns (default is 6pt)
\renewcommand{\arraystretch}{1.3} % Adds vertical breathing room for wrapped lines

\begin{tabularx}{\textwidth}{|| >{\hsize=0.85\hsize}X 
                               >{\hsize=0.80\hsize}X 
                               >{\hsize=0.75\hsize}X 
                               >{\hsize=1.60\hsize}X ||} 
 \hline
 \textbf{Module} & \textbf{Model name / Citation} & \textbf{Game type} & \textbf{Description} \\ 
 \hline\hline
 Deception.hs & \textbf{Decep} \cite{cceker2016deception} & Bayesian, two-player & Deception game to mitigate DDoS attacks \\ 
 Honeypot.hs & \textbf{Honey} \cite{li2019game} & Bayesian, two-player & Distributed honeypot deployment mechanism game models \\
 IDS.hs & \textbf{IDS} \cite{Chen2009} & Bayesian, two-player & Intrusion detection systems for heterogeneous networks game models \\
 IDSMarkov.hs & \textbf{IDSMark} \cite{lye2005game} & Stochastic, two-player & Stochastic game over network state, simplified \\ 
 \hline
\end{tabularx}
\caption{Baseline model implementations}
\label{table:baseline}
\end{table}




Furthermore, out-of-the-box equilibrium checker can verify equilibrium results from the paper (i.e. parameter values for which equilibrium is achieved), there is no analogous equilibrium-solving process in open games. However, with the input data for running the equilibrium checker comprised (typically) of floating point numbers, it should be possible to check for equilibrium under certain conditions. Additionally, the diagnostics are well-suited for reading expected payoffs as a result of the game. 

Lastly, the analysis in some of these models use solution concepts that have not yet been developed in open games like Bayesian perfect equilibrium and sequential equilibrium \cite{FUDENBERG1991236}. Over the course of the study, some time was dedicated to fomralizing these concepts in open games \footnote{see \textbf{SeparatingEquilbrium.hs} to see the class beer-quiche game.}, which resulted in a tangent that was less pertinent to the overall target design process for modelling. Nonetheless, future work down this path would greatly enhance the translatability of pre-existing classical models to open games. Based on \cite{ghani2017compositionaltreatmentiteratedopen}, \textbf{IDSMark} was implementable as expected by treating it as an infinitely-repeated game with discounted payoffs. Each step was dictated by a transition graph that described the status of the network following each action. In open games, solving for stationary equilibrium strategies would involve iterating over possible strategies (actions for each state), for each possible initial condition for the system, which quickly leads to a computationally unyieldy simulation. 



\subsection{Design patterns}
\label{designPatterns:library}
After analyzing the direct translation process, we can separate the responsibilities of the components that instantiate a model. These are specifically implemented as modules (dubbed \textbf{Security} modules in-line with the repository). The key advantage is that these three modules are dependent on each other through custom types relevant to the model. Given that specification, they can be developed independent of each other, then brought all together into a top-level testing suite for model-wide evaluation. The following section will tie these modules together into a streamlined, Agile-inspired workflow. 

\subsubsection{Module 1: two-player open games}
The first abstraction that can be leveraged is generalizing the two-player interactions. 
Readers may refer to \textit{AttackerDefender.hs} module for the complete documentation of these games. An example of a two-player template game is below: 

\begin{minipage}\textwidth
\scriptsize
\begin{code}
twoPlayer distType a1 name1 a2 name2 = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:
   inputs: ;
   feedback: ;
   operation: nature $ distType;
   outputs: visitorType;
   returns: ;

   inputs: visitorType;
   feedback: ;
   operation: attackerLeader name1 a1;
   outputs: attackerDecision;
   returns: attackerPayoff;

   inputs: attackerDecision;
   feedback: ;
   operation: defenderFollower name2 a2;
   outputs: defenderDecision;
   returns: defenderPayoff;

   :----------------------------:

   outputs: visitorType, attackerDecision, defenderDecision;
   returns: attackerPayoff, defenderPayoff;

 |]
\end{code}
\end{minipage}

In the Bayesian setting, we want to allow players to be able to observe a private type. Then, any direct observed inputs of a player are determined by the order-of-play. The following template code is used to dictate a game where an attacker moves first, with a private type. In the \textbf{outputs} and \textbf{returns} fields, we can see the template game exposes all the data generated within the game and receives the corresponding payoffs externally. The |name1| and |name2| are set by the modeller to help read the diagnostic information. 

Treating this open game as a first-class citizen for implementing large, complex models comes with many advantages. These can be composed sequentially, leading to possible chains of independent 2-player security interactions. Composing in parallel allows a modeller to dictate simultaneous play \footnote{conceptually, not necessarily physically playing simultaneously} of these security interactions. Since the payoffs are determined external to this building block, calculations can be written in a separate module. 

To accommodate the infinitely repeated game setting, we constructed two other generic template games |repeatedStage| and |repeatedPayoffGame|. The former essentially serves as template for running a payoff computation that accummulates discounted rewards by preloading the behaviour according to the supplied strategy (i.e. repeated |play|). This will later be executed and packaged as a context to evaluate a game of a particular format (where the types of both covariant inputs match those of its own contravariant inputs. see \cite{ghani2017compositionaltreatmentiteratedopen}). This brings us to the latter game |repeatedPayoffGame| which splits continuation payoffs to pass to the appropriate player. 



\begin{figure}
	\centering
	\includegraphics[width=\linewidth]{IDNBlockDiagram.png}
	\caption{A block diagram for an IDN, for three subsystems from \cite{Jin2018} \label{figure:Fig. 3}}
	
\end{figure}


\begin{mdframed}
\begin{example}[Subsystem replication using template games]
Consider the architecture of a typical intrusion detection network (IDN), which is comprised of multiple intrusion detection systems (IDS) as seen in Figure \ref{figure:Fig. 3}. The model developed in \cite{Jin2018} is a two-layer stochastic, game between an attacker and an IDN, where the states of the game are defined by the status of each subsystem. Here, the assumption is that the capabilities of each of the IDSs and their respective attackers as homogenous, but working independently. In particular in the \textit{Simulation} section, the proposed model is evaluated with a specific set of parameters in a network of three IDSs and three independent attackers. If the assumption of homogeneity was to change, the parameters used to evaluate the model must also change. Maintaining consistency across the model requires flexbility, but current game formulation techniques aren't necessarily built with the notion of seamless integration.

From a security design point-of-view, this interaction between subsystems is vital, especially if a vulnerability in one system affects the defensive capabilities of another. After designing games for a subsystem, we can easily direct the flow of the result of the game to a level-higher for resource management. Designing this IDN using open games allows us to work on each subsystem separately from the aggregation mechanism. The disjoint nature of these parts allows for testing the efficacy of a different aggregation mechanisms or subsystems. Each subsystem interaction can then be instantiated as three functions using the template two-player game, but each parameterized accordingly \footnote{In order to run simulations using the constructed model formulation, the authors assigned values such as the detection libraries available to each IDS system $i$ and attacking libraries for each attacker $j$. \cite{He2015}.}. Then, the logic for the aggregation mechanism is defined as a separate open game which takes as input the outputs of the three previous functions. 

\end{example}
\end{mdframed}


\subsubsection{Module 2: model parameterization}

Outside the structure of the game, we organize the pipelined data necessary for decision making and payoff calculation into a single module. This module is the arena for modellers to construct abstract data types (ADT) corresponding to model-relevant parameters. Exogenous parameters, or parameters defined outside of an open game, can be hardcoded values. Exposing this module to all other modules allows each of them to access the relevant data as needed. With no logic related to the game structure or calculating payoffs, we treat this module closer to a configuration file to dictate the available types that can be used. This also places no restriction on how many models use these parameters, allowing for related variant models accomplishing different tasks. Expectedly, any changes made at this level would reflect on its dependencies as a compile-error, for example in the case of adding a new parameter called for by the specification team. 
\begin{minipage}\textwidth
	\begin{code}
	data IDSParams = IDSParams {
	probDetected :: Double,
	costOfAttack :: Double,
	costOfDefense :: Double,
	attackImpact :: Double,
	priorDistributionAttacker :: Double,
	computingResources :: Double,
	basePayoff :: Double,
	computationReductionUnderAttack :: Double
} deriving Show

\end{code}
\end{minipage}

The only other fixed data types we would like to set here are the actions available to the models. See \textbf{IDS.IDSModel.hs} for a fully worked-out example.

Lastly, any test-data can be hardcoded here. But auto-generating each field of the data type is also possible using the |Test.QuickCheck.Gen| module. We can provide an implementation that sets clear guidelines for how to randomly generate each of the values. 
Below, we can generate test-data varying along the prior probability of an IDS encountering an attacker. We can manually sample test data using |totalGen|, or testing frameworks that generate test cases will use this implementation when testing over |IDSParams|. In this case, |probDetected| would vary over the range (0,1). 
\begin{minipage}\textwidth
	\begin{code}
	totalGen :: Gen (IDSParams)
	totalGen = 
	    do 
	        probDetected <- choose (0,1)
	        return IDSParams {
	                probDetected = probDetected,
	                costOfAttack = 20,
	                costOfDefense = 10,
	                attackImpact = 10,
	                priorDistributionAttacker = 0.5,
	                computingResources = 100,
	                basePayoff = 100,
	                computationReductionUnderAttack = 70
	        }
	
	\end{code}
	
\end{minipage}

A vital part of ensuring correctness when designing games is also the relative values of these parameters. In \cite{la2016deceptive}, the authors assume that the reward for an attacker's successful exploit (encoded as |attSucc| ) is strictly greater than the reward for probing a non-honeypot target (|attProbeSucc|). Encoding these restrictions must then be used as a wrapper for our test generator |flip suchThat checkAttReward :: Gen a -> Gen a| where any assumption can be encoded as a function that accesses the appropriate variable from the model datatype |checkAttReward = (>) <$> attSucc <*> attProbeSucc|. As part of this model instantiation module, there can be more than one assumption which can then be composed such that all assumptions must be satisfied when generating the test data. 

\subsubsection{Module 3: designing payoffs}
We can also recognize the similarities between how these types are used for computing payoffs. The instantiation of games by action space informs the types exactly available for designing payoffs. Since a model doesn't 'require' any specific payoff behaviour beyond these types (and maybe fitting into a test infrastructure), we can independently develop payoff logic away from the structure of the game. We can loosely characterize payoff functions by their dependence on the following information: 
\begin{enumerate}
	\item The output of the open game 
	\item Model-level exogenous parameters from \textbf{Module 2}
\end{enumerate}

An example of 1. in a simple case is a tuple of actions chosen by each player in the game, or the assigned player type. 2. is concerned with system parameters that are relevant to payoff data. Here, we propose the reader monad as the necessary function-passing structure for generating payoff functions according to these model-level exogenous parameters. The reader monad is well-suited to passing a configuration in functional programs, and easily accessing fields of record type with the |asks| operator. Let's see how this is used in-production.

\begin{code}

type PayoffReader a = Reader a Double

runPayoff :: a -> PayoffReader a -> Double
runPayoff params reader = runReader reader params

\end{code}




Notice the parametric type \textit{a}, so we can define a |PayoffReader| for any ADT containing exogenous model parameters. This supports the system-level-first architecture that allows a modeller to introduce relevant variables that are not directly involved and subject to manipulation separate from the interworkings of the open game model. Thus, we can actively test how different payoff schemes affect our game model, either by (1) testing the same game with different system variables or (2) the same system variables with different player capabilities. We can characterize a payoff profile's dependence on two things: the outputs of the open game, and the variables accessible with the |PayoffReader|.

Already we can consider branching the payoff functions into helpers associated with each type of player, and pattern-match on these types. If we use the preset two-player template from the \textbf{Security} module, the set of two-player security games requires a |PayoffReader| for each attacker and defender. Then at the execution-level of the game, which runs against the model-level parameters, we use these parameters to instantiate the readers (in this case, |IDSParams|). Thanks to the type-checker, the output type of the model should provide the modeller with the requirements for this |PayoffReader| constructor. 
\begin{mdframed}
	\begin{example}[Using the Reader monad to access exogenous parameters]
		To design payoffs, we can start by fixing our model parameters to follow |IDSParams| datatype as defined in \textbf{Module 1}. For one such implementation of describing an attacker's payoff, we can read from our config to assign values according to the (covariant) output of an open game, in this case dependent on the attacker and defender move. Pattern matching over the results can be read as "if the attacker attempted access, and a defender did not allow it, then the attacker recieves |costOfAttack|" Note that |attAccessPayoff| collects the values it needs, then does a computation.
\begin{code}

attPayoff :: AttMove -> DefMove -> PayoffReader IDSParams
attPayoff Access Open = attAccessPayoff
attPayoff Access Close = asks costOfAttack
attPayoff DoesNotAccess Open = (* (-1)) <$> attAccessPayoff
attPayoff DoesNotAccess Close = return 0

attAccessPayoff :: PayoffReader IDSParams
attAccessPayoff =
    do
		coA <- asks costOfAttack
		basePayoff <- asks basePayoff
		probDetected <- asks probDetected
		return $ (basePayoff - coA) * (1 - probDetected) - coA * probDetected     
\end{code}
	\end{example}
\end{mdframed}


The implementation of \textbf{Module 2} in the \textbf{Security} library provides the necessary functions to extract the actual numeric payoff from the reader, then package the payoffs into a |StochasticContext| so it's ready-to-use for the diagnostic functions. We can also further develop functional tests written specifically to ensure the behaviour of this module follows the required specifications, or even just a sanity check. This extra capability gives an added layer of ensuring correctness, without having to consider the entirety of the model. 


\begin{mdframed} 
   \begin{example}[Model adaptation along the payoff module]
	\label{example:adapt}
      A key feature of using the reader monad is having fine-tuned control over these parameters without worrying about changing them. And if we do need to change them, it's explicit. Consider the payoff scheme used to slightly adapt the previous example by allowing the defender to not just open or close, but deploy two different kinds of honeypots or remain open under normal operation. Refer to \textbf{IDS/IDSAPayoff.hs} for the complete implementation, and \textbf{IDS/IDSAPayoffHP.hs} which explicitly adapts it. 

The type signature only differs in the third argument to the payoff functions. Intuitively, we will have to write the same pattern-matching structure but over the new datatype |HoneypotDeploymentMove|, but the computation of payoff shouldn't have to be rewritten explicitly. Since in our model, deploying a high-interaction honeypot increases the probability of detecting an adversary, this can be reflected by locally altering the |IDSParams| before using the same formula from \textbf{IDSAPayoff}. So given a |HoneypotDeploymentMove|, we want to update my |PayoffReader| with an augmentation function such as: 
\begin{code}

augment :: HoneypotAllocation -> 
	(PayoffReader IDSParams -> PayoffReader IDSParams)
augment HighHP = local (\params -> params {probDetected = 0.8})
augment LowHP = local (\params -> params {probDetected = 0.65})
augment Normal = local (\params -> params {probDetected = 0.5})

\end{code}
To demonstrate the breadth of this granularity, we observe the following example for designing payoffs derived from an initial problem statement.

\begin{enumerate}
	\item Assumption: there is only one attacker and one defender
	\item Assumption: the defender can either allow traffic or close the server 
\end{enumerate}

The factors that we consider that dictates the payoff would be included in the config given by \textbf{Module 2}. Here, without having to change this global config, we use |local| to adjust the detection probability. 
   \end{example}
\end{mdframed}

\subsubsection{Module 4: property tests for model verification}
At this point, a modeller may be asking questions such as "is equilibrium reached under this system configuration and payoff calculations." After using the previous modules to construct a series of "executable" models, we need a concise way to organize our experiments. We use executable models to describe closed games (by type, ready to run diagnostics) but specifically instantiated with a payoff module and a parameter module call. This module leverages the Hspec testing library which has a nice tradeoff of writing human-readable specifications, and uses \textit{Gen} for these parameters to generate random test-data. 

A single experimentation test should be generalized under a broad goal using |describe|. The subsequent property tests are then defined using the |it| operators to designate the evaluation of a completed model. The |property| operator requires a boolean-valued function, so expectedly a modeller is in the position to extract properties based on this evaluation. \footnote{This resembles a model-checking approach in the multiagent-systems verification field, where a propositions are developed by a modeller which must be checked for each state of a state-transition structure}. 

\begin{minipage}\textwidth
\begin{code}
describe "Experiment 1: comparing defensive system A with system B"|
	it "should be in equilibrium under these conditions" $ 
            property $ \params -> myProposition
\end{code} 
\end{minipage}

Here, |myProposition| would be determined by the modeller as a result of evaluating a target model. Extra code to extract payoffs for specific players are necessary, but this logic would be designed to extract propositions such as "for all the test data, my model is in equilibrium". In terms of complexity, this evaluation is run for each test case of |params|. But how are these test cases generated? Precisely by the test data and model-wide data instantiation in \textbf{Module 1}. Without an explicit implementation of |Test.QuickCheck.Gen| for the supplied data type, we can end up with a number of test cases on the order of all the possible combinations over all the possible values within the natural range of each of the fields. This isn't computationally feasible, but conceptually not useful to modellers anyways. Any experiment to extract results means investigating how one or two exogenous parameters affects equilibrium or payoffs. 

This module is intended to be a mixture of both a simulation script and a self-documenting specifications document. This is a vast improvement on a series of Haskell functions calling diagnostic functions on closed games. It's dynamic in the sense that tests can be added, removed, or refactored. The built-in test case generation can also provide modellers insight to how sensitive the model is to certain parameters. \footnote{For occasional graphical analysis, we used |Graphics.Rendering.Chart.Backend.Diagrams| to plot payoffs for each player using the generated data.}  

A typical software project management or CI pipeline could be applied, however here we can accumulate a series of \textit{.spec} files containing these property tests. Since the \textit{open-games-engine} is managed using \textbf{stack}, practitioners can simply run \textit{stack test} to automatically run and direct test results from all spec files in the project to the console. 

\subsection{Discussion of design patterns}
\label{designPatterns:discussion}
Equipped with these modules to organize the development and analysis of a model, this should drastically improve the direct translation process from Section \ref{designPatterns:directTranslation}. But more than that, this provides some structure for the game formulation process which ultimately provides modellers with many advantages. 

Rapid generation of models is now possible, since many models can be off-shoots or variants for any given parameterization. The result could be multiple complete games that follow a singular high-level game formulation. The relationships between these variants can be explicitly controlled where it is commonly-used in literature, namely in payoff adaptation or stage game repetition. By fixing this process, practitioners have a common-platform to interpret these models. For example, practitioner Alice may be managing their own unique security situation, for which she can use \textbf{Module 2 and 3} to codify the model parameters. Alice's colleague Bob ran similar experiments but with an older configuration so the parameterization doesn't match, but the open games developed using \textbf{Module 1} by Bob are perfectly applicable. Then Alice's job could be as simple as importing Bob's library. Any future updates can then be maintained through standard Git source control and merging working branches. A future behavioural study involving practitioners of the relevant disciplines to be introduced to this workflow, then be tasked with a model to implement, in order to evaluate the efficacy of treating would help validate (or invalidate) the goals behind these design patterns.

These patterns overcome the rigidity of models by making them easily adaptable. Any changes are reflected across dependencies thanks to the Haskell typechecker, which helps maintain consistency across models and directs users to where changes need to be made. Then, any model adaptation or dependence on the security problem formulation is stratified more explicitly to modular adaptation in the Haskell environment. We can see this in Figure \ref{fig:HPadaptation} which stratifies model relationships along these patterns. In contrast with the direct translation process, the blue dotted line is is a concrete process, where "augment" makes minor adjustments corresponding to scaled payoffs according to new honeypot configs. The immediate question of how to consider this new factor in our game model can be written as an additional series of property tests within the same file, where a modeller can compare model performance. 

\begin{figure}
	\centering
	\label{fig:HPadaptation}
	\includegraphics[width=\linewidth]{HoneypotAdapt.png}
	\caption{Security game translation using design patterns}
\end{figure}

In Figure \ref{fig:Workflow1}, we distinguish domain experts of the security specifications in the left-blue region, and open games security games developers in the right-red region. The numbered boxes provide the order of which each step should be taken. Note that the DSL and parameters modules are always instantiated before payoffs, since payoffs are intended to provide the data needed to execute these models. In the last step, security experts can extrapolate results based on the status of the testing suite. Any subsequent changes to "Model specifications" should then result in failing tests in the test specifications, which signals open games developers to make adjustments accordingly.   

\begin{figure}
	\centering
	\label{fig:Workflow1}
	\includegraphics[width=\textwidth]{Workflow1.png}
	\caption{Step-by-step domain expert collaboration for model development}
\end{figure}

\begin{mdframed}
	\begin{example}[Hierarchal game by composing models] \label{example:Hierarchal}We refer readers to \textbf{HierarchalIDS.hs}, which imports models from \textbf{IDS.IDSModel} and \textbf{IDS.Deception}. For this example, we can remark on the dependencies of this composite model. Below is the template code for scaffolding an IDN network comprised of two IDS systems. These two IDS systems are , resultiong in a four Bayesian agent model with two attackers |"A1"| and |"A2"| and two defenders |"D1"| and |"D2"|. 

	\begin{code}
twoIDS idsParams deceptionParams = [opengame|
   inputs: a1, d1, a2, d2;
   feedback: ;
   :----------------------------:

  
   inputs : a1, d1;
   feedback: ;
   operation: ids idsParams "A1" "D1";
   outputs: a1Type, a1New, d1New;
   returns: [payoffIndexer initPayoffs 0, payoffIndexer initPayoffs 1];

   inputs : a2, d2;
   feedback: ;
   operation: deceptionGame deceptionParams "A2" "D2";
   outputs: a2Type, a2New, d2New;
   returns: [payoffIndexer initPayoffs 2, payoffIndexer initPayoffs 3];

   :----------------------------:
   outputs: a1Type, a1New, d1New, a2Type, a2New, d2New;
   returns: initPayoffs;
 |]

	\end{code}
	Here, we see that we can use both |IDSParams| and |DeceptionParams| in this composite model, which characterize each of the IDS-Attacker games individually. This allows for a complex strategic security interaction, where the direct relation between players is defined outside of |twoIDS|. This follows the separation-of-concerns principle, by defining the logic (such as auctioning schemes, payoff distribution mechanisms for a network manager) outside this template game. 
	\end{example}
\end{mdframed}
\subsubsection{Libraries and model-sharing}

Recalling the example on model adaptation (Example \ref{example:adapt}), we could envision many such augmented payoff schemes. Adjustments along this module, while fixing all other parts of our model, naturally formulates the process for answering questions of how any other game model improves on the other. 

Following the one-shot signalling game models from \cite{la2016deceptive}, \cite{boumkheldHoneypotTypeSelection2019}, \cite{Carroll2009} and how the authors approach in the analysis of the model, we can comment on the advantages of using open games for the conception of the security model in natural language rather than repetitive a payoff table or extensive-form game tree. One primary advantage is that we have an active simulation environment for which practitioners can examine how the proposed variables change the overall model. Furthermore, along \textbf{Module 1}, we can programmatically manipulate these variables for a wide-ranging series of tests. We address the issue of allowing flexible assumptions (from the earlier part of this chapter at \ref{topic:collinsrec}) by providing a framework to test these assumptions.

Taking the step to writing payoffs in Haskell comes with several tradeoffs. The most notable downside is Haskell is less-suited for numerical computing, especially for more complex payoff schemes, in comparison with other languages. While we hoped to mitigate this using the payoff scheme of \textbf{Module 3}, there could be easier ways to inject these calculations into a model. On the upside, writing payoff schemes into an executable format allows for reuse and maintainability as exports of a software package, rather than a collection of findings that must be re0derived or reanalyzed by hand.  

% We can also remark on the similarity of models across literature following the signalling game structure. By the separation-of-concerns principle enabled by \textbf{Module 2} and \textbf{Module 3}, 

% \begin{mdframed}
% 	\begin{example}[Functional tests for adapting \cite{la2016deceptive}]
		
% 	\end{example}
% \end{mdframed}
Similarly, there is a deep disconnect between static models that are evaluated numerically, and derived optimal defensive (or attacker) strategies that can inform systems in real time. When implementing findings from these models and performance in the real-world, \cite{kiennertSurveyGameTheoreticApproaches2018} shows a majority of the work in literature does not provide this kind of validation. We hope that this programmatic approach could be pipelined and more easily accessible for the introduction of new model parameters, and subsequently, the derived strategies integrated into a particular system (such as integration with signature-based IDS SNORT as in \cite{zonouzRREGametheoreticIntrusion2009}). Whether the methodology presented here would be an adequate platform for linking with a network-simulation or test-bed platform remains to be seen, however the models-as-code paradigm should allow for easy coupling with other software. 


\subsection{Iterative modelling using open games}
\label{designPatterns:Iterative}
% The spirit of this thesis has certainly been explored in other work, for example in the simulation procedure provided by \cite{Nochenson2012}. This thesis attempts to mechanize the claims for "easily extendable" or "replace lines 9-13 in Algorithm 1."
With the feedback loop established in \ref{fig:Workflow1}, we can begin to see a responsive, cyclical workflow. With standard software patterns in place, changing the implementation for these models to match changing specifications is a typical refactoring process. 

An iterative, formalized process for refining games is not new, as seen in \cite{wellman2006methods}, as a simulation-based approach to inform the general game-theoretic design process. The process proposed by Cassell and Wellman continues in \cite{EGTAOnline}, which automatically implements data reuse to show how simulation runs differing in one element (a strategy set) can be easily compared using their data retention mechanism. In particular, \textit{empirical game-theoretic analysis} is a methodology that learns payoff profiles and strategy spaces through simulated data to inform the game formulation. Specifically, the goal is to instantiate an empirical game which is parameterized by simulating expected payoffs according to a strategy profile. Two feedback mechanisms are leveraged: (1) payoff estimation and (2) strategy space exploration.  This methodology has seen its applicability in moving target defense \cite{Wellman2015} and adaptive cyber defense \cite{Wellman2019}. Further extensions for a software-induced workflow, including database support and use of Gambit, can be found in \cite{EGTAOnline}. The culmination of a tooling for empirical game-theoretic analysis is \textbf{EGTAOnline}, dubbed as an experiment manager, which can sample data in real-time. We can touch upon some of the differences of this approach with ours, primarily the automatic refinement process and the learning mechanisms to restrict the strategy space for each loop. Future work on developing \textit{open-games-hs} as part of an automatic pipeline would greatly expand the capabilities of our approach.

Many game-theoretic models in security rely on ad-hoc schemes \cite{Liang2013}. The authors also cite a need for standards for designing payoffs and more scalable methods to match the complexity of the security problem, such as building a model that considers more than three players. The cybersecurity problem specifications dictate the parameters and format of the model, creating a hyper-focused game. So translating the real-world security situation to a model using the same toolbox of game-theoretic mechanisms implies the need for the right sandbox to test different real-world translations and how they respond in the game-theoretic model. According to section 6.1 on IDS optimization in \cite{Collins2025}, there is a recommendation for characterizing and distinguishing different kinds of attackers and varying objectives.  

In the realm of compositional security modelling and a formal syntax, but not game-theoretic models, we can also see models-at-the-interface at work.For example, \cite{Caulfield2015}, \cite{Caulfield2014} closely resembles compositional and software-supported approach in security modelling by \textit{a priori} designing models that can be composed together later. Here the authors present a systems modelling theory for security policy design. Using a semantic-approach based on process theories to model elements of a security situation as resources of these theories, these concepts can be encoded in Julia to run simulations. They show composition of models is well-defined and demonstrate how to run these models based on individual expected utility. The result is a model to help inform security policy managers make better decisions about security systems and have a framework to convey this information to other stakeholders.  

This modelling approach is focused on the security of an organization comprised of three sequentially-composable models: (1) a device-loss model, (2) a tailgating model, and (3) a document-sharing model. The pitch most strongly reminiscent to this thesis is that a modeller can adaptively see how including or excluding elements of a model to the workflow affects the system in a reactive way. For example, the modeller can examine the simulated data of just the tailgate model with and without the presence of a security guard on the frequency of computer accesses, and then observe the impact of the same presence of a security guard in the large composed model. This layered approach of designing locations and resources on a layer under the decision-making layer of agents hints at a design approach that separates the concerns of the model from its instantiation. This thesis tackles a different class of security problems but mirrors the task of formalizing security problems in a compositional and iterative way.



% \begin{figure}
% 	\begin{center}
% 		\includegraphics[width=0.75\linewidth]{EmpiricalAnalysisPipeline.png}
% 		\caption{Workflow diagram for empirical analysis from \cite{Wellman2015} \label{figure:Fig. 2}}
		
% 	\end{center}
% \end{figure}

\begin{figure}
	\centering
	\includegraphics[width=0.75\linewidth]{EGTAFeedback.png}
	\caption{Empirical game-theoretic analysis pipeline from \cite{Wellman2019} \label{figure:Fig. 3}}
\end{figure}


\subsubsection{Towards test-driven open games}
Test-driven development (TDD) is a coding paradigm where a programmer begins with unit tests and iteratively refactors code to fulfill these tests and write new ones. A programmer doesn't move on to the next iteration until the entire test suite passes, ensuring that refactors don't cause breaking changes across a code-base. The very first test case in any situation is to verify the most basic assumptions for the behaviour of a program. And as the complexity and dependency of this program grows, these assumptions are always kept in check. TDD enables the coder to think about specifications first, and while those specifications are open to change over time, writing these tests document the expected behaviour of the program. 

By using TDD as a way to guide open games evaluations in a we can ensure guarantees and verify assumptions surrounding a game formulation before its eventual composition with others. Furthermore, the use of the previous design patterns means we don't have to treat an entire security model as a monolithic entity every time we fail a test. 

First, we make the following correspondence between types of tests in order to demonstrate different kinds of tests that can be written in our framework, summarized in Table \ref{table:TDD}. 


\begin{table}[h!]
\centering
\begin{tabularx}{\textwidth}{||l X||} 
 \hline
 Type of test & Description \\ [0.5ex] 
 \hline\hline
 Unit & Payoff module tests, parameter and data generation tests \\ 
 \hline
 Functional& Model-wide tests, equilibrium-checking, sensitivity tests \\ [1ex] 
 \hline
\end{tabularx}
\caption{Summary of kinds of tests for TDD in open games}
\label{table:TDD}
\end{table}

Unit tests would ensure the correctness of the payoffs, test data, or helper functions that act as infrastructure to run the high-level specs that reflect the target security specification. We reserve Functional tests as the mechanism for verifying security needs through equilibrium checking. It follows that unit tests serve as a the test suite for the implementation of the model, so all unit tests should go green before running the functional tests. After both types of tests are passing, the results can be fed back to the top-level in order to inform the next iteration of models. Due to the compositional and interdependent nature of this methodology, the next iteration of models will have the previous iteration of models (and its components) at its disposal, like a typical software project. By following the TDD process as seen in Figure \ref{fig:TDD}, security models in open games can be iteratively improved upon, while maintaining consistency with the demands of stakeholders setting high-level specifications. 

 We have used these design patterns to separate-concerns for constructing games, which also lends itself to creating specs of unit tests corresponding to each of the elements of the model. For example, a passing spec file of unit tests for \textbf{IDSPayoff.hs} ensures validity for other downstream payoff modules such as \textbf{IDSPayoffHP.hs} which uses that logic. 


 \begin{figure}
	\label{fig:TDD}
	\centering
	\includegraphics[width=0.5\textwidth]{OpenGamesTDD.png}
	\caption{Test-driven development (TDD) for writing open games}
\end{figure}



 \begin{mdframed}
	\begin{example}[Unit test for the deceptive model]
	This example describes a unit test (as per \textbf{Module 4}) for guaranteeing assumptions as in \cite{la2016deceptive} and implemented in \textbf{IDS.DeceptiveModel}. We can guarantee that our assumptions are made in the test data provided for the rest of the model and its construction in the repository. Any supplied parameters must conform to these unit tests, otherwise the methodology would immediately display failing tests. 

	Our goal is to write unit tests associated with the generated test data for |Gen DeceptionParams|, where |DeceptionParams| are the exogenous parameters for the \textbf{IDS.DeceptiveModel}. Such restrictions are direct consequences of the interpretation of the security game, namely (1) the reward for the attacker is strictly greater for a successful attack over a probe move and (2) the cost for the defender is strictly greater for getting compromised over an unnecessary deployment of a honeypot. Furthermore, we want a human-readable format to document these models as a result of the model-wide parameters set in \textbf{IDS.DeceptiveModel}
	
	Since we are doing TDD, we write our unit tests first to describe these restrictions and bake these assumptions into our model. A spec file like \textbf{DeceptiveModel.spec} could contain a test like the following.

	\begin{code}
	describe "Parameter tests for deception model" |
		it "reward for attack greater than probe " $ 
			property $ \params -> attackerSuccess params > attackerProbSuccess
	\end{code}

	\end{example}

	Provided these unit tests pass, other payoff modules that import and adapt \textbf{IDS.DeceptiveModel} will also conform to the same restrictions in a project-wide testing infrastructure. This is specifically relevant for the parameterization used for running interdependent models like \textbf{IDS.HierarchalIDS} (see Example \ref{example:Hierarchal})
\end{mdframed}





\subsubsection{Testing, quantitative analysis and payoff graph generation}
Lastly, for quantitative and numerical analysis of game-theoretic models for cybersecurity, the proposed methodology can accommodate graphical outputs in addition to property tests. Future attachments to an external optimizer for computing optimal strategies for repeated game models is left for future work. One kind of round-based analysis that can be done is by computing the aggregate payoffs finitely-repeated games at each round by mapping |generatePayoff| over the number of rounds and an open stage game. But runtime and complexity analysis is required to compare with other software tools. Performance and comparative analysis with other tools such as Gambit can be conducted for a future study. But initially, we cite the major advantages of expressibility and modularity of using open games can act as a cursory tool before translating them into equilibrium-solving engines.

\begin{figure}\label{fig:payoff}
	\centering
	\includegraphics[width=0.75\linewidth]{Payoff.png}
 	\caption{A preliminary payoff graph from a 3-IDS system game, with a manager player allocating defensive resources to each IDS. }  
\end{figure}


Consider Figure \ref{fig:payoff}, where a modeller can evaluate the impact of the common prior probability of encountering an attacker rather than a normal user. The defensive system with a certain reputation, corresponding to a type |Active, Passive| (along the x-axis) for an open-game model, is also drawn probabilistically in the usual sense. This figure was generated using \textbf{Graphics.Rendering.Chart}. Each line depicts the corresponding payoff for the resource allocator deploying a strategy (encoded by colour), who's strategies represent the deployment different countermeasures to three subsystems. For example, "high active" in blue corresponds to the strategy of the allocator with type |Active| to deploy the maximum defensive resources. For this experiment, each of the three subsystems can be tweaked independently (for example, by a degree of importance in the network or energy consumption). For this figure, we can say that deploying the normal strategy outperforms others. Similarly, as the chance of an attacker increases, the more involved defensive strategies perform greater better. Some avenues that can be taken given our methodology could be the following experiments, by analyzing the model that produced this figure: 
\begin{enumerate}
	\item Write unit tests pertaining to the payoff module associated with the |high active| strategy to improve performance 
	\item Write functional tests for determining the threshold for which an importance value for one of three one of three IDS systems can be increased while maintaining similar performance
\end{enumerate}

For (1), modellers can work in \textbf{Module 2} and \textbf{Module 3} without touching the original game structure. For (2), the singular IDS game has already been written as an open game, and can be tested independently and then reintegrated to the larger model by \textbf{Module 1}.

Expectedly, a graphing module was required to parse through the diagnostic output of the evaluative module of the open-game-engine. This involves filtering out non-equilibrium strategies, identifying players, and parsing through an inconvenient tuple detailing unobservable state. We also found the parallel-processing (evaluating multiple open-games models simultaneously to populate graphs) lead to significant runtime issues. Future changes to \textit{open-game-hs} to optimize evaluation or reimplementation of the engine in another language may help with more efficient workflows. 











