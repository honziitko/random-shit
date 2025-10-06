{-# LANGUAGE TemplateHaskell #-}
import Templates

$(mapN 3)

f c_0 c_1 c_2 = \x -> c_2*x*x + c_1*x + c_0

main :: IO ()
main = do
    print $ map (map3 f [0] [0] [1]) [1..5]
