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
    .style={%
        color=black,
        text opacity=1,
        fill=white,
        fill opacity=0.6
    },
    height/.initial=.15\paperheight,
    year/.initial=2021,
    title/.initial={A default title},
    subtitle/.initial={A default subtitle},
    author/.initial=A default author,
    marker/.initial={\draw[/calendar, thick, fill=none] (0,0) circle (\f@size pt * 0.7);},
    marker/.style={}
    weekend/.initial={},
    weekend/.style={text=red!60!black},
    % summary keys
    /calendar/summary/.cd,
    .style={
        color=black,
        fill=white,
        fill opacity=0.6
    },
    columns/.initial=3,
    rows/.initial=4,
    xmargin/.initial=0.35,
    ymargin/.initial=0.35,
    % front keys
    /calendar/front/.cd,
    .style={%
        color=black,
        double=black,
        double distance=1mm,
        fill=white,
        fill opacity=0.8
    },
    minimum height/.initial=.25\textheight,
    minimum width/.initial=.8*\textwidth
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
% Set a subtitle (not yet used)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\renewcommand*{\subtitle}[1]{%
    \tikzset{/calendar/subtitle=#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rewrite the author macro, do call the
% default macro to set the pdf author as well.
%
% EXAMPLE: \author{My awesome calendar}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\let\authororiginal\author
\renewcommand*{\author}[1]{%
    \authororiginal{#1}
    \tikzset{/calendar/author=#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set global tikz keys
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand*{\gtikzset}[1]{%
    \begingroup%
     \globaldefs=1\relax%
     \pgfqkeys{/tikz}{#1}%
    \endgroup%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the year
%
% param 1 - the year
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\setYear}[1]{%
    \tikzset{/calendar/year=#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the calendar height
%
% param 1 - value [0,\paperheight]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\setHeight}[1]{%
    \tikzset{/calendar/height=#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the calendar height
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print the calendar part
%
% param 1 - month
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\printCalendar}[1]{%
    % Some help variables
    \coordinate (topCenter) at ([yshift=\pgfkeysvalueof{/calendar/height}]current page.south);
    \coordinate (topLeft) at ([yshift=\pgfkeysvalueof{/calendar/height}]current page.south west);
    \coordinate (bottomCenter) at (current page.south);
    \coordinate (bottomRight) at (current page.south east);
    \coordinate (monthLine) at ([yshift={-0.5*height("A")}]topCenter);

    \begin{scope}[/calendar]
        % The calendar background
        \fill (topLeft) rectangle (current page.south east);
        % Left month label
        \node[anchor=north west, fill=none] (month)
            at ([xshift=-.5\textwidth]monthLine) {%
                \huge\pgfcalendarmonthname{#1}
            };
        % Right year label
        \node[anchor=north east, fill=none] (year)
            at ([xshift=.5\textwidth]monthLine) {%
                \huge\pgfkeysvalueof{/calendar/year}
            };
    \end{scope}
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
% Create a cover page
%
% TODO specify title and date as nodes which can be styled
%
% param 1 - path to the cover image
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\makeCover}[1]{%
    \begin{coverPage}{#1}
        \makeFront
    \end{coverPage}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Create a front
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand{\makeFront}{%
    % Set the calendar bg
    \node[anchor=center,
        /calendar/front,
        minimum height=\pgfkeysvalueof{/calendar/front/minimum height},
        minimum width=\pgfkeysvalueof{/calendar/front/minimum width}] (background)
        at ([yshift=-0.20*\paperheight]current page.center) {
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
% Create a front with subtitle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand{\makeFrontWithSubtitle}{%
    \node[anchor=center]
        at ($(current page.center)!.5!(current page.south)$) {%
        \begin{tikzpicture}
            \draw[/calendar/front, local bounding box=rect]
                (0,0) rectangle (.7\textwidth, 0.33\textheight)
                node[anchor=center] at ($(rect.north)!0.2!(rect.south)$) {%
                    \huge\pgfkeysvalueof{/calendar/year}%
                }
                node[anchor=center] at ($(rect.north)!0.5!(rect.south)$) {%
                    \Huge\pgfkeysvalueof{/calendar/title}
                }
                node[anchor=center] at ($(rect.north)!0.8!(rect.south)$) {%
                    \pgfkeysvalueof{/calendar/subtitle}
                };
        \end{tikzpicture}
    };
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

        \foreach \row in {1,...,\pgfkeysvalueof{/calendar/summary/rows}}
            \foreach \column in {1,...,\pgfkeysvalueof{/calendar/summary/columns}} {
                % Get the month as an integer without decimal point
                \pgfmathsetmacro\month{(int(round(\row-1)*\pgfkeysvalueof{/calendar/summary/columns}+\column))}
                \pgfkeysgetvalue{/calendar/months/img\month}{\image}
                % Convenience vars: Get vars from pgf backend
                \pgfmathsetmacro\xmargin{\pgfkeysvalueof{/calendar/summary/xmargin}}
                \pgfmathsetmacro\ymargin{\pgfkeysvalueof{/calendar/summary/ymargin}}
                \pgfmathsetmacro\xshift{\paperwidth*(\xmargin*((\column - 1) - 1))}
                \pgfmathsetmacro\yshift{\paperheight*(\ymargin*(1-(\row - 1)/(\pgfkeysvalueof{/calendar/summary/rows}-1)*2))}
                \node[anchor=center] () at
                    ([xshift=\xshift,yshift=\yshift]current page.center) {
                        \includegraphics[height=.2\paperheight]{\image}
                };
        };

        \node[/calendar/summary, anchor=south, text opacity=1, fill=none]%
            at ([yshift={.5*\paperheight-.5*\textheight-.5*\f@size}]current page.south) {%
                \small\textit{Made by \pgfkeysvalueof{/calendar/author}}
        };
    \end{tikzpicture}
    \clearpage
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Typeset a month with an open tikzpicture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newenvironment*{monthPage}[2]{%
    \gtikzset{/calendar/months/img\number#1/.initial={#2}}
    \begin{page}{#2}
}{%
    \end{page}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print an event line
%
% param 1 - month
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\printEventline}[1]{%
    \node[anchor=south west, /calendar, fill=none] (events)%
        at([xshift=-.5*\textwidth,yshift=(.5*\paperheight-.5*\textheight)] bottomCenter) {%
            \small\textit{\pgfkeysvalueof{/calendar/months/ev#1}}%
        };

    \node[anchor=south east, /calendar, fill=none] (description)%
        at([xshift=(-.5*\paperwidth+.5*\textwidth),yshift=(.5*\paperheight-.5*\textheight)] bottomRight) {%
            \small\textit{\pgfkeysvalueof{/calendar/months/desc#1}}%
        };
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Typeset a cover with an open tikzpicture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newenvironment*{coverPage}[1]{%
    \gtikzset{/calendar/cover/.initial={#1}}
    \begin{page}{#1}
}{%
    \end{page}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Typeset a month
%
% EXAMPLE: \makeMonth{01}{/path/to/image}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand*{\makeMonth}[2]{%
    \begin{monthPage}{#1}{#2}
        % calendar part
        \printCalendar{#1}
        % events
        \printEventline{#1}
    \end{monthPage}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% First parameter shall be the month,
% second parameter is the day of month
% third is the event description.
%
% The events must be given before typesetting the month.
%
% param 1 - month
% param 2 - day of month
% param 3 - description
%
% EXAMPLE: \addEvent{01}{01}{First day of the new year}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand{\addEvent}[3]{%
    % Add mark to the given date
    \tikzset{/calendar/weekend/.append={%
        if (equals=\pgfkeysvalueof{/calendar/year}-#1-#2) [/calendar/marker]%
        if (equals=\pgfkeysvalueof{/calendar/year}-#1-#2) {\pgfkeysvalueof{/calendar/marker}}%
        }%
    }%
    % Append the event description to the eventline.
    % Initialise the pgf key if not already defined
    \pgfkeysifdefined{/calendar/months/ev#1}{%
        \tikzset{/calendar/months/ev#1/.append={,\ \pgfcalendarmonthshortname{#1} #2: #3}}
    }{%
        \tikzset{/calendar/months/ev#1/.initial={\pgfcalendarmonthshortname{#1} #2: #3}}
    }%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% First parameter shall be the month,
% second is the month description.
%
% The description must be given before typesetting the month.
%
% param 1 - month
% param 2 - text to display
%
% EXAMPLE: \addText{01}{This image is because...}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
\newcommand{\addText}[2]{%
    % Append the month description to the eventline.
    % Initialise the pgf key if not already defined
    \pgfkeysifdefined{/calendar/months/desc#1}{%
        \tikzset{/calendar/months/desc#1/.append={#2}}
    }{%
        \tikzset{/calendar/months/desc#1/.initial={#2}}
    }%
}
