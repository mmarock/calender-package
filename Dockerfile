FROM my-texlive:2

RUN useradd -ms /bin/sh texuser

ENV TEXINPUTS=/home/texuser/tex

USER texuser
RUN mkdir ${TEXINPUTS}

ADD calendar.cls ${TEXINPUTS}/calendar.cls
