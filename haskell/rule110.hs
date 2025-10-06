import Data.List

calculateCell :: Bool -> Bool -> Bool -> Bool
calculateCell False False False = False
calculateCell False False True  = True
calculateCell False True  False = True
calculateCell False True  True  = True
calculateCell True  False False = False
calculateCell True  False True  = True
calculateCell True  True  False = True
calculateCell True  True  True  = False

nextState :: [Bool] -> [Bool]
nextState [] = []
nextState [_] = [False]
nextState idk = False : center ++ [False]
        where
    center = zipWith3 calculateCell idk (tail idk) (tail $ tail idk)

play :: Int -> [[Bool]]
play n = take n $ iterate nextState $ (replicate (n - 1) False ++ [True])

drawState :: [[Bool]] -> String
drawState state = intercalate "\n" $ map (map drawChar) state
        where
    drawChar True  = '#'
    drawChar False = ' '
