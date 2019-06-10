

module AbsGrammar where

-- Haskell module generated by the BNF converter




newtype Ident = Ident String deriving (Eq, Ord, Show, Read)
newtype LIdent = LIdent String deriving (Eq, Ord, Show, Read)
newtype UIdent = UIdent String deriving (Eq, Ord, Show, Read)
data Program = Prog [Instr]
  deriving (Eq, Ord, Show, Read)

data Instr = IDecl Decl | IType TypeDef | IExpr Expr
  deriving (Eq, Ord, Show, Read)

data Decl = Decl LIdent [Arg] Expr Type
  deriving (Eq, Ord, Show, Read)

data TypeDef = TypeDef UIdent [LIdent] [Constr]
  deriving (Eq, Ord, Show, Read)

data Constr = Constr UIdent [Type]
  deriving (Eq, Ord, Show, Read)

data Type = TArr Type Type | TVar LIdent | TType Constr
  deriving (Eq, Ord, Show, Read)

data Arg = Arg LIdent Type
  deriving (Eq, Ord, Show, Read)

data Pattern
    = PConstr UIdent [Pattern]
    | PVar LIdent
    | PInt Integer
    | PBool Boolean
    | PWildcard
  deriving (Eq, Ord, Show, Read)

data Matching = Matching Pattern Expr
  deriving (Eq, Ord, Show, Read)

data Boolean = BTrue | BFalse
  deriving (Eq, Ord, Show, Read)

data Expr
    = ELambda Arg [Arg] Expr
    | ELet [Decl] Expr
    | EIfte Expr Expr Expr
    | EMatch Expr [Matching]
    | EOr Expr Expr
    | EAnd Expr Expr
    | EEq Expr Expr
    | ENeq Expr Expr
    | ELeq Expr Expr
    | ELes Expr Expr
    | EGre Expr Expr
    | EGeq Expr Expr
    | EAdd Expr Expr
    | ESub Expr Expr
    | EMul Expr Expr
    | EDiv Expr Expr
    | EApply Expr Expr
    | EInt Integer
    | EBool Boolean
    | EVar LIdent
    | EConstr UIdent
    | EData UIdent [Expr]
  deriving (Eq, Ord, Show, Read)

