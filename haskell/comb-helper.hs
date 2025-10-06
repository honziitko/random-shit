fsum :: Int -> Int -> (Int -> Int) -> Int
fsum a b f = sum $ map f [a..b]

a :: Int -> Int -> Int
a 0 _ = 1
a 1 _ = 1
a _ 1 = 1
a n k = fsum 1 k (\i -> a (n - i) i)

b :: Int -> Int -> Int
b 0 _ = 1
b 1 _ = 1
b _ 1 = 1
b n k = fsum 1 (min n k) (\i -> b (n - i) i)

generate :: Int -> Int -> [[Int]]
generate 0 _ = [[]]
generate n 1 = [replicate n 1]
generate n k = concat $ map firstElem [1..min n k]
    where
    firstElem r = map (r:) $ generate (n - r) r

allPairs :: Int -> [(Int, Int)]
allPairs n = [(x, y) | x <- s, y <- s]
    where
    s = [1..n]
