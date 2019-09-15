# Calendar class
Create a wallcalender with Tikz.

## Usage
Load the class and specify a title and year.
The events for each month must be added before
the month is typeset by makeMonth macro.

```
\title{My awesome title}
\setYear{2020}
\begin{document}

    \makeCover{/path/to/cover}

    \addEvent{01}{01}{First day of the year}
    \makeMonth{/path/to/the/image.png}{1}

\end{document}
```