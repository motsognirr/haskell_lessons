module Main where

-- | Safe version of head. Returns Nothing for an empty list.
myHead :: [a] -> Maybe a
myHead []    = Nothing
myHead (x:_) = Just x

-- | Safe version of last. Returns the last element wrapped in Just,
-- or Nothing for an empty list.
myLast :: [a] -> Maybe a
myLast []     = Nothing
myLast [x]    = Just x
myLast (_:xs) = myLast xs

-- | Count the number of elements in a list using pattern matching
-- and recursion (no built-in length).
countElements :: [a] -> Int
countElements []     = 0
countElements (_:xs) = 1 + countElements xs

-- | Classic FizzBuzz for a single number using guards.
fizzbuzz :: Int -> String
fizzbuzz n
  | n `mod` 15 == 0 = "FizzBuzz"
  | n `mod` 3  == 0 = "Fizz"
  | n `mod` 5  == 0 = "Buzz"
  | otherwise        = show n

main :: IO ()
main = do
  -- Test myHead
  print (myHead [1, 2, 3])
  print (myHead ([] :: [Int]))

  -- Test myLast
  print (myLast [1, 2, 3])

  -- Test countElements
  print (countElements [10, 20, 30, 40])

  -- Test fizzbuzz for 1 through 15
  mapM_ (putStrLn . fizzbuzz) [1..15]
