.FORCE:
sqgen:SimpleLexer.x sqgen.y
	alex SimpleLexer.x
	happy sqgen.y
	ghc -O2 sqgen.hs
lexer: SimpleLexer.x
	echo -e 'import SimpleLexer\nmain=interact(show.alexScanTokens)' > lexer.hs
	ghc -O2 lexer
tables.sql: sqgen test.sqg
	./sqgen < test.sqg > tables.sql
commit: sql_prep.sql tables.sql sql_post.sql
	cat $< >commited.sql
	mysql<commited.sql
clean: .FORCE 
	rm -f SimpleLexer.hs sqgen.hs *.hi *.o
