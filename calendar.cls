\ProvidesClass{calendar}[2018/10/03 A wallcalendar class for fun]
\NeedsTeXFormat{LaTeX2e}
\LoadClassWithOptions{scrartcl}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   forwarded package options
%   size:   a4paper, a3paper, a2paper
%   layout: landscape OR portrait
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[margin=2mm, verbose,nohead,nofoot]{geometry}

\RequirePackage{translator}

% does the main work, pgf frontend
\RequirePackage{tikz}
\usetikzlibrary{calc}
\usetikzlibrary{calendar}

\pagestyle{empty}

% Do not indent the first line
\setlength{\parindent}{0pt}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define some keys
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\pgfkeys{%
    /calendar/.cd,
    .style={
        color=black,
        text opacity=1,
        fill=white,
        fill opacity=0.6
    },
    front/.style={
        color=black,
        fill=white,
        fill opacity=0.8
    },
    summary/.style={
        color=black,
        fill=white,
        fill opacity=0.6
    },
    height/.initial=.15\paperheight,
    year/.initial=2021,
    title/.initial=A default title,
    marker/.initial={\draw[/calendar, thick, fill=none] (0,0) circle (\f@size pt * 0.7);},
    summary xmargin/.initial=0.35,
    summary ymargin/.initial=0.35,
    summary rows/.initial=4,
    summary columns/.initial=3,
    weekend/.initial={},
    weekend/.style={text=red!60!black},
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper function for scaling the images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand*{\addImage}[1]{%
    \ifnum\paperwidth>\paperheight%
    %landscape
        \includegraphics[height=\paperheight]{\expanded{#1}}%
    \else%
    %portrait
        \includegraphics[width=\paperwidth]{\expanded{#1}}%
    \fi
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rewrite the title macro, do call the
% default macro to set the pdf title.
%
% EXAMPLE: \title{My awesome calendar}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\let\titleoriginal\title
\renewcommand*{\title}[1]{%
    \titleoriginal{#1}
    \tikzset{/calendar/title=#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the color + opacity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\setBackground}[2]{%
    %\tikzset{/calendar/bg=#1}
    %\tikzset{/calendar/opacity=#2}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the year
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\setYear}[1]{%
    \tikzset{/calendar/year=#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the calendar height
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\setHeight}[1]{%
    \tikzset{/calendar/height=#1}
}

\newenvironment{page}[1]{%
    \begin{tikzpicture}[remember picture,overlay,anchor=north]

        % The image path is the first parameter
        \node[anchor=center] (names)
            at (current page.center) {%
            \addImage{#1}
        };
}{%
    \end{tikzpicture}
    \clearpage
}

\newcommand{\printCalendar}[1]{%
        % Some help variables
    \coordinate (topCenter) at ([yshift=\pgfkeysvalueof{/calendar/height}]current page.south);
        \coordinate (monthLine) at ([yshift={-0.5*height("A")}]topCenter);
        \coordinate (bottomCenter) at (current page.south);

        % The calendar bg
        \node[anchor=north,
            /calendar,
            minimum height=\pgfkeysvalueof{/calendar/height},
            minimum width=\paperwidth] (background)
            at (topCenter) {};

        % Left month label
        \node[anchor=north west, /calendar, fill=none] (month)
            at ([xshift=-.5\textwidth]monthLine) {%
                \huge\pgfcalendarmonthname{#1}
            };

        % Right year label
        \node[anchor=north east, /calendar, fill=none] (year)
            at ([xshift=.5\textwidth]monthLine) {%
                \huge\pgfkeysvalueof{/calendar/year}
            };

        % Wrapper is needed to center it to the page.
        % In fact this is one suggested solution in the manual..
        \node[anchor=center] (calendar-wrapper)
            at ($(bottomCenter)!0.5!(topCenter)$) {
                \tikz \calendar[%
                    /calendar,
                    every day/.style={anchor=mid},
                    name=mycal,
                    dates=\pgfkeysvalueof{/calendar/year}-#1-01 to \pgfkeysvalueof{/calendar/year}-#1-last,
                    day xshift=0.032*\textwidth, % times 0.03 is approx 1/33, 0.032 is 1/31
                    day list right, day code={% print weekday character + day number below
                        \node[name=\pgfcalendarsuggestedname,every day]{%
                            \tikzdaytext%
                        };
                        \node[name=thisday,every day, anchor=mid] at (0,0.5cm) {%
                            \pgfcalendarweekdayshortname{\pgfcalendarcurrentweekday}%
                        };
                    }]
                    if (weekend) [/calendar/weekend]%
                        \pgfkeysvalueof{/calendar/weekend};
            };
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Create a front
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand{\makeFront}{%
    % Set the calendar bg
    \node[anchor=center,
        /calendar/front,
        minimum height=0.25*\textheight,
        minimum width=0.8*\textwidth] (background)
        at ([yshift=.25\textheight]current page.south) {
        % Set the year + title
        \begin{minipage}{\textwidth}
            \centering
            \Huge\pgfkeysvalueof{/calendar/year}\\
            \vspace*{.05\textheight}
            \huge{\pgfkeysvalueof{/calendar/title}}
        \end{minipage}
    };

}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store the cover image 
%
% SEE: \makeCover
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand*{\storeCover}[1]{%
    % Save the image for the summary
    \tikzset{/calendar/cover/.initial={#1}}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Create a cover page
%
% TODO specify title and date as nodes which can be styled
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand{\makeCover}[1]{%
    \begin{page}{#1}
        \makeFront
    \end{page}

    \storeCover{#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Create a summary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand*{\makeSummary}{%
    \begin{tikzpicture}[remember picture,overlay,anchor=north]
        % Print the cover as background
        \node[/calendar/summary, anchor=center] (bg)
            at (current page.center){%
            \addImage{\pgfkeysvalueof{/calendar/cover}}%
        };

        \foreach \row in {1,...,\pgfkeysvalueof{/calendar/summary rows}}
            \foreach \column in {1,...,\pgfkeysvalueof{/calendar/summary columns}} {
                % Get the month as an integer without decimal point
                \pgfmathsetmacro\month{(int(round(\row-1)*\pgfkeysvalueof{/calendar/summary columns}+\column))}
                \pgfkeysgetvalue{/calendar/months/img\month}{\image}
                % Convenience vars: Get vars from pgf backend
                \pgfmathsetmacro\xmargin{\pgfkeysvalueof{/calendar/summary xmargin}}
                \pgfmathsetmacro\ymargin{\pgfkeysvalueof{/calendar/summary ymargin}}
                \pgfmathsetmacro\xshift{\paperwidth*(\xmargin*((\column - 1) - 1))}
                \pgfmathsetmacro\yshift{\paperheight*(\ymargin*(1-(\row - 1)/(\pgfkeysvalueof{/calendar/summary rows}-1)*2))}
                \node[anchor=center] () at
                    ([xshift=\xshift,yshift=\yshift]current page.center) {
                        \includegraphics[height=.2\paperheight]{\image}
                };
        }
    \end{tikzpicture}
    \clearpage
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store a monthly image for the summary
%
% This seems to be a problem to automate since
% pgf variables are bound to Tex groups.
% It seems, that environments create groups and I don't
% find an easy path to set global vars.
%
% SEE: \makeMonth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand*{\storeMonthImage}[2]{%
    % Save the image for the summary
    \tikzset{/calendar/months/img\number#1/.initial={#2}}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Typeset a month
%
% EXAMPLE: \makeMonth{01}{/path/to/image}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand*{\makeMonth}[2]{%
    \begin{page}{#2}
        % calendar part
        \printCalendar{#1}
        % events
        \node[anchor=south west, /calendar, fill=none] (events)%
            at([xshift=-.5\textwidth,yshift=(.5\paperheight-.5\textheight)] bottomCenter) {%
                \small\textit{\pgfkeysvalueof{/calendar/months/ev#1}}%
            };

    \end{page}
    \storeMonthImage{#1}{#2}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% First parameter shall be the month,
% second parameter is the day of month
% third is the event description.
%
% The events must be given before typesetting the month.
%
% EXAMPLE: \addEvent{01}{01}{First day of the new year}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand{\addEvent}[3]{%
    % Add mark to the given date
    \tikzset{/calendar/weekend/.append={if (equals=\pgfkeysvalueof{/calendar/year}-#1-#2) {\pgfkeysvalueof{/calendar/marker}}}}
    % Append the event description to the eventline.
    % Initialise the pgf key if not already defined
    \pgfkeysifdefined{/calendar/months/ev#1}{%
        \tikzset{/calendar/months/ev#1/.append={,\ \pgfcalendarmonthshortname{#1} #2: #3}}
    }{%
        \tikzset{/calendar/months/ev#1/.initial={\pgfcalendarmonthshortname{#1} #2: #3}}
    }%
}
