\ProvidesClass{calendar}[2018/10/03 A wallcalendar class for fun]
\NeedsTeXFormat{LaTeX2e}
\LoadClassWithOptions{article}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   forwarded package options
%%   size:   a4paper, a3paper, a2paper
%%   layout: landscape OR portrait
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[margin=2mm, verbose,nohead,nofoot]{geometry}

\RequirePackage{translator}

% does the main work, pgf frontend
\RequirePackage{tikz}
\usetikzlibrary{calc}
\usetikzlibrary{calendar}

\pagestyle{empty}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Do not indent the first line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\setlength{\parindent}{0pt}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define some keys
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\pgfkeys{/tikz/.cd,%
    calendar height/.initial=.15\paperheight,
    calendar height/.get=\calheight,
    calendar height/.store in=\calheight,
    calendar opacity/.initial=0.6,
    calendar year/.initial=2020,
    calendar title/.initial=A default title,
    calendar filter/.initial={},
    calendar bg/.initial=white,
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Rewrite the title macro, do call the
%% default macro to set the pdf title.
%%
%% EXAMPLE: \title{My awesome calendar}
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\let\titleoriginal\title
\renewcommand*{\title}[1]{%
    \titleoriginal{#1}
    \tikzset{/tikz/calendar title=#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the color + opacity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\setBackground}[2]{%
    \tikzset{/tikz/calendar bg=#1}
    \tikzset{/tikz/calendar opacity=#2}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the year
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\setYear}[1]{%
    \tikzset{/tikz/calendar year=#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the calendar height
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\setHeight}[1]{%
    \tikzset{/tikz/calendar height=#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Create a cover page
%%
%% TODO specify title and date as nodes which can be styled
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand{\makeCover}[1]{%
    \begin{tikzpicture}[remember picture,overlay,anchor=north]
        %%%%%%%%%%
        %% The image is first param.
        %%
        %% Save the image path afterwards
        %% in /tikz/calendar/images/cover
        %%%%%%%%%%
        \node[anchor=center] (names)
            at (current page.center) {
            \if\paperwidth>\paperheight
                %landscape
                \includegraphics[height=\paperheight]{#1}
            \else
                %portrait
                \includegraphics[width=\paperwidth]{#1}
            \fi
        };
        %%%%%%%%%%
        %% The calendar bg
        %%%%%%%%%%
        \node[anchor=center,
            fill=\pgfkeysvalueof{/tikz/calendar bg},
            fill opacity=\pgfkeysvalueof{/tikz/calendar opacity},
            minimum height=0.25*\textheight,
            minimum width=0.8*\textwidth] (background)
            at ([yshift=.25\textheight]current page.south) {};
        %%%%%%%%%%
        %% The year + title
        %%%%%%%%%%
        \node[anchor=center]
            at ([yshift=.25\textheight]current page.south) {%
                \begin{minipage}{0.7\textwidth}
                    \centering
                    \Huge\pgfkeysvalueof{/tikz/calendar year}\\
                    \vspace*{.05\textheight}
                    \huge{\pgfkeysvalueof{/tikz/calendar title}}
                \end{minipage}
            };
    \end{tikzpicture}
    \tikzset{/tikz/calendar/images/cover/.initial={#1}}
    \clearpage
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%
%% Create a last page
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand*{\makeSummary}{%
    \begin{tikzpicture}[remember picture,overlay,anchor=north]
        \node[anchor=center,opacity=0.2] (bg)
            at (current page.center) {
            \pgfkeysgetvalue{/tikz/calendar/images/cover}{\coverImage}
            \if\paperwidth>\paperheight
                %landscape
                \includegraphics[height=\paperheight]{\coverImage}
            \else
                %portrait
                \includegraphics[width=\paperwidth]{\coverImage}
            \fi
        };
        \foreach \row in {1,...,4}
            \foreach \column in {1,...,3} {
                \pgfmathsetmacro\result{(int(round(\row-1)*3+\column))}
                \node[anchor=center] () at ([xshift=(\paperwidth*(-0.35 +(\column - 1)/2*0.7)),yshift=(\paperheight*(0.35 - (\row - 1)/3*0.7))]current page.center) {
                     \includegraphics[height=.2\paperheight]{\pgfkeysvalueof{/tikz/calendar/images/\result}}
                };
        }
    %% Have a grid of 4x3 or 3x4
    \end{tikzpicture}
    \clearpage
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Typeset a month
%%
%% EXAMPLE: \makeMonth{01}{/path/to/image}
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand*{\makeMonth}[2]{%
    \begin{tikzpicture}[remember picture,overlay,anchor=north]
        %%%%%%%%%%
        %% The image is first param.
        %%%%%%%%%%
        \node[anchor=center] (names)
            at (current page.center){%
            \if\paperwidth>\paperheight
                %landscape
                \includegraphics[height=\paperheight]{#2}
            \else
                %portrait
                \includegraphics[width=\paperwidth]{#2}
            \fi
        };

        \coordinate (topCenter) at ([yshift=\calheight]current page.south);
        \coordinate (bottomCenter) at (current page.south);

        %%%%%%%%%%
        %% The calendar bg
        %%%%%%%%%%
        \node[anchor=north,
            fill=\pgfkeysvalueof{/tikz/calendar bg},
            fill opacity=\pgfkeysvalueof{/tikz/calendar opacity},
            minimum height=\calheight,
            minimum width=\paperwidth] (background)
            at (topCenter) {};

        %%%%%%%%%%
        %% Left month label
        %%%%%%%%%%
        \node[anchor=north west,
            minimum height=0.05\textheight]
            (monthname)
            at ([xshift=.5\paperwidth-\textwidth]topCenter) {%
                \huge\pgfcalendarmonthname{#1}
            };

        %%%%%%%%%%
        %% Right year label
        %%%%%%%%%%
        \node[anchor=north east,
            minimum height=0.05\textheight] (yearname)
            at ([xshift=-.5\paperwidth+\textwidth]topCenter) {%
                \huge\pgfkeysvalueof{/tikz/calendar year}
            };

        %%%%%%%%%%
        %% Wrapper is needed to
        %% center it to the page
        %%%%%%%%%%
        \node[anchor=center] (calendar-wrapper)
            at ($(bottomCenter)!0.5!(topCenter)$) {
                \tikz[every day/.style={anchor=mid}] {\calendar[%
                    name=mycal,
                    dates=\pgfkeysvalueof{/tikz/calendar year}-#1-01 to \pgfkeysvalueof{/tikz/calendar year}-#1-last,
                    day xshift=0.032*\textwidth, % times 0.03 is approx 1/33, 0.032 is 1/31
                    day list right, day code={% print weekday character + day number below
                        \node[name=\pgfcalendarsuggestedname,every day]{\tikzdaytext};
                        \node[name=thisday,every day, anchor=mid] at (0,0.5cm) {\pgfcalendarweekdayshortname{\pgfcalendarcurrentweekday}};
                    }]
                    if (weekend) [text=red!60!black]
                    \pgfkeysvalueof{/tikz/calendar filter};
                }
            };
        %%%%%%%%%%
        %% Events
        %%%%%%%%%%
        \node[anchor=south west] (eventline)
            at([yshift=.5\paperheight-.5\textheight, xshift=.5\paperwidth-.5\textwidth]current page.south west)%
                {\small\textit{\pgfkeysvalueof{/tikz/calendar/#1}}};
    \end{tikzpicture}
    %%%%%%%%%%
    %% Save the image for the summary
    %%%%%%%%%%
    \tikzset{/tikz/calendar/images/#1/.initial={#2}}
    \clearpage
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% First parameter shall be the month,
%% second parameter is the day of month
%% third is the event description.
%%
%% The events must be given before typesetting the month.
%%
%% EXAMPLE: \addEvent{01}{01}{First day of the new year}
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand{\addEvent}[3]{%
    %%%%%%%%%%
    %% Add mark to the given date
    %%%%%%%%%%
    \tikzset{/tikz/calendar filter/.append={if (equals=\pgfkeysvalueof{/tikz/calendar year}-#1-#2) {\draw (0,0) circle (8pt);}}}
    %%%%%%%%%%
    %% Append the event description to the eventline.
    %% Initialise the pgf key if not already defined
    %%%%%%%%%%
    \pgfkeysifdefined{/tikz/calendar/#1}{%
        \tikzset{/tikz/calendar/#1/.append={,\ \pgfcalendarmonthshortname{#1} #2: #3}}
    }{%
        \tikzset{/tikz/calendar/#1/.initial={\pgfcalendarmonthshortname{#1} #2: #3}}
    }%
}
