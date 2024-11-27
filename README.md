# Calendar class
Create a wallcalender with Tikz.
Events and a text may be added to a month
and colors of the calender may be adjusted by using pgfkeys.

## Usage
Load the class and specify a title and year.
The events for each month must be added before
the month is typeset by makeMonth macro.

All month params in the latex commands are two digit numbers.

### Function reference

### \addEvent{day}{day of month}{description}
Add an event to the calendar.

### \addText{month}{text to display}
Add a text to the given month.
The text is displayed in the 'event' line from the right, but there is no
'collision' detection with the added events.

### \author{author}
Renewed command to save the calendar author in the pgf keyvalue store.

### \makeCover{/path/to/image}
Set the cover image.

### \makeMonth{month}{/path/to/image}
This creates one page for a month and adds an image.

### \setHeight{[0,\paperheight]}
This command sets the height of the "calendar" part of the page.
Default is 0.15 * \paperheight, on A4 landscape 0.2 may be needed.

### \setYear{the year}
Set the year you want to typeset the calendar for :-)

### \subtitle{the subtitle}
Save a subtitle for the coverpage.

### \title{title}
Renewed command to save the calendar title in the pgf keyvalue store.

### \makeSummary
Print a summary of all used pictures.

### Example
For a working example have a look into [test.tex](test.tex).
