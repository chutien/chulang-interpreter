{-# LANGUAGE FlexibleInstances, OverlappingInstances #-}
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- | Pretty-printer for PrintGrammar.
--   Generated by the BNF converter.

module PrintGrammar where

import AbsGrammar
import Data.Char

-- | The top-level printing method.

printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : ts@(p:_) | closingOrPunctuation p -> showString t . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else ' ':s)

  closingOrPunctuation :: String -> Bool
  closingOrPunctuation [c] = c `elem` closerOrPunct
  closingOrPunctuation _   = False

  closerOrPunct :: String
  closerOrPunct = ")],;"

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- | The printer class does the job.

class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j < i then parenth else id

instance Print Integer where
  prt _ x = doc (shows x)

instance Print Double where
  prt _ x = doc (shows x)

instance Print Ident where
  prt _ (Ident i) = doc (showString i)
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print LIdent where
  prt _ (LIdent i) = doc (showString i)
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print UIdent where
  prt _ (UIdent i) = doc (showString i)
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [Ident] where
  prt = prtList

instance Print [LIdent] where
  prt = prtList

instance Print [UIdent] where
  prt = prtList

instance Print Program where
  prt i e = case e of
    Prog instrs -> prPrec i 0 (concatD [prt 0 instrs])

instance Print Instr where
  prt i e = case e of
    IDecl decl -> prPrec i 0 (concatD [doc (showString "let"), prt 0 decl])
    IType typedef -> prPrec i 0 (concatD [doc (showString "type"), prt 0 typedef])
    IExpr expr -> prPrec i 0 (concatD [prt 0 expr])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ";"), prt 0 xs]

instance Print [Instr] where
  prt = prtList

instance Print Decl where
  prt i e = case e of
    Decl lident args expr type_ -> prPrec i 0 (concatD [prt 0 lident, prt 0 args, doc (showString "="), prt 0 expr, doc (showString ":"), prt 0 type_])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [Decl] where
  prt = prtList

instance Print TypeDef where
  prt i e = case e of
    TypeDef uident lidents constrs -> prPrec i 0 (concatD [prt 0 uident, prt 0 lidents, doc (showString "="), prt 0 constrs])

instance Print Constr where
  prt i e = case e of
    Constr uident types -> prPrec i 0 (concatD [prt 0 uident, prt 0 types])
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString "|"), prt 0 xs]

instance Print [Constr] where
  prt = prtList

instance Print Type where
  prt i e = case e of
    TArr type_1 type_2 -> prPrec i 0 (concatD [prt 2 type_1, doc (showString "->"), prt 0 type_2])
    TVar lident -> prPrec i 2 (concatD [prt 0 lident])
    TType constr -> prPrec i 2 (concatD [prt 0 constr])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [Type] where
  prt = prtList

instance Print Arg where
  prt i e = case e of
    Arg lident type_ -> prPrec i 0 (concatD [prt 0 lident, doc (showString ":"), prt 0 type_])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [Arg] where
  prt = prtList

instance Print Pattern where
  prt i e = case e of
    PConstr uident patterns -> prPrec i 0 (concatD [prt 0 uident, prt 0 patterns])
    PVar lident -> prPrec i 2 (concatD [prt 0 lident])
    PInt n -> prPrec i 2 (concatD [prt 0 n])
    PBool boolean -> prPrec i 2 (concatD [prt 0 boolean])
    PWildcard -> prPrec i 2 (concatD [doc (showString "_")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [Pattern] where
  prt = prtList

instance Print Matching where
  prt i e = case e of
    Matching pattern expr -> prPrec i 0 (concatD [prt 0 pattern, doc (showString "->"), prt 0 expr])
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString "|"), prt 0 xs]

instance Print [Matching] where
  prt = prtList

instance Print Boolean where
  prt i e = case e of
    BTrue -> prPrec i 0 (concatD [doc (showString "True")])
    BFalse -> prPrec i 0 (concatD [doc (showString "False")])

instance Print Expr where
  prt i e = case e of
    ELambda arg args expr -> prPrec i 0 (concatD [doc (showString "\\"), prt 0 arg, prt 0 args, doc (showString "."), prt 0 expr])
    ELet decls expr -> prPrec i 0 (concatD [doc (showString "let"), prt 0 decls, doc (showString "in"), prt 0 expr])
    EIfte expr1 expr2 expr3 -> prPrec i 0 (concatD [doc (showString "if"), prt 0 expr1, doc (showString "then"), prt 0 expr2, doc (showString "else"), prt 0 expr3])
    EMatch expr matchings -> prPrec i 0 (concatD [doc (showString "match"), prt 0 expr, doc (showString "with"), prt 0 matchings])
    EOr expr1 expr2 -> prPrec i 2 (concatD [prt 3 expr1, doc (showString "||"), prt 2 expr2])
    EAnd expr1 expr2 -> prPrec i 3 (concatD [prt 4 expr1, doc (showString "&&"), prt 3 expr2])
    EEq expr1 expr2 -> prPrec i 4 (concatD [prt 5 expr1, doc (showString "=="), prt 5 expr2])
    ENeq expr1 expr2 -> prPrec i 4 (concatD [prt 5 expr1, doc (showString "!="), prt 5 expr2])
    ELeq expr1 expr2 -> prPrec i 4 (concatD [prt 5 expr1, doc (showString "<="), prt 5 expr2])
    ELes expr1 expr2 -> prPrec i 4 (concatD [prt 5 expr1, doc (showString "<"), prt 5 expr2])
    EGre expr1 expr2 -> prPrec i 4 (concatD [prt 5 expr1, doc (showString ">"), prt 5 expr2])
    EGeq expr1 expr2 -> prPrec i 4 (concatD [prt 5 expr1, doc (showString ">="), prt 5 expr2])
    EAdd expr1 expr2 -> prPrec i 6 (concatD [prt 6 expr1, doc (showString "+"), prt 7 expr2])
    ESub expr1 expr2 -> prPrec i 6 (concatD [prt 6 expr1, doc (showString "-"), prt 7 expr2])
    EMul expr1 expr2 -> prPrec i 7 (concatD [prt 7 expr1, doc (showString "*"), prt 8 expr2])
    EDiv expr1 expr2 -> prPrec i 7 (concatD [prt 7 expr1, doc (showString "/"), prt 8 expr2])
    EApply expr1 expr2 -> prPrec i 10 (concatD [prt 10 expr1, prt 11 expr2])
    EInt n -> prPrec i 11 (concatD [prt 0 n])
    EBool boolean -> prPrec i 11 (concatD [prt 0 boolean])
    EVar lident -> prPrec i 11 (concatD [prt 0 lident])
    EConstr uident -> prPrec i 11 (concatD [prt 0 uident])
    EData uident exprs -> prPrec i 11 (concatD [prt 0 uident, prt 11 exprs])
  prtList 11 [] = concatD []
  prtList 11 (x:xs) = concatD [prt 11 x, prt 11 xs]

