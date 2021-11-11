FROM localhost/my-texlive:latest

RUN mkdir -p /usr/share/texmf/tex/latex/calendar
ADD calendar.cls /usr/share/texmf/tex/latex/calendar/calendar.cls

RUN texhash
