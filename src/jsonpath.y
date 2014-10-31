%start JSONText

%parse-param TEST
/*
  ECMA-262 5th Edition, 15.12.1 The JSON Grammar.
*/
%{

var returnValue = "";

function addToString(element)
{
	//console.log("got here: " + returnValue);
	returnValue = element + returnValue;
}
%}


%%

JSONString
    : STRING
        { // replace escaped characters with actual character
          $$ = {};
          $$[0] = yytext.replace(/\\(\\|")/g, "$"+"1")
                     .replace(/\\n/g,'\n')
                     .replace(/\\r/g,'\r')
                     .replace(/\\t/g,'\t')
                     .replace(/\\v/g,'\v')
                     .replace(/\\f/g,'\f')
                     .replace(/\\b/g,'\b'); 
	  $$.ismagic = false;
	  //console.log("Line: " + @1.first_line + " Column: " + @1.first_column + ", " + @1.last_column + " " + $1 + " Range: " + @1.range[0] + "-" + @1.range[1]);
	  if (@1.range[0] <= yy.curpos && @1.range[1] >= yy.curpos)
	  {
		$$.ismagic = true;
	  }
        }
    ;

JSONNumber
    : NUMBER
        {$$ = Number(yytext); $$.ismagic = false;}
    ;

JSONNullLiteral
    : NULL
        {$$ = null; } // $$.ismagic = false;}
    ;

JSONBooleanLiteral
    : TRUE
        {$$ = true; $$.ismagic = false;}
    | FALSE
        {$$ = false; $$.ismagic = false; }
    ;

JSONText
    : JSONValue EOF
        { 
		returnValue = "";
		yy.myStack.forEach(addToString);
		return returnValue; 
	} 
    ;

JSONValue
    : JSONNullLiteral
    | JSONBooleanLiteral
    | JSONString
    | JSONNumber
    | JSONObject
	{
		$$.ismagic = $1.ismagic;
	}
    | JSONArray
	{
		if ($$.ismagic == true)
		{
			// TODO replace with idx name related to the string assocaited with the array
			yy.myStack.push("[X]");
		}
	}
    ;

JSONObject
    : '{' '}'
        {
		{$$ = {}; $$.ismagic = false; }
	}
    | '{' JSONMemberList '}'
        {
		$$ = $2;
		$$.ismagic = $2.ismagic;
	}
    ;

JSONMember
    : JSONString ':' JSONValue
        {
		if ($1.ismagic == true || ($3 !== null && $3.ismagic == true))
		{
			yy.myStack.push("[\"" + $1[0] + "\"]");
			$$.ismagic = true;
		}
		$$ = [$1, $3]; 
		if ($1.ismagic == true)
		{
			$$.ismagic = $1.ismagic;	
		}
		if ($3 !== null && $3.ismagic == true)
		{
			$$.ismaigc = true;
		}
	}
    ;

JSONMemberList
    : JSONMember
	{
        	$$ = {}; 
		$$[$1[0]] = $1[1]; 
		if ($1.ismagic == true)
		{
			$$.ismagic = true;
		}
	}
    | JSONMemberList ',' JSONMember
        {
		$$ = $1; 
		$1[$3[0]] = $3[1]; 
		if ($3.ismagic == true)
		{
			$$.ismagic = true;
		}
	}
    ;

JSONArray
    : '[' ']'
        {
		$$ = []; 
		$$.ismagic = false; 
	}
    | '[' JSONElementList ']'
        {
		$$ = $2; 
		$$.ismagic = $2.ismagic;
	}
    ;

JSONElementList
    : JSONValue
        {
		$$ = [$1]; 
		if ($1.ismagic == true)
		{
			$$.ismagic = true;
		}
	}
    | JSONElementList ',' JSONValue
        {
		$$ = $1; $1.push($3); 
		if ($3.ismagic == true)
		{
			$$.ismagic = true;
		}
	}
    ;

%%

