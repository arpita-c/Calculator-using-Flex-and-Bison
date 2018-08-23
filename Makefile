lexlib=l
yacclib=y
rm=/bin/rm -f
targets=calc
bison=/usr/local/opt/bison\@3.0/bin/bison
flex=/usr/local/opt/flex/bin/flex

all: $(targets)

$(targets): %: %.y
	$(flex) -o$@.lex.c $@.l
	$(bison) -o$@.tab.c -d $<
	gcc -w -o $@ $@.tab.c $@.lex.c -l$(yacclib) -l$(lexlib)

clean:
	$(rm) $(targets)
	$(rm) *.tab.h *.tab.c *.lex.c
