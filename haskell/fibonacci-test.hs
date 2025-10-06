goldenRatio :: Double
goldenRatio = (1 + sqrt 5) / 2
geometricSeries = map (ceiling . (goldenRatio **)) [-1..]
geometricIterativeImpl = [5] ++ map (round . (*goldenRatio) . fromIntegral) geometricIterativeImpl
geometricIterative = [1, 1, 2, 3] ++ geometricIterativeImpl
real = 1 : 1 : zipWith (+) real (tail real)
-- λ> findFirstDifference 1 65535 real geometricSeries
-- Just 6
-- λ> findFirstDifference 1 65535 real geometricIterative
-- Just 79
-- λ> real!!78
-- 14472334024676221
-- λ> geometricIterative!!78
-- 14472334024676222

findFirstDifference :: Int -> Int -> [Integer] -> [Integer] -> Maybe Int
findFirstDifference i max (x:xs) (y:ys) | i > max   = Nothing
                                        | x /= y    = Just i
                                        | otherwise = findFirstDifference (i + 1) max xs ys
