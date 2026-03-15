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

But black boxing into this DSL the development of these models may not be enough to create intuitive models. If we wanted to ship a certain model expressly as a series of open games written in the DSL, the constraints coworkers have come down to the input and output types of the games. Otherwise, the process of generating strategies to run the game, reading through the console output of simulating the game, or refactoring a single input variable within the game, requires deeper knowledge of |OpenGames.Engine.Engine|. 

Thus we can take a look at the following code example from to introduce the separation 
of these two concepts: 
\framedhs
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
and generalize \textit{get} and \textit{put} to the definition of concrete lenses given in 
\cite{BayesianOpenGames}[Definition 2.2.1]

\begin{Definition}(Concrete lenses) Let $S$, $T$, $A$, $B$ be objects of 
the category $\Set$. A \textit{concrete lens} l: $(S,T) \rightarrowtail (A,B)$ is a pair of functions 
$u: S \rightarrow A$ and $v: S \times T \rightarrow B$
\end{Definition}


To see what this would look like in Haskell, we can treat $u$ and $v$ as the two parameters for instantiating 
a datatype
\begin{code}
data Lens s t a b where 
   Lens :: (s -> a) -> (s -> b -> t) -> Lens s t a b
\end{code}

One of the important features of these lenses is that they compose sequentially and in parallel,
or in other words, act as morphisms of a symmetric monoidal category where objects are pairs of sets. 
We term sequential composition as morphism composition and parallel composition as the tensor product of the 
symmetric monoidal category. Note that 
$S$ and $A$ are considered the "boundaries" that dictate 
covariant morphisms and $R$ and $B$ are the "boundaries" for contravariant morphisms of these lenses, or readers can use 
morphisms from $\mathbf{Set} \times \mathbf{Set}^{\mathbf{op}}$.

To hint at where we are headed in game-theoretic terms, intuitively
such a morphism would describe the behaviour of an agent given a certain strategy when operating 
in a given environment, where: 
\begin{itemize} \label{note:hint}
   \item Makes observations of type $S$
   \item Takes actions of type $A$
   \item Recieves some feedback from its local environment of type $T$
   \item Relays information back to the environment of type $B$
\end{itemize}
Thus given a (1) a strategy $S \rightarrow A$, (2) an observation of type $S$, and (3) some continuation or feedback 
providing some payoff of type $B$, we will be able to describe what this agent would do. 

Considering the behaviour of agents using these lenses is enough to start constructing a category 
of open games that can model normal-form games (see \cite{HedgesThesis,hedges2017morphismsopengames,BayesianOpenGames} to see how 
this is done and the construction of the category of open games). We'll only mention that this category of \textit{concrete open games}
exists, and choose to focus on the successor which is not limited to a deterministic setting. 
For security games or modelling realistic security scenarios, most current models use
mixed strategies, Bayesian games, or incomplete information games.

\subsubsection{Coend lenses and probability}
To accommodate the need for modelling games in a probabilistic setting, we would need a more generalized notion of lenses (and then a more general category of open games), where we can do things like take actions $A$ 
over some probability distribution, or give agents the ability to have some probabilistic belief about their type (as in classic Bayesian games)
. This turns out not to be as simple as attaching a probability monad 
to the current definition of lenses, specifically because the tensor product of the category of open games fails to be associative,
(see \cite[Section 3.4]{BayesianOpenGames} to understand why this happens). Instead, the authors of 
\cite{3} use \textit{coend lenses} (or \textit{optics}) to construct Bayesian open games. 

We recall the definition from \cite[\textbf{Definition 2.0.1}]{riley2018categories}

\begin{definition}[Coend lens] \label{Definition:Coends}
   Given a symmetric monoidal category $\C$ equipped with tensor product $\otimes$, and with pairs of
   objects $(S,T)$ and $(A,B)$, a \textit{coend lens} 
   $l: (S, T) \rightarrowtail (A, B)$ is an element of the set $\int^{\Theta:\C} \C(S, \Theta \otimes A) \times \C(\Theta \otimes R, T)$
\end{definition}

Treating $\C$ as $\textbf{Set}$ reduces this definition to the concrete lenses introduced in the previous section.
Explicitly, we can treat this set as the pairs of functions $u: S \rightarrow \Theta \otimes A$ and $v: \Theta \otimes B \rightarrow T$
quotiented by the equivalence relations given by $((f \otimes A)u, v) ~ (u, v(f \otimes B))$ for any 
$f: \Theta \rightarrow \Gamma$, $u: S \rightarrow \Theta \otimes A$ and $v: \Gamma \otimes B \rightarrow T$. Indeed, 


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

A quick way of deriving a function $S \rightarrow \Prob(A)$ from $S \rightarrow A$ is 
to consider the Kleisli category of the finite distribution monad $\Prob$. 
Working in the Kleisli category is handy for composing these morphisms without having 
to open up the monad, but the most common use for our purposes is writing Kleisli arrows of the distribution monad
to write behavioural strategies for our models. Generally speaking, these will follow the format:
\begin{code}
someBehaviouralStrategy :: Kleisli Stochastic s a
\end{code}

