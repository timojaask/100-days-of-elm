import Html exposing (Html, div, text)
import Html.Attributes exposing (style)

-- TREES
type Tree a
  = Empty
  | Node a (Tree a) (Tree a)

empty : Tree a
empty =
  Empty

singleton : a -> Tree a
singleton v =
  Node v Empty Empty

insert : comparable -> Tree comparable -> Tree comparable
insert x tree =
  case tree of
    Empty ->
      singleton x
    Node y left right ->
      if x > y then
        Node y left (insert x right)
      else if x < y then
        Node y (insert x left) right
      else
        tree

fromList : List comparable -> Tree comparable
fromList list =
  List.foldl insert empty list

depth : Tree comparable -> Int
depth tree =
  case tree of
    Empty ->
      0
    Node x left right ->
      1 + max (depth left) (depth right)

map : (a -> b) -> Tree a -> Tree b
map f tree =
  case tree of
    Empty ->
      Empty
    Node v left right ->
      Node (f v) (map f left) (map f right)

sum : Tree number -> number
sum tree =
  case tree of
    Empty -> 0
    Node n left right ->
      n + (sum left) + (sum right)

sum2 : Tree number -> number
sum2=fold (+) 0

flatten2 : Tree a -> List a
flatten2=fold (::) []

isElement2 : a -> Tree a -> Bool
isElement2 v=fold (\a -> ((||) (a == v))) False

flatten : Tree a -> List a
flatten tree =
  case tree of
    Empty -> []
    Node v left right ->
      [v] ++ (flatten left) ++ (flatten right)

flattenNLR : Tree a -> List a
flattenNLR tree =
  case tree of
    Empty -> []
    Node v left right ->
      [v] ++ (flatten left) ++ (flatten right)

flattenLNR : Tree a -> List a
flattenLNR tree =
  case tree of
    Empty -> []
    Node v left right ->
      (flattenLNR left) ++ [v] ++ (flattenLNR right)

flattenLRN : Tree a -> List a
flattenLRN tree =
  case tree of
    Empty -> []
    Node v left right ->
      (flattenLRN left) ++ (flattenLRN right) ++ [v]

isElement : a -> Tree a -> Bool
isElement x tree =
  case tree of
    Empty -> False
    Node v left right ->
      if x == v then True
      else (isElement x left) || (isElement x right)

fold : (a -> b -> b) -> b -> Tree a -> b
fold func acc tree = List.foldl func acc (flatten tree)

fold2 : (a -> b -> b) -> b -> Tree a -> b
fold2 func acc tree =
  case tree of
    Empty -> acc
    Node v left right ->
      (func v (fold2 func (fold2 func acc right) left))

--- TESTING
someTree = fromList [2, 1, 3, 6]
flattened = flatten someTree
flattened2 = flatten2 someTree
foldFunc = \a -> (\b -> a + b)

traverseTestTree = 
  Node "F"
    (Node "B"
      (Node "A" Empty Empty)
      (Node "D"
        (Node "C" Empty Empty)
        (Node "E" Empty Empty)
      )
    )
    (Node "G"
      Empty
      (Node "I"
        (Node "H" Empty Empty)
        Empty
      )
    )

main =
  div [ style [ ("font-family", "monospace") ] ]
    [ display "depth someTree" (depth someTree)
    , display "sum someTree" (sum someTree)
    , display "sum2 someTree" (sum2 someTree)
    , display "flattened" flattened 
    , display "flattened2" flattened2
    , display "contains 1" (isElement 1 someTree)
    , display "contains 4" (isElement 4 someTree)
    , display "contains 6" (isElement 6 someTree)
    , display "contains2 1" (isElement2 1 someTree)
    , display "contains2 4" (isElement2 4 someTree)
    , display "contains2 6" (isElement2 6 someTree)
    , display "fold" (fold foldFunc 0 someTree)
    , display "fold2" (fold2 foldFunc 0 someTree)
    , display "Pre-order (NLR)" (flattenNLR traverseTestTree)
    , display "In-order (LNR)" (flattenLNR traverseTestTree)
    , display "Post-order (LRN)" (flattenLRN traverseTestTree)
    ]


display : String -> a -> Html msg
display name value =
  div [] [ text (name ++ " ==> " ++ toString value) ]