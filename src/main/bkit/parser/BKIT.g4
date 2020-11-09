//1811137
grammar BKIT;

@lexer::header {
from lexererr import *
}

@lexer::members {
def emit(self):
    tk = self.type
    result = super().emit()
    if tk == self.UNCLOSE_STRING:
        raise UncloseString(result.text)
    elif tk == self.ILLEGAL_ESCAPE:
        raise IllegalEscape(result.text)
    elif tk == self.ERROR_CHAR:
        raise ErrorToken(result.text)
    elif tk == self.UNTERMINATED_COMMENT:
        raise UnterminatedComment()
    else:
        return result;
}

options{
	language=Python3;
}

program: glo_vari_declare*fun_declare* EOF;    //thu tu cua 2 thanh phan    /////////////////////////

glo_vari_declare: VAR COLON glo_variable_list SEMI ;
glo_variable_list: vari_intval COMMA glo_variable_list | vari_intval ;

vari_intval: ID (LSB INTLIT RSB)* (ASSIGN literal)?
            | ID (LSB INTLIT RSB)* (ASSIGN array)?;
//vari_intval: variable (ASSIGN literal)?
//            | variable (ASSIGN array);
//variable: ID (LSB exp RSB)*;//variable: ID (LSB INTLIT RSB)*;
array: LCB list_literal RCB
        | LCB RCB;
list_literal: literal COMMA list_literal | literal;

//        | array_vari_declare;//////////////////////////////////////////
//array_vari_declare: ID LRB

// co nhat thiet ham main phai nam o cuoi cung` ?
//fun_declare_list: fun_declare fun_declare_list | fun_declare;
fun_declare: FUNCTION COLON ID fun_para_struct? fun_body; //sau function name, khoang trang ghi chu thi` ?
fun_para_struct: PARAMETER COLON fun_para_list;
//fun_para_list: variable COMMA fun_para_list | variable;
fun_para_list: ID (LSB INTLIT RSB)* COMMA fun_para_list | ID (LSB INTLIT RSB)*;

fun_body: BODY COLON statement_list ENDBODY DOT;

statement_list: glo_vari_declare* statement_not_declare*;
statement_not_declare: statement statement_not_declare | statement;

//local_vari_declare: VAR COLON local_variable_list SEMI;
//local_variable_list: vari_intval_id COMMA local_variable_list | vari_intval_id;
//vari_intval_id: variable (ASSIGN array)/////dang co array o day
//            | variable (ASSIGN exp)?;
statement: assign_stm
        | if_stm
        | for_stm
        | while_stm
        | do_while_stm
        | break_stm
        | continue_stm
        | call_stm
        | return_stm;
//assign_stm: variable ASSIGN exp SEMI;
assign_stm: exp ASSIGN exp SEMI;       // thieu kieu array
if_stm: IF exp THEN statement_list   //chua giai quyet expression ko phai la boolean
        elseif_of_if*
        else_of_if?
        ENDIF DOT;
elseif_of_if: ELSEIF exp THEN statement_list;
else_of_if: ELSE statement_list;
for_stm: FOR LB ID ASSIGN exp COMMA exp COMMA exp RB//chua giai quyet assign chi dc la integer
        DO statement_list
        ENDFOR DOT;
while_stm: WHILE exp DO statement_list ENDWHILE DOT;//chua giai quyet expression ko phai la boolean
do_while_stm: DO statement_list WHILE exp ENDDO DOT;//chua giai quyet expression ko phai la boolean
break_stm: BREAK SEMI;//is it a stm ?
continue_stm: CONTINUE SEMI;// is it a stm ?
call_stm: ID LB call_stm_para_list? RB SEMI;
call_stm_para_list: exp COMMA call_stm_para_list | exp;// co dung ko ?
return_stm: RETURN exp? SEMI;

//expression: unary | binary; //bao gom co ID va ko co ID
//unary: (INTSUB|FLOATSUB)? operand;//(INTSUB|FLOATSUB)? operation;////////////////////////////////////////////////
//binary: operand OPERATOR operand;

//operand: (constants|variable|expression|call_stm);
//constants: (INTSUB|FLOATSUB)? literal;// -True ?

relational_op: INTEQUAL
                |INTNOTEQUAL
                |INTLESS
                |INTGREATER
                |INTLESSEQUAL
                |INTGREATEREQUAL
                |FLNOTEQUAL
                |FLLESS
                |FLGREATER
                |FLLESSEQUAL
                |FLGREATEREQUAL;
logical_op: CONJUNC | DISJUNC;
adding_op: INTADD| FLOATADD| INTSUB| FLOATSUB;
multiplying_op: INTMUL
                | FLOATMUL
                | INTDIV
                | FLOATDIV
                |INTREMAINDER;
exp: exp1 relational_op exp1 | exp1;
exp1: exp1 logical_op exp2 | exp2;
exp2: exp2 adding_op exp3 | exp3;
exp3: exp3 multiplying_op exp4 | exp4;
exp4: NEG exp4 | exp5;
exp5: (INTSUB | FLOATSUB) exp5 | exp6;
exp6: exp7 index_operators | exp7;//exp6: exp6 index_operators| exp7;
index_operators: LSB exp RSB index_operators | LSB exp RSB;
exp7: ID LB call_stm_para_list RB operand | operand;

operand: constants
        //| variable
        | ID //(LSB exp RSB)* //(variable)
        |ID LB call_stm_para_list? RB // call_stm without ;
        | literal
        | LB exp RB;
constants: (INTSUB|FLOATSUB)? literal;

//program  : VAR COLON ID SEMI EOF ;
//program: BOOLEAN;

//ID: [a-z]+ ;

ASSIGN: '=' ;

