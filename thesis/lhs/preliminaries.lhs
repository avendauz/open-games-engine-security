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
user in testing assumptions or design choices programmatically. If the end goal is for users to treat open games as first-class citizens of this workflow, we want to delve into the underlying theory before 
describing these design patterns. 

To get started with the tool, users will need \href{https://www.haskell.org/ghcup/install/}{\textbf{ghc}}, 
and a package manager such as \href{https://docs.haskellstack.org/en/stable/}{Stack}. 
From here on we will refer to the \textit{open-game-hs} as the library that can be included 
as a dependency in a Haskell project. The main module is |OpenGames.Engine.Engine|, where all 
the library's functionalities are available. On the other hand, we'll refer to the code block 
syntax (the DSL) that is compiled to a program that could be expressed with just the library functions. The purpose of the DSL is to give a language to construct open games with explicit input and output ports, and implicitly facilitate parallel and sequential composition by "plugging" these ports together. 

But black boxing into this DSL the development of these models may not be enough to create intuitive models. If we wanted to ship a certain model expressly as a series of open games written in the DSL, the only constraints to guide its usage have come down to four types inherent to each game. Otherwise, the process of generating strategies to run the game, reading through the console output of simulating the game, or refactoring a single input variable within the game, requires deeper knowledge of |OpenGames.Engine.Engine|. 

Thus we can take a look at the following code example from to introduce the separation 
of these two concepts: 

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

Some questions to be answered can be separated into two categories: (1) understanding each of the components of the type signature of |defenderFollower| and (2) how to read everything within @[opengame| ...|]@. The following sections will cover the necessary categorical constructions (mostly from \cite{BayesianOpenGames}). Where we depart from the literature covering open games is providing an interpretation and explicit accounting of the implementation of each of these constructions as they're used in \textit{open-games-hs}. 
 
The models developed during the course of this project is a fork from \url{https://github.com/philipp-zahn/open-games-engine}. Various tutorials and  
READMEs exist, however a comprehensive progression and explicit accounting of the key 
functionalities to support end-user capabilities of the \textit{open-game-engine} has not been completed. 
The goal is for readers to use the language given here to help transition from: 

(1) thinking in a classical game-theoretic sense to \\
(2) thinking in a compositional game-theoretic sense to \\
(3) thinking in a software-oriented sense for building these models.\\
(4) writing the code \\

where the main contributions of the following chapters focus on a particular security-oriented focus in (3) and (4) using new design patterns.

\subsection{Classical game theory}


Game theory is a mathematical formulation for modelling strategic interactions between self-interested actors. To encapsulate this self-interest, we can define a certain reward (or payoffs) according to a set of actions for each player. Typically, this is written as a real-valued payoff function that measures the "happiness" of an agent for each possible action. Thus, we can evaluate the reward for each agent when they act or react according to a \textit{strategy profile}, 
We invite readers to read through for a concise overview of these classical game theory formalisms.

For example, for normal-form games, we can consider the following diagram for two players taking simultaneous actions and receiving a real-valued payoff accordingly. 

After designing such a model, what can we learn about the agents? Typically, we are concerned with a solution concept such as Nash equilibrium, which intuitively means that every agent has no incentive to deviate from their given strategy given that they know everyone's strategy.


Here we begin to demonstrate more clear-cut separation-of-concerns that goes into creating this game. 

With the development and deployment of complex "socio-technical" systems, the demand for understanding the behaviour of the system interacting with rational actors has increased. While game theory has seen its applications in an economic sense, analyzing security applications begins with assigning adversarial notions to players. 

\subsection{Category theory}
The foundation of compositional game theory begins with category theory, 
in particular the "compositional" part of compositional game theory being enabled 
specifically by defining open games as morphisms of a category. In the spirit of staying in 
an applied setting, this chapter will briefly 
cover the related categorical constructions, assuming knowledge of what categories are, properties such as tensor product for symmetric monoidal categories? 

\subsection{Haskell fundamentals}

Haskell is a statically-typed, functional programming language. We also have the ability to define custom data types using the keyword |data| to represent actions or outcomes. 
\begin{mdframed}
\begin{example}[User-defined types]\label{example:userTypes}
Say we characterize a honeypot's resource capabilities as three different states: high-interaction, low-interaction, and normal. We can define a type as follows: 
\begin{code}
data Honeypot = Hinteract | Linteract | Normal deriving (Eq, Show)
\end{code}

where |Honeypot| has three constructors corresponding to the three states. Here there are no type variables. The |deriving| keyword specifies which type classes this data type is an instance of, in this case two type classes |(Eq, Show)| imported from |Prelude|. This gives our data type operations for equality to compare instances of |Honeypot| and the ability to read data in the console as |String|. 
\end{example}
   
\end{mdframed}


\subsection{Constructing open games in Haskell}
We'll begin by recounting the construction of open games up to its current implementation. The goal of this section is to present the definitions that are used, and then to explain 
how to read the corresponding implementation, especially the various types and frequently-used functions. The hope is 
that this builds an intuition for modellers to be able to understand the bare minimimum for constructing 
models and effectively using the type system. 

\subsubsection{Concrete lenses and open games}
Open games that are used in this thesis first relies on machinery that enables the flow of "forwards" and "backwards" 
information flow. This is encoded using the language of 
\textit{lenses}. Historically, open games were constructed without any connection to 
lenses, but was most recently used for defining Bayesian games in \cite{BayesianOpenGames} using a more general 
definition which broadly encompasses
the more familiar term, \textit{lenses}. 

Lenses have been used in database theory, defining certain 
\textit{lens laws} associated with data accessors. These properties dictate the behaviour 
of a \textit{get} and \textit{put} operations (or colloquially, \textit{view} and \textit{update} operations).
High-level, \textit{get} allows you to view the contents of a substructure, and 
\textit{put} allows you to make updates to a substructure, and the lawfullness of these operations ensure that 
updates to the substrucuture are reflected accordingly in the larger structure. Thus a lens (given by $lens: S \rightarrowtail A$) is a pair of operations typed as $get: S \rightarrow A$
and $put: S \times A \rightarrow S$, where $A$ is the substructure of $S$. But we can relax the requirement of "substructure"
and generalize \textit{get} and \textit{put} to the definition of concrete lenses:

\begin{definition}(Concrete lenses from \cite[Definition 2.2.1]{BayesianOpenGames}) Let $S$, $T$, $A$, $B$ be objects of 
the category $\Set$. A \textit{concrete lens} l: $(S,T) \rightarrowtail (A,B)$ is a pair of functions 
$u: S \rightarrow A$ and $v: S \times T \rightarrow B$
\end{definition}


To see what this would look like in Haskell, we can treat $u$ and $v$ as the two parameters for instantiating 
a datatype


\begin{minipage}\textwidth
\begin{code}
data Lens s t a b where 
   Lens :: (s -> a) -> (s -> b -> t) -> Lens s t a b
\end{code}
\end{minipage}


One of the important features of these lenses is that they compose sequentially and in parallel,
or in other words, act as morphisms of a symmetric monoidal category where objects are pairs of sets. 
We term sequential composition as morphism composition and parallel composition as the tensor product of the 
symmetric monoidal category. Note that 
$S$ and $A$ are the types for domain and codomain of the
covariant morphisms and $R$ and $B$ are the domain and codomain for contravariant morphisms of these lenses.

To hint at where we are headed towards describing open games as \textit{processes that care about their environment}, intuitively
such a morphism would describe the behaviour of an agent given a certain strategy when operating 
in a given environment, where: 
\begin{itemize} \label{note:hint}
   \item Makes observations of type $S$
   \item Takes actions of type $A$
   \item Recieves some feedback from its local environment of type $T$
   \item Relays information back to the environment of type $B$
\end{itemize}
Thus given (1) a strategy $S \rightarrow A$, (2) an observation of type $S$, and (3) some continuation or feedback 
providing some payoff of type $B$, we will be able to describe what this agent would do. 

Considering the behaviour of agents using these lenses is enough to start constructing a category 
of open games that can model normal-form games \footnote{(see \cite{HedgesThesis,hedges2017morphismsopengames,BayesianOpenGames} to see how 
this is done and the construction of the category of open games)}. We'll only mention that this category of \textit{concrete open games}
exists, and choose to focus on the successor which is not limited to a deterministic setting. 
For security games or modelling realistic security scenarios, most current models use
mixed strategies, Bayesian games, or incomplete information games.

\subsubsection{Coend lenses and probability}
To accommodate the need for modelling games in a probabilistic setting, we would need a more generalized notion of lenses (and then a more general category of open games), where we can do things like take actions $A$ 
over some probability distribution, or give agents the ability to have some probabilistic belief about their type (as in classic Bayesian games)
. This turns out not to be as simple as attaching a probability monad 
to the current definition of lenses, specifically because the tensor product of the category of open games fails to be associative. 
\footcite[Section 3.4]{BayesianOpenGames}
Instead, the authors of 
\cite{3} use \textit{coend lenses} (or \textit{optics}). 

We recall the definition from \cite[Definition 2.0.1]{riley2018categories}

\begin{definition}[Coend lens] \label{Definition:Coends}
   Given a symmetric monoidal category $\C$ equipped with tensor product $\otimes$, and with pairs of
   objects $(S,T)$ and $(A,B)$, a \textit{coend lens} 
   $l: (S, T) \rightarrowtail (A, B)$ is an element of the set $\int^{\Theta:\C} \C(S, \Theta \otimes A) \times \C(\Theta \otimes R, T)$
\end{definition}

Treating $\C$ as $\mathbf{Set}$ produces the definition of the concrete lenses introduced in the previous section. 
Explicitly, we can treat this set as the pairs of functions $u: S \rightarrow \Theta \otimes A$ and $v: \Theta \otimes B \rightarrow T$
quotiented by the equivalence relations given by $((f \otimes A)u, v) ~ (u, v(f \otimes B))$ for any 
$f: \Theta \rightarrow \Gamma$, $u: S \rightarrow \Theta \otimes A$ and $v: \Gamma \otimes B \rightarrow T$. 

Effectful lenses have been studied in \cite{xie2025effectful,abou2016reflections}, but \cite[Section 4.9]{riley2018categories} implements some desired effectul properties as "effectful 
optics" using the coends as defined here with the appropriate monad (i.e. Writer, State). Since the specific application we 
are interested in for game theoretic modelling is the ability to describe, for example, \textit{behavioural strategies}
and moves of Nature, we use the finite distribution probability monad. 

Based on the intuition we've introduced in the previous section, a \textit{behavioural strategy} would 
then have to be represented by a function of type $S \rightarrow \Prob(A)$ where $\Prob(A)$ is the finitary probability distribution
monad over the actions $A$. This monad is an important type constructor 
used in the \textit{open-game-engine} for wrapping user-defined types, specifically 
the constructor |type Stochastic :: T Double|, where |T| is the probability monad 
given by the module |Numeric.Probability.Distribution|.  

\begin{mdframed}
\begin{example}[Deterministic functions]\label{examples:playDeterministically}
The \textit{open-game-engine} provides a helper function |playDeterministically| to assign any type a probability of 1. 

\begin{code}
definitelyHoneypot = playDeterministically Honeypot 
\end{code}
\end{example}
\end{mdframed}


A way of deriving a function $S \rightarrow \Prob(A)$ from $S \rightarrow A$ is 
to consider the Kleisli category of the finite distribution monad $\Prob$. 
Working in the Kleisli category is handy for composing these morphisms without having 
to open up the monad, but the most common use for our purposes is writing Kleisli arrows of the distribution monad
to write behavioural strategies for our models. Generally speaking, these will follow the format:
\begin{code}
someBehaviouralStrategy :: Kleisli Stochastic s a
\end{code}

In the classic game-theoretic sense, this strategy assigns some probabilistic action of type |a| for every observed type |s|. 

\begin{mdframed}
\begin{example}[Honeypot allocation randomization]
Say we want to describe a defensive strategy that deploys a high interaction honeypot 75\% of the time, a low-interaction honeypot 25\% of the time, and doesn't activate a honeypot 10\% of the time. We can use the helper function |distFromList| and the data type in Example \ref{example:userTypes} as our set of actions. Assuming we deploy this defensive strategy statically, without any observations, we use the type |()| to describe no input.

\begin{code}
defensiveStrategy :: Kleisli Stochastic () Honeypot
defensiveStrategy = Kleisli $ const $
      distFromList 
         [(HighInteraction, 0.75), 
         (LowInteraction, 0.25),
         (Normal, 0.10)]
\end{code}

\end{example}
\end{mdframed}


Using this Kleisli category over the finite distribution monad as the category of interest in Definition \ref{Definition:Coends}, we have a way of keeping track of 
joint probability distributions between \textit{unobservables} and directly observed inputs. 
Using $\Theta$ as a type variable to 
store priors as information to be used later, we can directly express Bayesian updating for agents. \footnote{See \href{Bruno Gavaranovic's blog post}{https://www.brunogavranovic.com/posts/2022-02-10-optics-vs-lenses-operationally.html} for an explanation for how composition works with a nice graphical simulation of how this "internal state" works} 

For the purposes of the \textit{open-game-engine}, the implementation that is used of coend lenses ties this definition together 
as a data type:

\begin{minipage}\textwidth
\begin{code}
   data StochasticOptic s t a b where
      StochasticOptic ::  (s -> Stochastic (z, a))
                           -> (z -> b -> Stochastic t)
                           -> StochasticOptic s t a b
\end{code}
\end{minipage}


Note the implicit quantification |forall z| as part of this data type, which was explicitly given as $\Theta$ in Definition \ref{Definition:Coends}. We retain the value of |z|, the "residual" to be used in computing the backwards pass, which is given as the second argument given to this data constructor. 

\begin{mdframed}
\begin{example}[Forward probabilistic function]\label{example:forward}
We can describe a class of stochastic optics |StochasticOptic s () a ()| which performs a probabilistic computation and disregards any contravariantly flowing information. So we can lift any morphism \mbox{$f: S \rightarrow \Prob(A)$} of $\KlD$ to an optic using the following Haskell function: 
\begin{code}

liftStochastic :: (s -> Stochastic a) -> StochasticOptic s () a () 
liftStochastic f = 
   StochasticOptic 
      ( \x -> do {y <- f x; return ((), y)} )
      (\() () -> return ())
\end{code}
Which ignores any residual, computes morphism $f$, and returns the output. 

\end{example}
\end{mdframed}

Furthermore, $\KlD$ is a symmetric monoidal category and can be used as the underlying category 
of a coend lens in \ref{Definition:Coends}. By \cite[Proposition 2.0.3]{riley2018categories}, there is a symmetric monoidal category 
of coend lenses $\mathbf{Optic}_{\KlD}$ where objects are pairs of sets, and morphisms are coend lenses. Composition and the tensor product is described by the |Optic| typeclass:

\begin{code}
class Optic o where
  lens :: (s -> a) -> (s -> b -> t) -> o s t a b
  (>>>>) :: o s t a b -> o a b p q -> o s t p q
  (&&&&) :: o s1 t1 a1 b1 -> o s2 t2 a2 b2 -> o (s1, s2) (t1, t2) (a1, a2) (b1, b2)
\end{code}

which we can parameterize with the datatype |StochasticOptic| to get our desired operations for "stochastic optics," located in |OpenGames.Engine.OpticClass|. Optic sequential and parallel composition will form the basis of how agent's game-theoretic behaviour compose, with extra details about how to interpret their local contexts given in the next section. We'll also use this opportunity to show how these optics plug together using the type parameters. First, note the type of |(>>>>)| enforces that the output type |a| and the contravariant input type |b| of the first optic correspond to the input type and the contravariant output type of the second optic. Similarly, the type of |(&&&&)| enforces that each of the input and output types are tupled together. Most IDEs will give a pop-up corresponding to the \textbf{ghc} typechecker to help a user line these types up, or a direct error message will be given when trying to compile in \textbf{ghci}.  

% \begin{mdframed}

% \begin{example}[Composition of Bayesian inverse]\label{example:bayesian-updating}

% We can use the |Optic StochasticOptic| class to facilitate composition of Baye's rule, see \cite{braithwaite2023compositional} for the specific category of \textit{Bayesian lenses} for some fixed initial distribution. Since we're in the discrete case, we can calculate the Bayesian inverse between two random variables $X$ and $Y$ as $P(X @|@ Y) = P(X, Y) \div P(Y)$ 

% Assume we have an observation $X$, conditional distribution 

% \end{example}
% \end{mdframed}



\subsubsection{Open games}
We'll start with the formal definition of general open games from \cite[Definition 3.6.1]{BayesianOpenGames} and then demonstrate each of its components. 

\begin{definition}[Open game]
   An open game is comprised of the following data, with $(S,T)$ and $(A,B)$ objects of $\StochOpt((S,T), (A,B))$: 
   \begin{enumerate}
      \item A set of strategies $\Sigma$
      \item A \textit{play function} $P: \Sigma \rightarrow \StochOpt((S,T), (A,B))$
      \item A \textit{best-response function} $B: \Sigma \rightarrow \mathbb{C}((S,T), (A,B)) \rightarrow \mathcal{P}(\Sigma)$
   \end{enumerate}
\end{definition}

Now that we've set our formalization for stochastic optics, we can introduce the  interpretation for these morphisms of $\mathbf{Optic}_{\KlD}$, which describes an \textit{open play} according to a supplied strategy. Given a strategy that assigns an outcome of type |Stochastic a| representing probability distribution over actions for each observation of type |s|, we generate a stochastic optic that is "preloaded" with the behaviour of this strategy. This optic |StochasticOptic s t a b| is open in the sense that it's ready to respond by choosing an action according to its local \textit{context} \footnote{see the following section, \ref{sec:contexts}}. So we can describe a family of optics indexed by behavioural strategies using the Haskell function:
\begin{code}
play: Kleisli Stochastic s a -> StochasticOptic s () a Double
play strategy = StochasticOptic 
      ( \s -> do {y <- runKleisli strategy s; return ((), a)} )
      (\() _ -> return ())
\end{code}

This construction doesn't necessitate a strategic play, and can be used to model computations (processes with no preferences, as seen in \hyperref[example:forward]{Example 4}. This implementation follows from the play function given for \textit{Bayesian agent} in \cite[Definition 4.4.1]{BayesianOpenGames}, which makes an observation, computes an action according to the given strategy, and throws away any real-valued payoff propagated back to it. 

Of the many definitions of open games, we've chosen to follow more closely to the definition for the best response function which takes a strategy and a context to produce the strategies that are in equilibrium. With the following data type, we've reached the highest level for which modellers would be interacting with the open-game-engine when conducting experiments:

\begin{minipage}\textwidth
   \begin{code}
   data OpenGame StochasticOptic StochasticContext x y s t a b = OpenGame {
      play :: List x -> o s t a b,
      evaluate :: List x -> c x s y r -> List y
   }
   \end{code}
\end{minipage}

\begin{mdframed}
\begin{example}[Nature open game]\label{example:nature}
The open-game-engine provides an operator |nature| for instantiating an open game according to a user-defined random draw. Nature corresponds to the terminology used in classical extensive-form Bayesian games, where the first node of the tree is the Nature player providing a type. 

In security games, a defender monitoring traffic cannot identify whether a user is adversarial or a normal consumer. Designing a game would involve fixing a common prior to represent the proportion of users that could be adversarial or not, and have Nature assign the types privately to the first-mover, in this case the user. A 75\% chance of encountering an adversary can be encoded as an open game as follows: 

\begin{code}

data UserType = Normal | Adversary deriving (Eq, Ord, Show2)

natureUser = 
   nature $ 
      distFromList [(Adversary, threatPrior), (Normal, 1 - threatPrior)]
      where threatPrior = 0.75

\end{code}
   
\end{example}
\end{mdframed}

\subsubsection{The context aside}\label{sec:contexts}

So far we alluded to the idea of \textit{context} in open games. Contexts have taken many different forms in the literature, from more bare-bones necessitation of a \textit{history/cohistory} pair, to more formally using a \textit{context functor} to define contexts as elements of $\mathbb{C}((S,T),(A,B))$n \cite{BayesianOpenGames}. 


% Ideally, a modeller would only need to procedurally type games starting with |OpenGame StochasticOptic StochasticContext ... | and use |void| to , but this works against separation-of-concerns, when in fact the 

% Contexts form the arena for modellers to eventually parameterize and "run" the . Having the categorical definition for open games allows for a well-defined (and well-typed) context, and much of the work of the modeller goes into designing this context to understand how a game behaves given certain constraints. 



The name of the game is to describe rational behaviour interacting with an environment. And like in classical-game theory, players make assumptions of other players making utility-maximizing decisions. In the field of view of players, we act according to how we expect other players to act. By knowing other player's |play| function, we have a characterization of describing this pre/post behaviour of other players, which becomes part of the player's field of vision, or \textit{local context}. 

In the string-diagrammatic calculus of open games, a context is given by two components of a coend diagram, with (1) a triangle on the far-left side of the diagram and (2) a triangle on the far-right side of the diagram that essentially "close" our games. The graphical calculus gives an intuitive "hole" that describes this player's position in the flow of information, and explicitly the play of 

Expectedly, the open-game-engine isn't as 



\cite{BayesianOpenGames} . In practice for modelling, the most useful characterization of this context will be through the datatype: 

\begin{code}
data StochasticContext s t a b where
  StochasticContext :: Stochastic (z, s) -> (z -> a -> Stochastic b) 
      -> StochasticContext s t a b
\end{code}

which represents a history/cohistory pair of functions. A typical usage can be simplified 


Closing a game requires an initial state and a continuation  by payoff functions. 

Rather than inlining payoffs, we take the approach of keeping to the components separately and defining a context with the payoffs.

\subsubsection{The category of open games and operations}

By \cite[Theorem 3.10.2]{BayesianOpenGames}, a category of Bayesian open games exists where objects are pairs 
of objects in the Kleisli category of the distribution monad $\mathbf{Kl}(\textbf{D})$ and morphisms are equivalence classes of open games. So modellers will have access to operations that govern sequential and parallel composition of open games as |(>>>)| and |(&&&)| respectively. The same thought-process for piping together these games applies when piping together optics as described in a previous section. 


By precomposing a game that makes an observation with a copy operation (\cite[Definition 4.4.3]{BayesianOpenGames}), we give the rest of the model access to this observation.Now we can use the previous sections and build more explicitly on the ideas alluded to in Section \ref{note:hint}.
Without the DSL, we can write Haskell functions for the \textit{copy} and \textit{delete} operations to write a formula for completing \hyperref[example:nature]{Example 5} game as follows: 

\begin{code}
userGame:: OpenGame
  StochasticOptic
  StochasticContext
  `[Kleisli Stochastic Signal VisitorMove]
  `[[DiagnosticInfoBayesian Signal VisitorMove]]
  (Signal, Signal)
  ()
  (Signal, VisitorMove)
  ((), Double)
userGame = 
   natureUser >>> copyGame >>> 
   (deleteGame >>> (idGame &&& dependentDecision "Bob" [Heads,Tails]))
\end{code}
Note that the tensor product of open games concatenates the resultant types into tuples. This eventually means in order to close a game using a tensor produce, we could be working with games that involve types like |((),())| which becomes unwieldy to work with, so we would have to precompose with |deleteGame| which flattens these tuples in the contravariant direction. Otherwise, we can read this expression as 
\begin{enumerate}
   \item Nature draws a private state 
\end{enumerate}


The most important function for modellers to use that bakes in Bayesian updating and maximization of the expected payoff after updating their belief is the |dependentDecision| function which implements the selection function given in \cite{BayesianOpenGames}[Definition 4.4.1] for Bayesian agents. 




The intuition (as described in \cite[Section 2.1.1]{HedgesThesis}) is to begin thinking 
of an open game as a process, open to and interacting with its local environment through its inputs 
and outputs. A commonly-used representation of an open game is as a box (representing the process or morphism)
with two incoming and two outgoing wires (representing objects of the category).

\begin{figure}[h]
	\centering
	\includegraphics[width=0.5\linewidth]{images/GameSimple.png}
	\caption{A string diagram of an open game \label{figure:Fig. 10}}
	
\end{figure}

\begin{definition}[Sequential composition of open games]
Sequential composition of open games is given by: 
\end{definition}



this $\Theta$ may be some prior distribution representing an agent's belief of their type. Given a prior joint distribution $\Prob(\Theta \times S)$ where $\Theta$ is the unobservables and $S$ is the observable states, the agent can update this prior to a posterior and maximize their expected utility. 


Starting to think of each of these open games as programs, an open game has four types associated with it. 
Here variables $X, Y$ are flowing covariantly (intuitively, flowing forwards) and $S, R$ are flowing contravariantly (which represent the feedback of information). Specifically: 
\begin{itemize}
	\item $X$ is the set of inputs that the open game can observe 
	\item $Y$ is the set of actions that the open game can take, or \textit{outcomes}
	\item $S$ is the set of \textit{co-outcomes} with the purpose of propagating information to precomposed games. 
	\item $R$ is the set of \textit{outcomes}
\end{itemize}

Note that there is no sense of agency attached to open games right off the bat. We have flexibility to define the behaviour of the open system according to our needs, whether as 
a representation of a utility-maximizing agent, or simply a function.  

The type of $\Sigma$, like a pure strategy profile in normal-form games, can be selecting an action from the set of actions. 
For sequential games, a strategy would typically involve choosing an action in response to each possible observed action played previously, 
thus such a strategy would be a function of type $X \rightarrow Y$.

\subsubsection{Reading the DSL}
Rather than constructing games using the aforementioned functions, we can use a DSL that compiles to Haskell. The following example 

\begin{code}
openGame exoVar = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:

   inputs:;
   feedback:;
   operation: dependentDecision;
   outputs:;
   returns: ;

   :----------------------------:

   outputs: ;
   returns:;

 |]

\end{code}

We treat any parameters such as |exoVar| as exogenous parameters introduced outside the game.




\subsubsection{Custom types and specifiying strategies}
The \textit{behavioural strategies} of type |Kleisli Stochastic s a| have already been described in a previous section, but we made no indication for what |s| and |a| had to be. The 

\subsubsection{Debugging}
We make mistakes or make independent changes to one function which may cause an entire code block not to compile because types are not consistent. In the case of open games, tracking four inputs and outputs for each building block can be cumbersome. Fortunately, Haskell's typechecker and 