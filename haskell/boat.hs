mapPair :: (a -> b) -> (a, a) -> (b, b)
mapPair f (x, y) = (f x, f y)

pairToList :: (a, a) -> [a]
pairToList (x, y) = [x, y]

-- Implements the formula from https://youtu.be/ei58gGM9Z8k?t=857
idk :: Int -> (Int, Int)
idk n = mapPair (`div` 50) $ mapPair (*times25) (times25 - 1, times25 + 1)
    where
    times25 = 25*n

theThing = foldr (++) [] $ map pairToList $ map idk [1..]
