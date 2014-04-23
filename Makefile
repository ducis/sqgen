.FORCE:
sqgen:SimpleLexer.x sqgen.y
	alex SimpleLexer.x
	happy sqgen.y
	ghc -O2 sqgen.hs
lexer: SimpleLexer.x
	echo -e 'import SimpleLexer\nmain=interact(show.alexScanTokens)' > lexer.hs
	ghc -O2 lexer
tables.sql: sqgen test.sqg
	./sqgen < test.sqg | ./sqgen-pg > tables.sql
commited.sql: sql_prep.sql tables.sql sql_post.sql
	cat $^ >$@
commit-mysql: commited.sql
	mysql<$<
clean: .FORCE 
	rm -f SimpleLexer.hs sqgen.hs *.hi *.o
install: sqgen
	install sqgen sqgen-* /usr/bin
