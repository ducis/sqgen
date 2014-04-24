{
{-# LANGUAGE NoMonomorphismRestriction,TupleSections #-}
import SimpleLexer
--import qualified Data.Sequence as S
--import Data.Sequence((<|),(|>),(><))
import qualified Data.DList as D
import Control.Applicative 
import Data.Monoid
import Control.Monad
import Data.List
import qualified Data.List.Ordered as LO
import Data.Function
}
%name translate src
%tokentype{ Tok }
%error { (error.("ERR!"++).show) }
%token
	i							{ I $$ }
	n							{ N $$ }
	'('						{ S "(" }
	')'						{ S ")" }
	':'						{ S ":" }
	';'						{ S ";" }
	','						{ S "," }
	s							{ S $$ }
%%

src::{ St }
src 	: {df ""} 
		| src n '(' attrs ')' ';'	
		{
			let 
				(keys,defs) = unzip $ map (\(k,n,ty)->((k,n), n|+' '|+|ty)) $ D.toList $4
				lines = (defs ++) 
					$ map ((|+')').("UNIQUE ("++|).delimit' ",".map snd) 
					$ groupBy ((==) `on` fst) $ LO.sortOn fst $ filter ((>=0).fst) keys
			in	$1 |++ "CREATE TABLE " |++ $2 |++ "(\n" 
				|+| (delimit' ",\n" $ map ('\t'+|) $ lines) |++ "\n);\n"
		}

attr::{ (Int,St,St) }
attr	:	n 										{(-1, df $1, df "▶text")}
		| i n 									{(fi $1, df $2, df "▶text")}
		| attr ':' n
		{
			let (i,a,t) = $1 in (i,a,).df $ case $3 of
				"i"->"▶integer"
				"I"->"▶bigint"
				"s"->"▶serial"
				"S"->"▶bigserial"
				"f"->"▶real"
				"F"->"▶double precision"
				"t"->"▶text"
				"j"->"▶json"
				"b"->"▶bytea"
				"p"->"▶timestamp"
				x->x
		}

attrs::{ D.DList (Int,St,St) }
attrs	:	attr 									{ D.singleton $1 }
		|	attrs ',' attr 						{ $1|+$3 }

{

delimit::D.DList a->[D.DList a]->D.DList a
delimit dlmt xs = D.concat $ intersperse dlmt xs
delimit' = delimit.df
a +| as = D.cons a as
as |+ a = D.snoc as a
x |+| y = D.append x y
x |++ y = x |+| df y
x ++| y = df x |+| y
type St = D.DList Char
df = D.fromList
fi = fromIntegral 
main = getContents >>= putStrLn.D.toList.translate.alexScanTokens
--main = getContents>>=print
--parseError::[Token]->a
--parseError e = error (errorshow e)
}

