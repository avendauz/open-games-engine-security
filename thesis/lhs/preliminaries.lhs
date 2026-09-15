\section{Preliminaries}
\subsection{Introduction}
The primary focus of this thesis is on developing a methodology for the game formulation of cybersecurity models using a Haskell domain-specific-language (DSL) for \textit{open games}. 
The organization of this chapter is based on the construction of the model of computation
for open games. These constructions will then be accompanied by their corresponding implementation,
available as typeclasses or type constructors as part of |OpenGame.Engine.Engine|. The remaining chapters of the thesis 
will propose design patterns and techniques for rapidly developing security models using the tool presented here.

Compositionality in game theory enables a wider range possibilities for modelling, in particular how to develop a particular way to refine this model modularly. Even based on the intuition of deciding the rationality of agents, we can confer their behaviour based on their percieved context, whether that's actions of other agents they directly observe, or the result of some sort of computation. 
Furthermore, abstracting away the specific behaviour of agents by describing a well-defined type system, allowing a software engineering approach, can enable a contextual understanding of an agent as part of a larger system. 
That dependence and ability to decouple the problem is enabled by considering utility-maximizing agents as a kind of open system, reacting to its environment. 
In the case of compositional game theory, we can start by using the concept of an open game. The properties of an open game allow a particular modelling workflow to assist a 
user in testing modelling assumptions or design choices programmatically. If the end goal is for users to treat open games as first-class citizens of this workflow, we want to delve into the underlying theory before 
describing these design patterns. 

