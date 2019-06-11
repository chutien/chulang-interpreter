-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module ParGrammar where
import AbsGrammar
import LexGrammar
import ErrM

}

%name pProgram Program
-- no lexer declaration
%monad { Err } { thenM } { returnM }
%tokentype {Token}
%token
  '!=' { PT _ (TS _ 1) }
  '&&' { PT _ (TS _ 2) }
  '(' { PT _ (TS _ 3) }
  ')' { PT _ (TS _ 4) }
  '*' { PT _ (TS _ 5) }
  '+' { PT _ (TS _ 6) }
  ',' { PT _ (TS _ 7) }
  '-' { PT _ (TS _ 8) }
  '->' { PT _ (TS _ 9) }
  '.' { PT _ (TS _ 10) }
  '/' { PT _ (TS _ 11) }
  ';' { PT _ (TS _ 12) }
  '<' { PT _ (TS _ 13) }
  '<=' { PT _ (TS _ 14) }
  '=' { PT _ (TS _ 15) }
  '==' { PT _ (TS _ 16) }
  '>' { PT _ (TS _ 17) }
  '>=' { PT _ (TS _ 18) }
  'False' { PT _ (TS _ 19) }
  'True' { PT _ (TS _ 20) }
  '\\' { PT _ (TS _ 21) }
  '_' { PT _ (TS _ 22) }
  'else' { PT _ (TS _ 23) }
  'if' { PT _ (TS _ 24) }
  'in' { PT _ (TS _ 25) }
  'let' { PT _ (TS _ 26) }
  'match' { PT _ (TS _ 27) }
  'then' { PT _ (TS _ 28) }
  'type' { PT _ (TS _ 29) }
  'with' { PT _ (TS _ 30) }
  '|' { PT _ (TS _ 31) }
  '||' { PT _ (TS _ 32) }

L_ident  { PT _ (TV $$) }
L_integ  { PT _ (TI $$) }
L_LIdent { PT _ (T_LIdent $$) }
L_UIdent { PT _ (T_UIdent $$) }


%%

Ident   :: { Ident }   : L_ident  { Ident $1 }
Integer :: { Integer } : L_integ  { (read ( $1)) :: Integer }
LIdent    :: { LIdent} : L_LIdent { LIdent ($1)}
UIdent    :: { UIdent} : L_UIdent { UIdent ($1)}

ListIdent :: { [Ident] }
ListIdent : {- empty -} { [] } | Ident ListIdent { (:) $1 $2 }
ListLIdent :: { [LIdent] }
ListLIdent : {- empty -} { [] } | LIdent ListLIdent { (:) $1 $2 }
ListUIdent :: { [UIdent] }
ListUIdent : {- empty -} { [] } | UIdent ListUIdent { (:) $1 $2 }
Program :: { Program }
Program : ListInstr { AbsGrammar.Prog (reverse $1) }
Instr :: { Instr }
Instr : 'let' Decl { AbsGrammar.IDecl $2 }
      | 'type' TypeDef { AbsGrammar.IType $2 }
      | Expr { AbsGrammar.IExpr $1 }
ListInstr :: { [Instr] }
ListInstr : {- empty -} { [] }
          | ListInstr Instr ';' { flip (:) $1 $2 }
Decl :: { Decl }
Decl : LIdent '=' Expr { AbsGrammar.DVar $1 $3 }
     | LIdent ListArg '=' Expr { AbsGrammar.DFunc $1 $2 $4 }
ListDecl :: { [Decl] }
ListDecl : {- empty -} { [] }
         | Decl { (:[]) $1 }
         | Decl ',' ListDecl { (:) $1 $3 }
TypeDef :: { TypeDef }
TypeDef : UIdent ListLIdent '=' ListConstr { AbsGrammar.TypeDef $1 $2 $4 }
Constr :: { Constr }
Constr : UIdent ListType { AbsGrammar.Constr $1 (reverse $2) }
ListConstr :: { [Constr] }
ListConstr : Constr { (:[]) $1 }
           | Constr '|' ListConstr { (:) $1 $3 }
Type :: { Type }
Type : Type2 '->' Type { AbsGrammar.TArr $1 $3 } | Type1 { $1 }
Type2 :: { Type }
Type2 : LIdent { AbsGrammar.TVar $1 }
      | Constr { AbsGrammar.TConstr $1 }
      | '(' Type ')' { $2 }