Using this Kleisli category over the finite distribution monad as the category of interest in \ref{Definition:Coends}, we have a way of keeping track of 
correlations (or \textit{marginals} from probability theory, or \textit{residuals} 
defined over indirectly observed variables (which we call \textit{unobservables}). 
Using $\Theta$ as a type variable to 
store this information to be used later, we can directly express Bayesian updating for agents. For example, 
this $\Theta$ may be some prior distribution representing an agent's belief of their type. 

For the purposes of the \textit{open-game-engine}, the implementation that is used of coend lenses ties this definition together 
as a data type:

\begin{code}
data StochasticOptic s t a b where
  StochasticOptic ::  (s -> Stochastic (z, a))
                          -> (z -> b -> Stochastic t)
                          -> StochasticOptic s t a b
\end{code}

Note the implicit |forall z| as part of this definition, which represents $\Theta$. 

Furthermore, $\KlD$ is a symmetric monoidal category and can be used as the underlying category 
of a coend lense in \ref{Definition:Coends}. By \cite[Proposition 2.0.3]{riley2018categories}, there is a symmetric monoidal category 
of coend lenses where objects are pairs of sets, and morphisms are coend lenses. Composition and the tensor product is described by the |Optic| typeclass:

\begin{code}
class Optic o where
  lens :: (s -> a) -> (s -> b -> t) -> o s t a b
  (>>>>) :: o s t a b -> o a b p q -> o s t p q
  (&&&&) :: o s1 t1 a1 b1 -> o s2 t2 a2 b2 -> o (s1, s2) (t1, t2) (a1, a2) (b1, b2)
\end{code}

which we can parameterize with |StochasticOptic| to get our desired category of "stochastic optics." 


\subsubsection{Open games}
Now we can use the previous sections and build more explicitly on the ideas from \ref{note:hint}.
By \cite[Theorem 3.10.2]{BayesianOpenGames}, a category of Bayesian open games exists where objects are pairs 
of objects in the Kleisli category of the distribution monad $\mathbf{Kl}(\textbf{D})$ and morphisms are equivalence classes of open games.
f
The intuition (best described in \cite[Section 2.1.1]{HedgesThesis}) is to begin thinking 
of an open game as a process, open to and interacting with its local environment through its inputs 
and outputs. The most common representation of open games is a box (representing the process or morphism)
with two incoming and two outgoing wires (representing objects of the category).

\begin{figure}[h]
	\centering
	\includegraphics[width=0.5\linewidth]{images/GameSimple.png}
	\caption{A string diagram of an open game \label{figure:Fig. 10}}
	
\end{figure}


\begin{Definition} (Concrete open game, from \cite{BayesianOpenGames}) Let $X$, $S$, $Y$, $R$ be sets. Then a concrete open game $G: (X,S) \rightarrow (Y,R)$ is given by: 
	\begin{enumerate}
		\item A set of strategy profiles $\Sigma$
		\item A play function $P : \Sigma \rightarrow \mathbf{CL}((X,S), (Y,R))$
		\item A best response function $B: X \times (Y \rightarrow R) \rightarrow Rel(\Sigma)$
	\end{enumerate}

\end{Definition}

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



\begin{code}
openGame var1 var2 = [opengame|
   inputs : ;
   feedback: ;
   :----------------------------:

   inputs:;
   feedback:;
   operation:;
   outputs:;
   returns: ;

   :----------------------------:

   outputs: ;
   returns:;

 |]

\end{code}


\begin{enumerate}
   \item $X \rightarrow Y$
   \item $X \times R \rightarrow S$
\end{enumerate}

So what does this lense object represent? As soon as we supply our open system 
with a strategy, the resultant lense describes the behaviour of the system 


Breaking down the best response function, note othe domain $X \times \rightarrow$

\begin{definition}The category of open games, $\mathbf{Open}$
\end{definition}


Thus, we can begin thinking of an agent as defined by a) what it sees, b) what it does, c) what it sees according to the action it took. 
Departing from the standard of defining a global structure around agents, payoffs, and strategies, we can understand agents as a wider class of abstract notions called "open games." 
How we want these open games to be able to interact with each other can have well-defined properties as morphisms of a category. T
he objects of this category encode the data given in a), b), and c). 



As we see in the corresponding string diagram, the forward (or covariant) arrows correspond to \textit{inputs} and \textit{outputs}, and 

\textit{inputs}, as expected, is where to declare the input to the game. This is typically used  to define the state of a game, observed types or observed actions of other players. Note that declaring these as variables in this line brings them into scope for all other In a 2-player sequential game in the classical sense, the follower player observes the actions of the fi
Thus one way of "doing" compositional game theory can be done by drawing a string diagram to represent open games. 

As outlined in \cite{tan2022a} for designing institutions with a software 
