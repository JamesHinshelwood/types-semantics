module Exercise1 where

{- Instruction: Fill in all the missing definitions. In most cases,
the type signature enforces that there should be a single unique
definition that fits. 

If you have any questions, don't hesitate to email me or ask in class.
-}


---------------------
------ Prelude ------
---------------------

data Bool : Set where
  True : Bool
  False : Bool

data Nat : Set where
  Zero : Nat 
  Succ : Nat → Nat

{-# BUILTIN NATURAL Nat #-}

_+_ : Nat → Nat → Nat
Zero + m = m
Succ k + m = Succ (k + m)

_*_ : Nat → Nat → Nat
Zero * n = Zero
(Succ k) * n = n + (k * n)

data List (a : Set) : Set where
  Nil : List a
  Cons : a → List a → List a

data Vec (a : Set) : Nat → Set where
  Nil : Vec a 0
  Cons : {n : Nat} → (x : a) → (xs : Vec a n) → Vec a (Succ n)

head : {a : Set} {n : Nat}→ Vec a (Succ n) → a
head (Cons x xs) = x

append : {a : Set} {n m : Nat} → Vec a n → Vec a m → Vec a (n + m)
append Nil ys = ys
append (Cons x xs) ys = Cons x (append xs ys)

data _==_ {a : Set} (x : a) : a → Set where
  Refl : x == x

cong : {a b : Set} {x y : a} → (f : a → b) → x == y → f x == f y
cong f Refl = Refl

data Unit : Set where
  unit : Unit

data Empty : Set where

magic : {a : Set} → Empty → a
magic ()

data Pair (a b : Set) : Set where
  _,_ : a → b → Pair a b

data Fin : Nat → Set where
  Fz : ∀{n} → Fin (Succ n)
  Fs : ∀{n} → Fin n → Fin (Succ n)

data Maybe (a : Set) : Set where
  Just : a → Maybe a
  Nothing : Maybe a

-- Helper functions - Allowed or not?
zip : {a b : Set} {n : Nat} → Vec a n → Vec b n → Vec (Pair a b) n
zip Nil ys = Nil
zip (Cons x xs) (Cons y ys) = Cons (x , y) (zip xs ys)

zipWith : {a b c : Set} {n : Nat} → (a → b → c) → Vec a n → Vec b n → Vec c n
zipWith f Nil ys = Nil
zipWith f (Cons x xs) (Cons y ys) = Cons (f x y) (zipWith f xs ys)

replicate : {a : Set} → (n : Nat) -> a -> Vec a n
replicate Zero     _ = Nil
replicate (Succ n) x = Cons x (replicate n x)

tail : {a : Set} {n : Nat} -> Vec a (Succ n) -> Vec a n
tail (Cons x xs) = xs

----------------------
----- Exercise 1 -----
----------------------

--Show that the Vec a n type is applicative

pure : {n : Nat} {a : Set} → a → Vec a n
pure {Zero}   _ = Nil
pure {Succ n} x = Cons x (pure x)

_<*>_ : {a b : Set} {n : Nat} → Vec (a → b) n → Vec a n → Vec b n
Nil <*> x = Nil
Cons f fs <*> Cons x xs = Cons (f x) (fs <*> xs)

vmap : {a b : Set} {n : Nat} → (a → b) → Vec a n → Vec b n
vmap f xs = pure f <*> xs -- Equivalent to Cons (f x) (vmap f xs)

-- 3 / 3 Correct: 1 point

----------------------
----- Exercise 2 -----
----------------------

-- Using the Vector definitions, define a type for matrices;
-- matrix addition; the identity matrix; and matrix transposition.

Matrix : Set → Nat → Nat → Set
Matrix a n m = Vec (Vec a n) m 

-- Define matrix addition
madd : {n m : Nat} → Matrix Nat m n → Matrix Nat m n → Matrix Nat m n
madd Nil yss = yss
madd (Cons xs xss) (Cons ys yss) = let ar = zipWith (_+_) xs ys  -- Additions are done row by row
                                   in Cons ar (madd xss yss)


-- Equivalent to (pure (\xs ys -> (pure _+_ <*> xs) <*> ys)  <*> xss) <*> yss

foo : Matrix Nat 10 10
foo = pure (pure 0)

-- Define the identity matrix
idMatrix : {n : Nat} → Matrix Nat n n
idMatrix {Zero}   = Nil
idMatrix {Succ n} = let fr = Cons (Succ Zero) (replicate n Zero) -- The first row starts with a one and has
                    in Cons fr (vmap (Cons Zero) idMatrix)       -- only zeroes after that, the length is
                                                                 -- (Succ n). The other part is that the
                                                                 -- idMatrix of one order lower is appended
                                                                 -- with zeroes at the front of each row.

-- Equivalent to (but less elegant than) Cons (Cons 1 (pure 0)) (vmap (Cons 0) idMatrix)

-- Define matrix transposition
transpose : {n m : Nat} {a : Set} → Matrix a m n → Matrix a n m
transpose Nil                    = pure Nil
transpose (Cons Nil xss)         = Nil -- Case is missing from the solution, do i subtract points for this?
transpose (Cons (Cons x xs) xss) = let fr = Cons x (vmap head xss)       -- New first row
                                   in Cons fr (transpose (Cons xs (vmap tail xss))) 

-- Equivalent to (but less elegant than) (pure Cons <*> xs) <*> transpose xss

-- 3 / 3 Correct: 1 point

----------------------
----- Exercise 3 -----
----------------------

-- Define a few functions manipulating finite types.

-- The result of "plan {n}" should be a vector of length n storing all
-- the inhabitants of Fin n in increasing order.
plan : {n : Nat} → Vec (Fin n) n
plan {Zero}   = Nil
plan {Succ n} = Cons Fz ( vmap Fs (plan))

-- Define a forgetful map, mapping Fin to Nat
forget : {n : Nat} → Fin n → Nat
forget (Fz {n}) = n           -- Should be Zero
forget (Fs x)   = (forget x)  -- Should be Succ (forget x)

-- There are several ways to embed Fin n in Fin (Succ n).  Try to come
-- up with one that satisfies the correctness property below (and
-- prove that it does).
embed : {n : Nat} → Fin n → Fin (Succ n)
embed (Fz {n}) = Fs Fz        -- Should be Fz
embed (Fs x)   = Fs (embed x)

correct : {n : Nat} → (i : Fin n) → forget i == forget (embed i)
correct {Zero} ()          -- Cas is missing from the solution, but it is unreachable.
correct {Succ n} Fz = Refl
correct (Fs i) = correct i -- Should be cong Succ (correct i)

-- 1 / 4 Correct: 0.25 Points
-- Ex 3.3 correct for 50%: 1/8 point
-- Ex 4.4 correct for 50%: 1/8 point
--
-- 1/4 + 1/8 + 1/8 = 2/4 = 0.5 Points total


----------------------
----- Exercise 4 -----
----------------------

-- Given the following data type definition:

data Compare : Nat → Nat → Set where
  LessThan    : ∀ {n} k → Compare  n (n + Succ k)
  Equal       : ∀ {n}   → Compare  n n
  GreaterThan : ∀ {n} k → Compare (n + Succ k) n

-- Show that there is a 'covering function'
cmp : (n m : Nat) → Compare n m 
cmp Zero Zero         = Equal
cmp Zero (Succ y)     = LessThan y
cmp (Succ x) Zero     = GreaterThan x
cmp (Succ x) (Succ y) with cmp x y
cmp (Succ n) (Succ .(n + Succ k)) | LessThan k    = LessThan k
cmp (Succ y) (Succ .y)            | Equal         = Equal
cmp (Succ .(y + Succ k)) (Succ y) | GreaterThan k = GreaterThan k

-- Use the cmp function you defined above to define the absolute
-- difference between two natural numbers.
difference : (n m : Nat) → Nat
difference Zero     y = y           -- Missing from the solution
difference (Succ x) y with cmp x y
difference (Succ n) .(n + Succ k) | LessThan k    = k -- Should be Succ k
difference (Succ y) .y            | Equal         = Zero
difference (Succ .(y + Succ k)) y | GreaterThan k = k -- Should be Succ k

-- 1 / 2 Correct: 0.5 Points
-- Ex 4.2 correct for 33%: 1/6 point
--
-- 1/2 + 1/6 = 0.67 points total

----------------------
----- Exercise 5 -----
----------------------

-- Prove the following equalities.  You may want to define auxiliary
-- lemmas or use the notation intoduced in the lectures.

sym : {a : Set} {x y : a} → x == y → y == x
sym Refl = Refl

trans : {a : Set} {x y z : a} → x == y → y == z → x == z
trans Refl Refl = Refl

plusZero : (n : Nat) → (n + Zero) == n
plusZero Zero     = Refl
plusZero (Succ x) = cong Succ (plusZero x)

plusSucc : (n m : Nat) → Succ (n + m) == (n + Succ m)
plusSucc Zero y     = Refl
plusSucc (Succ x) y = cong Succ (plusSucc x y)

plusCommutes : (n m : Nat) → (n + m) == (m + n)
plusCommutes Zero     m = sym (plusZero m)
plusCommutes (Succ n) m = let ih = plusCommutes n m
                          in  trans (cong Succ ih) (plusSucc m n)

distributivity : (n m k : Nat) → (n * (m + k)) == ((n * m) + (n * k))
distributivity Zero     m k = Refl
distributivity (Succ n) m k = let ih = distributivity n m k
                              in {!!}

-- 3 / 4 correct: 0.75 Points

----------------------
----- Exercise 6 -----
----------------------

-- Prove that the sublist relation defined below is transitive and reflexive.

data SubList {a : Set} : List a → List a → Set where
  Base : SubList Nil Nil
  Keep : ∀ {x xs ys} → SubList xs ys → SubList (Cons x xs) (Cons x ys)
  Drop : ∀ {y zs ys} → SubList zs ys → SubList zs (Cons y ys)

SubListRefl : {a : Set} {xs : List a} → SubList xs xs
SubListRefl {xs = Nil}       = Base
SubListRefl {xs = Cons x xs} = Keep SubListRefl

SubListTrans : {a : Set} {xs ys zs : List a} → SubList xs ys → SubList ys zs → SubList xs zs
SubListTrans Base      ys = ys
SubListTrans (Keep xs) ys = let ih = SubListTrans in {!!}
SubListTrans (Drop xs) ys = let ih = SubListTrans in {!!}
-- SubListTrans p1 p2 = {!inductie over p1/p2!}

SubListAntiSym : {a : Set} {xs ys : List a} →  SubList xs ys → SubList ys xs → xs == ys
SubListAntiSym Base      ys = Refl
SubListAntiSym (Keep xs) ys = {!!}
SubListAntiSym (Drop xs) ys = {!!}
-- SubListAntiSym = {!lastiger!}

-- 1 / 3 Correct: 0.33 points

----------------------
----- Exercise 7 -----
----------------------

-- Define the constructors of a data type 
data LEQ : Nat → Nat → Set where
  leq-zero : {  n : Nat} → LEQ Zero n
  leq-succ : {m n : Nat} → LEQ m n → LEQ (Succ m) (Succ n)

-- (Alternative correct definitions exist - this one is the easiest to
-- work with for the rest of this exercise)

leqRefl : (n : Nat) → LEQ n n
leqRefl  Zero    = leq-zero
leqRefl (Succ n) = leq-succ (leqRefl n)

leqTrans : {n m k : Nat} → LEQ n m → LEQ m k → LEQ n k
leqTrans  leq-zero x               = leq-zero
leqTrans (leq-succ x) (leq-succ y) = leq-succ (leqTrans x y)

leqAntiSym : {n m : Nat} → LEQ n m → LEQ m n → n == m
leqAntiSym leq-zero leq-zero = Refl
leqAntiSym (leq-succ n) (leq-succ m) = let ih = leqAntiSym
                                       in cong Succ (ih n m)

-- Given the following function:
_<=_ : Nat → Nat → Bool
Zero   <= y      = True
Succ x <= Zero   = False
Succ x <= Succ y = x <= y

-- Now show that this function behaves as the LEQ data type

leq<= : {n m : Nat} → LEQ n m → (n <= m) == True
leq<= leq-zero     = Refl
leq<= (leq-succ i) = leq<= i

<=leq : (n m : Nat) → (n <= m) == True → LEQ n m
<=leq Zero m x = leq-zero
<=leq (Succ n) Zero x = {!!}
<=leq (Succ n) (Succ m) x = leq-succ (<=leq n m x)

-- 5 / 6 Correct: 0.83 points


----------------------
----- Exercise 7 -----
----------------------

-- We can define negation as follows
Not : Set → Set
Not P = P → Empty

-- Agda's logic is *constructive*, meaning some properties you may be
-- familiar with from classical logic do not hold.

notNotP : {P : Set} → P → Not (Not P)
notNotP p = λ z → z p  -- ???

-- The reverse does not hold: Not (Not P) does not imply P

-- Similarly, P or Not P doesn't hold for all statements P, but we can
-- prove the statement below. It's an amusing brainteaser.

data Or (a b : Set) : Set where
  Inl : a → Or a b
  Inr : b → Or a b

orCase : {a b c : Set} → (a → c) → (b → c) → Or a b → c
orCase f g (Inl x) = f x
orCase f g (Inr x) = g x

notNotExcludedMiddle : {P : Set} → Not (Not (Or P (Not P)))
notNotExcludedMiddle = λ {P} z → z (Inr (λ x → z (Inl x)))  --- ???

-- There are various different axioms that can be added to a
-- constructive logic to get the more familiar classical logic.


doubleNegation = {P : Set} → Not (Not P) → P
excludedMiddle = {P : Set} → Or P (Not P)
impliesToOr = {P Q : Set} → (P → Q) → Or (Not P) Q
-- Let's try to prove these three statements are equivalent...  you
--  may find it helpful to replace the 'doubleNegation' and others
--  with their definition in the type signatures below.
--  This is not always easy...


step1 : doubleNegation → excludedMiddle
step1 dn = λ {P} → dn (λ z → z (Inr (λ x → z (Inl x))))  --- ?

step2 : excludedMiddle → impliesToOr
step2 = {!!}

step3 : impliesToOr → doubleNegation
step3  ito {P} h = {!!}

-- HARDER: show that these are equivalent to Pierces law:
piercesLaw = {P Q : Set} → ((P → Q) → P) → P

-- 3 / 6 correct: .50 points

----------------------
----- Exercise 9 -----
----------------------

-- Given the following data type for expressions

data Expr : Set where
  Add : Expr → Expr → Expr
  Val : Nat → Expr

-- We can write a simple evaluator as follows
eval : Expr → Nat
eval (Add l r) = eval l + eval r
eval (Val x) = x

-- We can also compile such expressions to stack machine code
data Cmd : Set where
  -- stop execution and return the current stack
  HALT : Cmd 
  -- push a new number on the stack
  PUSH : Nat → Cmd → Cmd 
  -- replace the top two elements of the stack with their sum
  ADD : Cmd → Cmd

Stack : Set
Stack = List Nat

-- Complete the following definition, executing a list of instructions
-- Note: there 'obvious' definition is not total -- how can you fix
-- things so that it is?
exec : Cmd → Stack → Maybe Stack
exec HALT xs                      = Just xs
exec (PUSH x c) xs                = exec c (Cons x xs)
exec (ADD c) Nil                  = Nothing
exec (ADD c) (Cons x Nil)         = Nothing
exec (ADD c) (Cons x (Cons y xs)) = exec c (Cons (x + y) xs)

infixr 20 _++_
_++_ : Cmd -> Cmd -> Cmd
HALT      ++ ds = ds
PUSH x cs ++ ds = PUSH x (cs ++ ds)
ADD cs    ++ ds = ADD (cs ++ ds)

-- Define a compiler from expresions to instructions

compile : Expr → Cmd
compile (Add x y) = (compile x) ++ (compile y) ++ ADD HALT
compile (Val x) = PUSH x HALT

-- And prove your compiler correct
--correctness : (e : Expr) (s : Stack) → Cons (eval e) s == exec (compile e) s
--correctness e = {!!}

--BONUS exercises: extend the language with new constructs for let
--bindings, variables, new operators, mutable references, assignment,
--functions, ...

-- 2 / 3 correct: 0.67 Points


-- SUMMARY
-- Exercise 1:  1.00 point
-- Exercise 2:  1.00 points
-- Exercise 3:  0.50 points
-- Exercise 4:  0.67 points
-- Exercise 5:  0.75 points
-- Exercise 6:  0.33 points
-- Exercise 7:  0.83 points
-- Exercise 8:  0.50 points
-- Exercise 9:  0.67 points
--
-- Base points: 1.00 points
--------------------------- +
--              7.25 points
