# Update History

### 0.0.1:  
initial release  
"First release!"

### 0.0.2:  
fixing my dumb mistakes, a lot of values now use local instead of module so that you can't accidentally use methods not intended for you  
"fixing my dumb mistakes, a lot of values now use local instead of module so that you can't accidentally use methods not intended for you"

## 0.1.0: 
added rem (removes a variable), added prt (prints the evaluation of all following inputs, can be used to print variables), fixed some bugs and mistakes  
"Added 'rem' and 'prt' commands. Fixed some bugs. Fixed some mistakes."

### 0.1.1:  
added adjustable delay between executed lines; this required a slight rewrite of the entire system (and introduced some really stupid code), however it does fix bugs i hadn't considered before  
"Revamped code to enable multiple simultaneous executions without interference. Also added the ability to delay between lines of code."

### 0.1.2:  
parameter tables now use a metatable with .\_\_index to use default values; debuglogging and logging are now differentiated
"Now using a metatable for parameters to simplify adding default values. Debug logging and regular logging are now differentiated."
