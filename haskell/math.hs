eps = 0.001

deriveDx dx f x = (f (x + dx) - f x) / dx
derive = deriveDx eps

minusLists :: (Num a) => [a] -> [a] -> [a]
minusLists [] [] = []
minusLists [] ys = map negate ys
minusLists xs [] = xs
minusLists (x:xs) (y:ys) = (x - y) : minusLists xs ys

nextDerivateCoffs xs = minusLists (0 : xs) xs --TODO: this is just the next row is Pascal's triangle with alternating signs wtf???

sign x | x < 0     = -1
       | otherwise =  1

-- nthDerivate :: (Fractional a) => (Integral b) => a -> b -> (a -> a) -> a -> a
nthDerivateDx dx n f x = (sum $ zipWith (\i -> \c -> c * f (x + i*dx)) [0..] coffs) / den
    where
    coffs = (iterate nextDerivateCoffs [1])!!n
    den = dx ^ n
nthDerivate = nthDerivateDx eps

-- λ> let fs = iterate (derive 0.00001) square
-- λ> zipWith ($) fs (replicate 5 3)
-- [9.0,6.000009999951316,2.000017929049136,-3.552713678822705,710542.735764541]
-- λ> let fs = iterate (derive 0.00001) (const 2)
-- λ> zipWith ($) fs (replicate 5 3)
-- [2.0,0.0,0.0,0.0,0.0]
-- λ> let fs = iterate (derive 0.00000000000001) square
-- λ> zipWith ($) fs (replicate 5 3)
-- [9.0,6.217248937900877,-1.7763568394002504e13,3.5527136788005005e27,-7.105427357601001e41]
square x = x * x --utility function for testing

integralDx dx a b f | a > b     = -integralDx dx b a f
                    | otherwise = sum $ map (*dx) $ map f inputs
    where
    inputs = takeWhile (<=b) $ iterate (+dx) a

newtonEps eps f f' x = head $ dropWhile (\x -> (abs $ f x) > eps) $ iterate next x
    where
    next x = x - f(x) / f'(x)
newton = newtonEps eps

rootOfEps eps f x = head $ dropWhile (\x -> (abs $ f x) > eps) $ iterate next x
    where
    next x = x - (eps * f(x))/(f(x + eps) - f(x))

rootOf = rootOfEps eps

-- solveFOfXEqualsA eps f a = newton eps g (deriveDx eps g) a
--     where
--     g x = a - f x

inverseOfEps eps f x = rootOfEps eps g x
    where
    g x_g = f(x_g) - x
inverseOf = inverseOfEps eps

integrateDx dx f x = integralDx eps 0 x f
integrate = integrateDx eps
