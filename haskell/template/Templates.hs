{-# LANGUAGE TemplateHaskell #-}
module Templates where

import Control.Monad
import Language.Haskell.TH

curryN :: Int -> Q Exp
curryN n = do
    f <- newName "f"
    xs <- replicateM n (newName "x")
    let args = map VarP (f:xs)
        ntup = TupE $ map VarE xs
    return $ LamE args $ AppE (VarE f) ntup

-- genCurries :: Int -> Q [Dec]
-- genCurries n = forM [1..n] mkCurryDec
--     where mkCurryDec ith = do
--             cury <- curryN ith
--             let name = mkName $ "curry" ++ show ith
--             return $ FunD name [Clause [] (NormalB cury) []]
genCurries :: Int -> Q [Dec]
genCurries n = forM [1..n] mkCurryDec
    where mkCurryDec ith = funD name [clause [] (normalB (curryN ith)) []]
            where name = mkName $ "curry" ++ show ith

mapN :: Int -> Q Dec
mapN n
    | n >= 1 = funD name [cl1, cl2]
    | otherwise = fail "mapN: n >= 1 is false"
    where
        name = mkName $ "map" ++ show n
        cl1  = do f  <- newName "f"
                  xs <- replicateM n (newName "x")
                  ys <- replicateM n (newName "ys")
                  let argPatts = varP f : cosPatts
                      cosPatts = [ [p| $(varP x) : $(varP ys) |]
                                 | (x, ys) <- xs `zip` ys ]
                      apply = foldl (\ g x -> [| $g $(varE x) |])
                      first = apply (varE f) xs
                      rest  = apply (varE name) (f:ys)
                  clause argPatts (normalB [| $first : $rest |]) []
        cl2 = clause (replicate (n+1) wildP) (normalB (conE '[])) []

