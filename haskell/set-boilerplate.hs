import Data.List
import Data.Ratio (numerator, denominator)

expandNat :: (Integral i) => i -> String
expandNat 0 = "{}"
expandNat n = "{" ++ (intercalate "," $ map expandNat [0..(n - 1)]) ++ "}"

expandPair :: (String, String) -> String
expandPair (a, b) = "{{" ++ a ++ "," ++ expandNat 1 ++ "},{" ++ b ++ "," ++ expandNat 2 ++ "}}"

translateInteger :: (Integral i) => i -> (i, i)
translateInteger n | n < 0     = (0, -n)
                   | otherwise = (n, 0)

pairToList :: (a, a) -> [a]
pairToList (x, y) = [x, y]

both :: (a -> b) -> (a, a) -> (b, b)
both f (x, y) = (f x, f y)

expandInteger :: (Integral i) => i -> String
expandInteger n = expandPair $ both expandNat $ translateInteger n

mapKeep :: (a -> b) -> [a] -> [(a, b)]
mapKeep f = map (\x -> (x, f x))

count :: (Eq a) => a -> [a] -> Integer
count x xs = foldl' (\n -> \x' -> if x' == x then n + 1 else n) 0 xs

expandRational :: Rational -> String
expandRational x = expandPair $ both expandInteger (numerator x, denominator x)

expandRational' :: Rational -> String
expandRational' x = expandPair (expandInteger $ numerator x, expandNat $ denominator x)
