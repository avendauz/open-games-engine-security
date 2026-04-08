\documentclass[11pt,titlepage,dvipsnames,table,xcdraw,english]{article}
%!TEX root=./latex-dissertation.tex
%include polycode.fmt
\usepackage{haskell}
\usepackage{amsmath}
\usepackage{listings}
\usepackage{strath-dissertation}
\usepackage{setspace}
\usepackage{tcolorbox}
\usepackage{babel}
\usepackage{lipsum} % For demonstration only.
\usepackage[backend=biber, style=numeric-comp]{biblatex}
\usepackage{xcolor}
\usepackage{etoolbox}
\addbibresource{bibliography.bib}

% MACROS 
\newcommand{\C}{\mathcal{C}}
\newcommand{\Optic}{\mathbf{Optic}_{\C}}
\newcommand{\Set}{\mathbf{Set}}
\newcommand{\Prob}{\mathbf{D}}
\newcommand{\KlD}{\mathbf{Kl}(\Prob)}
\newcommand{\StochOpt}{\mathbf{Optic}_{\KlD}}
% lhs2TeX colours
\definecolor{funcColor}{HTML}{5E2D91}
\definecolor{typeColor}{HTML}{000080}
\definecolor{datatype}{RGB}{196, 6, 11}
\renewcommand{\Conid}[1]{{\color{funcColor}{#1}}}
\renewcommand{\Varid}[1]{{\color{typeColor}{#1}}}


% \renewcommand{\Conid}[1]{{\color{funcColor}\texttt{#1}}}
% \renewcommand{\Varid}[1]{{\color{typeColor}\texttt{#1}}}
%subst keyword a = "\mathbf{"a"}"
%format \_ = "\lambda\_"
\newcommand{\colorOp}[1]{\textcolor{orange!80!black}{\texttt{#1}}}


\usepackage{mdframed}
\mdfsetup{
    skipabove=20pt,   % Space between the previous paragraph and the box
    skipbelow=20pt,   % Space between the box and the following paragraph
}
\newtheorem{Definition}{Definition}
\newtheorem{definition}{Definition}[section]
\newtheorem{theorem}{Theorem}
\newtheorem{example}{Example}

% \AtBeginEnvironment{example}{
%   \renewcommand{\Conid}[1]{{\color{funcColor}\texttt{#1}}}
%   \renewcommand{\Varid}[1]{{\color{typeColor}\texttt{#1}}}
% }

% 
%--------------------------------
% Degree settings
%--------------------------------
\newcommand{\degreename}{MPhil}
\newcommand{\coursename}{Computer and Information Sciences}
\newcommand{\deptname}{Computer and Information Sciences}

\begin{document}

%--------------------------------
% Title page.
%--------------------------------
\begin{titlepage}
\vspace*{5mm}
\titletext{Compositional model formulation\\ techniques for cybersecurity games}
\vspace{10mm}
\authortext{Aven Dauz}
\vspace{15mm}
\degreetext{\degreename}{\coursename}
\vspace{40mm}
\centredcrest
\vspace{5mm}
\depttext{\deptname}
\vspace{5mm}
\datetext{October, 2025}
\end{titlepage}

%--------------------------------
% Front matter numbering.
%--------------------------------
\pagenumbering{roman}
\setcounter{page}{2}

%--------------------------------
% Setting counter depth.
%--------------------------------
\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{2}

%--------------------------------
% The front matter.
%--------------------------------
\setstretch{1.5} % 1.5 line spacing. 
\input{abstract}
\input{declaration}
\clearpage
\input{acknowledgements}  % Uncomment to include this page.

%--------------------------------
% Tables of contents.
%--------------------------------
\setstretch{1.0} % 1.0 line spacing.  
\clearpage
\tableofcontents
%\listoffigures   % Uncomment for af list of figures.
%\listoftables    % Uncomment for a list of tables.
\clearpage

%--------------------------------
% The body of the document.
%--------------------------------
\pagenumbering{arabic} % Page numbering for rest of document.
\setstretch{1.5} % 1.5 line spacing. 

%-------------- PRELIMINARIES ------------------
%include preliminaries.lhs

%include chapter1.lhs

%include chapter2.lhs

%--------------------------------
% Bibliography
%--------------------------------
\clearpage
\setstretch{1.0}  % 1.0 line spacing. 
\printbibliography
\clearpage

%--------------------------------
% Appendices
%--------------------------------
%\appendix
\setstretch{1.5} % 1.5 line spacing.
%\input{example-appendix} % Add one file per appendix

\end{document}