WS : [ \t\r\n\f]+ -> skip ; // skip spaces, tabs, newlines

//PROGRAM COMMENT
COMMENT: '**' .*? '**' -> skip;  // how about appearing in string ?      ** * * **

//TOKENS SET

//Identifiers
ID: [a-z][a-zA-Z_0-9]*;
//Keywords
BODY: 'Body';
BREAK: 'Break';
CONTINUE: 'Continue';
DO: 'Do';
ELSE: 'Else';
ELSEIF: 'ElseIf';
ENDBODY: 'EndBody';
ENDIF: 'EndIf';
ENDFOR: 'EndFor';
ENDWHILE: 'EndWhile';
FOR: 'For';
FUNCTION: 'Function';
IF: 'If';
PARAMETER: 'Parameter';
RETURN: 'Return';
THEN: 'Then';
VAR: 'Var';
WHILE: 'While';
//TRUE: 'True';     //overlap with BOOLEAN
//FALSE: 'False';
ENDDO: 'EndDo';
//Operators
INTADD: '+';
FLOATADD: '+.';
INTSUB: '-';
FLOATSUB: '-.';
INTMUL: '*';
FLOATMUL: '*.';
INTDIV: '\\';
FLOATDIV: '\\.';
INTREMAINDER: '%';
NEG: '!';
CONJUNC: '&&';
DISJUNC: '||';
INTEQUAL: '==';
INTNOTEQUAL: '!=';
INTLESS: '<';
INTGREATER: '>';
INTLESSEQUAL: '<=';
INTGREATEREQUAL: '>=';
FLNOTEQUAL: '=/=';
FLLESS: '<.';
FLGREATER: '>.';
FLLESSEQUAL: '<=.';
FLGREATEREQUAL: '>=.';
//Separator
LB: '(';
RB: ')';
LSB: '[';   //left square bracket
RSB: ']';
COLON: ':' ;
DOT: '.';
COMMA: ',' ;
SEMI: ';' ;
LCB: '{' ; //left curly bracket
RCB: '}' ;
//Literals
//Otherwise, the literal is 0 ????    // 00000 ?
INTLIT:'0'
        | [1-9][0-9]*
        | ('0x'|'0X')[1-9A-F][0-9A-F]*
        | ('0o'|'0O')[1-7][0-7]*;

fragment EXPONENTPART: [Ee][+-]?[0-9]+;
fragment INTPART: ('0'+| [0-9]+);
fragment DECIMALPART: '.'[0-9]*;
FLOATLIT: INTPART (DECIMALPART| EXPONENTPART| DECIMALPART EXPONENTPART);
//boolean
BOOLEANLIT: 'True'|'False';
//escape sequence is a sequence of characters that they can be in a string if they have a \ before it.
//STRING: '\"' (('\"'|'\b'|'\f'|'\r'|'\n'|'\t'|'\''|'\\')*|~('\''))? '\"';
//fragment ESCAPESEQUECE: '\\b'|'\\f'|'\\r'|'\\n'|'\\t'|'\\\''|'\\\\';
fragment ESCAPESEQUECE: '\\'[bfrnt'\\];
//fragment STR_CHAR: ~[\b\f\r\n\t'\\"] | ESCAPESEQUECE;
fragment STR_CHARACTER: ESCAPESEQUECE |~('\n'|'"'|'\\'|'\'')| ('\'"');
STRING_LIT: '"' STR_CHARACTER* '"'
        {
            a = str(self.text)
            self.text = a[1:-1]
        };

literal: INTLIT | FLOATLIT | STRING_LIT | BOOLEANLIT | array;

/*
ARRAYINT: LB INTLIT RB      //how about having multi dimension ?
        | LB INTLIT (COMMA INTLIT)+ RB;
ARRAYFLOAT: LB FLOATLIT RB
        | LB FLOATLIT (COMMA FLOATLIT)+ RB;
ARRAYBOOLEN: LB BOOLEAN RB
        | LB BOOLEAN (COMMA BOOLEAN)+ RB;
ARRAYSTRING: LB STRING RB
        | LB STRING (COMMA STRING)+ RB;
ARRAY: ARRAYINT | ARRAYFLOAT | ARRAYBOOLEN | ARRAYSTRING;
*/
//ARRAY: LCB LITERAL RCB    //how about having multi dimension
  //      | LCB LITERAL (COMMA INTLIT)+ RCB;
//Generate testcase: khai bao 1 array ma trong do co nhieu kieu => error

//TYPE AND VALUE
//fragment ESC_ILLEGAL: '\\' ~[btnfr"'\\] | ~'\\' | '\''~'"';
fragment ESC_ILLEGAL: '\\' ~[btnfr"'\\] | '\''~'"';


//UNCLOSE_STRING: '"' STR_CHARACTER* ( '\\'[btnfr'"\\] | EOF )      //2 dong la khac nhau
UNCLOSE_STRING: '"' STR_CHARACTER* ( [\b\t\n\f\r'\\] | EOF )
	{
		a = str(self.text)
		possible = ['\b', '\t', '\n', '\f', '\r',  "'", '\\']
		if a[-1] in possible:
			raise UncloseString(a[1:-1])
		else:
			raise UncloseString(a[1:])
	}
	;
ILLEGAL_ESCAPE: '"' STR_CHARACTER* ESC_ILLEGAL
	{
		a = str(self.text)
		raise IllegalEscape(a[1:])
	}
	;
//UNTERMINATED_COMMENT: '**' ~'*' EOF
//    {
//        raise UnterminatedComment()
//    };
UNTERMINATED_COMMENT:'**' .*?;

ERROR_CHAR:.
    {
		raise ErrorToken(self.text)
	};