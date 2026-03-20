module Main where

-- Part 1: Implement from scratch (no Prelude versions)

myMap :: (a -> b) -> [a] -> [b]
myMap _ []     = []
myMap f (x:xs) = f x : myMap f xs

myFilter :: (a -> Bool) -> [a] -> [a]
myFilter _ []     = []
myFilter p (x:xs)
  | p x       = x : myFilter p xs
  | otherwise  = myFilter p xs

myFoldl :: (b -> a -> b) -> b -> [a] -> b
myFoldl _ acc []     = acc
myFoldl f acc (x:xs) = myFoldl f (f acc x) xs

-- Part 2: One-liners using standard HOFs

doubleAll :: [Int] -> [Int]
doubleAll = map (*2)

keepEvens :: [Int] -> [Int]
keepEvens = filter even

sumSquares :: [Int] -> Int
sumSquares = sum . map (^2)

-- Part 3: main

main :: IO ()
main = do
  putStrLn $ "myMap (+1) [1,2,3] = " ++ show (myMap (+1) [1,2,3])
  putStrLn $ "myFilter even [1,2,3,4,5] = " ++ show (myFilter even [1,2,3,4,5])
  putStrLn $ "myFoldl (+) 0 [1,2,3,4,5] = " ++ show (myFoldl (+) 0 [1,2,3,4,5])
  putStrLn $ "doubleAll [1,2,3] = " ++ show (doubleAll [1,2,3])
  putStrLn $ "keepEvens [1,2,3,4,5,6] = " ++ show (keepEvens [1,2,3,4,5,6])
  putStrLn $ "sumSquares [1,2,3] = " ++ show (sumSquares [1,2,3])
