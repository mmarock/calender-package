FROM my-texlive:2

ENV TEXINPUTS=/tex

RUN mkdir ${TEXINPUTS}

ADD calendar.cls ${TEXINPUTS}/calendar.cls
