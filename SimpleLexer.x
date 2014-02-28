{
module SimpleLexer(alexScanTokens,Tok(..)) where
}
%wrapper "basic"

$di = 0-9
$a = a-z
$A = A-Z
$n0 = [$a $A \_ ]

tokens :-
	\-\-.*						;
	$white+						;
	$n0 ($n0 | $di)* 			{N}
	$di+ 							{I . read}
	[\=\+\-\*\/\(\)\,\:\;] 	{S}
{
data Tok = 	N String 	--name
			|	I Integer 	--integer
			|	S String		--symbol
			deriving (Show,Eq)
--main = getContents >>= print.alexScanTokens
}
