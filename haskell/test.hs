import Data.List
-- {-# LANGUAGE FlexibleInstances #-}
-- infiniteSequenceFromNext :: (a -> a) -> a -> [a]
-- infiniteSequenceFromNext f start = seq
--     where
--     seq = start : map f seq
--
-- class Idk a where
--     idk :: a -> String
--
-- instance Idk Integer where
--     idk x = show x
--
-- instance Idk [a] where
--     idk s = show $ length s

import Data.Function
data Person = Person {  name :: String
                     ,  age :: Int
                     } deriving (Show)

data BinaryTree a = Empty | Node a (BinaryTree a) (BinaryTree a) deriving(Eq)

indent :: Int -> String
indent x = replicate (2*x) ' '

stringifyBinaryTree :: (Show a) => Int -> BinaryTree a -> String
stringifyBinaryTree indentLvl Empty = ""
stringifyBinaryTree indentLvl (Node x left right) = (stringifyBinaryTree (indentLvl + 1) right) ++ (indent indentLvl) ++ (show x) ++ "\n"  ++ (stringifyBinaryTree (indentLvl + 1) left)

instance (Show b) => Show (BinaryTree b) where
    show bt = stringifyBinaryTree 0 bt

instance Functor BinaryTree where
    fmap f Empty = Empty
    fmap f (Node x left right) = Node (f x) (fmap f left) (fmap f right)

nodeFromElement :: a -> BinaryTree a
nodeFromElement x = Node x Empty Empty

-- treeInsert :: (Ord a) => a -> BinaryTree a -> BinaryTree a
-- treeInsert x (Empty) = nodeFromElement x
-- treeInsert x (Node y left right) | x == y = Node x left right
--                                  | x < y  = Node y (treeInsert x left) right
--                                  | x > y  = Node y left $ treeInsert x right
treeInsert :: (Ord a) => BinaryTree a -> a -> BinaryTree a
treeInsert (Empty) x = nodeFromElement x
treeInsert (Node y left right) x | x == y = Node x left right
                                 | x < y  = Node y (treeInsert left x) right
                                 | x > y  = Node y left $ treeInsert right x

treeFromList :: (Ord a) => [a] -> BinaryTree a
treeFromList = foldl' treeInsert Empty

mySum = fix (\f -> \x -> case x of
                            [] -> 0
                            (y:ys) -> y + f ys)

sortedInsert :: (Ord a) => [a] -> a -> [a]
sortedInsert [] x = [x]
sortedInsert (cur:other) x | x < cur   = x : cur : other
                           | otherwise = cur : sortedInsert other x

lazySort :: (Ord a) => [a] -> [a] --TODO: not lazy
lazySort = foldl' sortedInsert []

collatz :: Int -> Int
collatz x | (x `mod` 2) == 0 = x `div` 2
          | otherwise        = 3 * x + 1

(===) :: (Eq a) => a -> a -> Bool
(===) x y = x == y

infixl 7 ?
(?) x _ = x `div` 3 --TODO: make this postix