Type1 :: { Type }
Type1 : Type2 { $1 }
ListType :: { [Type] }
ListType : {- empty -} { [] } | ListType Type { flip (:) $1 $2 }
Arg :: { Arg }
Arg : LIdent { AbsGrammar.Arg $1 }
ListArg :: { [Arg] }
ListArg : Arg { (:[]) $1 } | Arg ListArg { (:) $1 $2 }
Pattern :: { Pattern }
Pattern : UIdent ListPattern { AbsGrammar.PConstr $1 (reverse $2) }
        | Pattern1 { $1 }
Pattern2 :: { Pattern }
Pattern2 : LIdent { AbsGrammar.PVar $1 }
         | Integer { AbsGrammar.PInt $1 }
         | Boolean { AbsGrammar.PBool $1 }
         | '_' { AbsGrammar.PWildcard }
         | '(' Pattern ')' { $2 }
Pattern1 :: { Pattern }
Pattern1 : Pattern2 { $1 }
ListPattern :: { [Pattern] }
ListPattern : {- empty -} { [] }
            | ListPattern Pattern { flip (:) $1 $2 }
Matching :: { Matching }
Matching : Pattern '->' Expr { AbsGrammar.Matching $1 $3 }
ListMatching :: { [Matching] }
ListMatching : Matching { (:[]) $1 }
             | Matching '|' ListMatching { (:) $1 $3 }
Boolean :: { Boolean }
Boolean : 'True' { AbsGrammar.BTrue }
        | 'False' { AbsGrammar.BFalse }
Expr :: { Expr }
Expr : '\\' ListArg '.' Expr { AbsGrammar.ELambda $2 $4 }
     | 'let' ListDecl 'in' Expr { AbsGrammar.ELet $2 $4 }
     | 'if' Expr 'then' Expr 'else' Expr { AbsGrammar.EIfte $2 $4 $6 }
     | 'match' Expr 'with' ListMatching { AbsGrammar.EMatch $2 $4 }
     | Expr1 { $1 }
Expr2 :: { Expr }
Expr2 : Expr3 '||' Expr2 { AbsGrammar.EOr $1 $3 } | Expr3 { $1 }
Expr3 :: { Expr }
Expr3 : Expr4 '&&' Expr3 { AbsGrammar.EAnd $1 $3 } | Expr4 { $1 }
Expr4 :: { Expr }
Expr4 : Expr5 '==' Expr5 { AbsGrammar.EEq $1 $3 }
      | Expr5 '!=' Expr5 { AbsGrammar.ENeq $1 $3 }
      | Expr5 '<=' Expr5 { AbsGrammar.ELeq $1 $3 }
      | Expr5 '<' Expr5 { AbsGrammar.ELes $1 $3 }
      | Expr5 '>' Expr5 { AbsGrammar.EGre $1 $3 }
      | Expr5 '>=' Expr5 { AbsGrammar.EGeq $1 $3 }
      | Expr5 { $1 }
Expr6 :: { Expr }
Expr6 : Expr6 '+' Expr7 { AbsGrammar.EAdd $1 $3 }
      | Expr6 '-' Expr7 { AbsGrammar.ESub $1 $3 }
      | Expr7 { $1 }
Expr7 :: { Expr }
Expr7 : Expr7 '*' Expr8 { AbsGrammar.EMul $1 $3 }
      | Expr7 '/' Expr8 { AbsGrammar.EDiv $1 $3 }
      | Expr8 { $1 }
Expr10 :: { Expr }
Expr10 : Expr10 Expr11 { AbsGrammar.EApply $1 $2 } | Expr11 { $1 }
Expr11 :: { Expr }
Expr11 : Integer { AbsGrammar.EInt $1 }
       | Boolean { AbsGrammar.EBool $1 }
       | LIdent { AbsGrammar.EVar $1 }
       | UIdent { AbsGrammar.EConstr $1 }
       | '(' Expr ')' { $2 }
Expr1 :: { Expr }
Expr1 : Expr2 { $1 }
Expr5 :: { Expr }
Expr5 : Expr6 { $1 }
Expr8 :: { Expr }
Expr8 : Expr9 { $1 }
Expr9 :: { Expr }
Expr9 : Expr10 { $1 }
ListExpr11 :: { [Expr] }
ListExpr11 : {- empty -} { [] }
           | ListExpr11 Expr11 { flip (:) $1 $2 }
{

returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++ 
  case ts of
    [] -> []
    [Err _] -> " due to lexer error"
    t:_ -> " before `" ++ id(prToken t) ++ "'"

myLexer = tokens
}

