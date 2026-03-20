module Main where

-- | Convert a temperature from Celsius to Fahrenheit.
celsiusToFahrenheit :: Double -> Double
celsiusToFahrenheit c = c * 9 / 5 + 32

-- | Convert a temperature from Fahrenheit to Celsius.
fahrenheitToCelsius :: Double -> Double
fahrenheitToCelsius f = (f - 32) * 5 / 9

-- | Greet a person by first and last name.
greet :: String -> String -> String
greet firstName lastName = "Hello, " ++ firstName ++ " " ++ lastName ++ "!"

-- | Return the initials of a first and last name, each followed by a dot.
initials :: String -> String -> String
initials firstName lastName = [head firstName] ++ "." ++ [head lastName] ++ "."

main :: IO ()
main = do
  print (celsiusToFahrenheit 100)
  print (fahrenheitToCelsius 32)
  putStrLn (greet "John" "Doe")
  putStrLn (initials "John" "Doe")