To get started with the tool, users will need \href{https://www.haskell.org/ghcup/install/}{\textbf{ghc}}, 
and a package manager such as \href{https://docs.haskellstack.org/en/stable/}{Stack}. 
From here on we will refer to the \textit{open-game-hs} as the library that can be included 
as a dependency in a Haskell project. The main module is |OpenGames.Engine.Engine|, where all 
the library's functionalities are available. On the other hand, we'll refer to the code block 
syntax (the DSL) that is compiled to a program that could be expressed with just the library functions. The purpose of the DSL is to give a language to construct open games with explicit input and output ports, and implicitly facilitate parallel and sequential composition by "plugging" these ports together. 

But black boxing into this DSL the development of these models may not be enough to create intuitive models. If we wanted to ship a certain model expressly as a series of open games written in the DSL, the only constraints to guide its usage comes down to specific functions exported by |OpenGames.Engine.Engine| to construct well-typed games and run diagnostic functions. The process of generating strategies to run the game, reading through the console output of simulating the game, or refactoring a single input variable within the game, requires deeper knowledge of |OpenGames.Engine.Engine|. 

We can start by examining the following code example which acts as a typical template game for defining larger security games. 

\begin{minipage}\textwidth
\begin{code}
import OpenGames.Preprocessor
import OpenGames.Engine.Engine 

defenderFollower :: String -> (a -> [b]) -> OpenGame
     StochasticOptic
     StochasticContext
     `[Kleisli Stochastic a b]
     `[[DiagnosticInfoBayesian a b]]
     a
     ()
     b
     Double

defenderFollower defenderName getActionSpace = [opengame|

   inputs    :  attackerDecision;
   feedback  :  ;

   :----------------------------:
   inputs    : attackerDecision;
   feedback  :      ;
   operation : dependentDecision defenderName getActionSpace;
   outputs   : defenderDecision;
   returns   : defenderPayoff ;
   :----------------------------:
 
   outputs   : defenderDecision;
   returns   : defenderPayoff;
|]

\end{code} 
\end{minipage}

We aim to give readers a basic understanding for reading this code block along two facets: (1) understanding each of the components of the type signature of |defenderFollower| and (2) how to read everything within @[opengame| ...|]@. The following sections will cover the necessary categorical constructions (mostly from \cite{BayesianOpenGames}). Where we depart from the literature covering open games is providing an interpretation and explicit accounting of the implementation of each of these constructions as they're used in \textit{open-games-hs}. 
 
The models developed during the course of this project is a fork from \url{https://github.com/philipp-zahn/open-games-engine}. Various tutorials and  
READMEs exist, however a comprehensive progression and explicit accounting of the key 
functionalities to support end-user capabilities of the \textit{open-game-engine} has not been completed. 
The hope is for readers to use the language given here to help transition from: 

(1) thinking in a classical game-theoretic sense to \\
(2) thinking in a compositional game-theoretic sense to \\
(3) thinking in a software-oriented sense for building these models.\\
(4) writing the code \\

where the main contributions of the following chapters focus on a particular security-oriented focus in (3) and (4) using new design patterns.

\subsection{Classical game theory}


Game theory is a mathematical formulation for modelling strategic interactions between self-interested actors. To encapsulate this self-interest in quantifiable game theoretic models, we can define a certain reward (or payoffs) according to a set of actions for each player. Typically, this is written as a real-valued payoff function that measures the "happiness" of an agent for each possible action. Thus, we can evaluate the reward for each agent when they act or react according to a \textit{strategy profile}. We refer to classical game theory in the sense of the original instantiation of game theory as it was used in mostly economics. Readers can use \cite{leyton2008essentials} as reference for the few classical game theory terms used in this thesis.
Since we primarily rely on constructing games using compositional game theory, we found that classical game theoretic terms come more in handy as a post-hoc interpretation and evaulation of these models. Another way to put this is compositional game theory boils down to classical results, but it is more useful not to restrict ourselves by thinking classically from the get-go. This is especially relevant when constructing games in the domain of application, in this case cybersecurity games. 

% For example, for normal-form games, we can consider the following diagram for two players taking simultaneous actions and receiving a real-valued payoff accordingly. 

% After designing such a model, what can we learn about the agents? Typically, we are concerned with a solution concept such as Nash equilibrium, which intuitively means that every agent has no incentive to deviate from their given strategy given that they know everyone's strategy.

% With the development and deployment of complex "socio-technical" systems, the demand for understanding the behaviour of the system interacting with rational actors has increased. While game theory has seen its applications in an economic sense, analyzing security applications begins with assigning adversarial notions to players. 

\subsection{(Applied) category theory}
Treating category theory as a mechanism to interpret systems and mechanisms in other disciplines such as engineering, machine learning, programming language theory, quantum theory, and probability theory falls in the more recently-growing area of applied category theory. Whether practitioners of a certain discipline find a useful formalism with a categorical interpretation, or category theorists find constructions useful in a certain discipline, the result is a nice interdisciplinary area of research. But overall, it can be difficult to characterize what applied category theory truly is in a handful of words. We suggest \cite{fong2018sevensketchescompositionalityinvitation} as an introduction to more of these topics. For example, a graphical notation used across some of these applications are string diagrams, which also serve as a nice intuitive language for open games. The "compositional" part of compositional game theory is enabled specifically by defining open games as morphisms of a category. We will briefly use categorical language in the following chapter that is not very self-contained but can be used as a reference for the theory that the |open-games-engine| is built upon. \footnote{Since the target audience (hopefully) reaches farther and farther away from just category theory experts, and hopefully growing the broader ACT commmunity as an interdisciplinary effort.} The references that we found most prudent for all the required definitions for open games are \cite{HedgesThesis,BayesianOpenGames} We provide the corresponding references for those specific definitions, and otherwise assume no knowledge of basic category theory. For further reading on that front, we refer to \cite{mac1971categories}. For reading on other categories that are relevant in this thesis such as categories of optics \cite{riley2018categories}.

\subsection{Haskell and coding fundamentals}

Haskell is a statically-typed, functional programming language. Since a large chunk of this work involves software design patterns, a base assumption for readers is some knowledge of Haskell. We would like to refer readers to the Haskell documentation \cite{haskelldocs}, for which everything up to abstract data types, monads, hspec would all be useful to understand the code examples. We are also heavily inspired by design patterns old-and-new, like the GangOfFour \cite{gamma1994design}, to Agile methodologies \cite{beck2001agile}. The parlance such as "separation-of-concerns" or DRY (don't repeat yourself) caters to a programming-oriented audience, with the intention for game theory modellers to see how these programming strategies might prove useful for organizing and structuring a large library of games.  
\subsection{Formatting and structure of thesis}

This thesis was written in Literate Haskell and compiled using \cite{loeh2012lhs2tex} which provided the pretty typesetting for the Haskell code snippets and even allowed in-lining code. We follow a paragraph-style of writing, but intersperse some of the ideas with written code examples, which are boxed for readability. Some frequently-used Haskell datatypes that exist outside these boxes will be in-line and coloured, like |myDataType|.  




% We also have the ability to define custom data types using the keyword |data| to represent actions or outcomes. 
% \begin{mdframed}
% \begin{example}[User-defined types]\label{example:userTypes}
% Say we characterize a honeypot's resource capabilities as three different states: high-interaction, low-interaction, and normal. We can define a type as follows: 
% \begin{code}
% data Honeypot = Hinteract | Linteract | Normal deriving (Eq, Show)
% \end{code}

% where |Honeypot| has three constructors corresponding to the three states. Here there are no type variables. The |deriving| keyword specifies which type classes this data type is an instance of, in this case two type classes |(Eq, Show)| imported from |Prelude|. This gives our data type operations for equality to compare instances of |Honeypot| and the ability to read data in the console as |String|. 
% \end{example}
   
% \end{mdframed}


