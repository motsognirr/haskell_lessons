{-# LANGUAGE FlexibleInstances #-}
module Main where

import Data.List (isInfixOf, intercalate)

-- | Priority level for a note.
data Priority = Low | Medium | High
  deriving (Eq, Ord)

-- | Custom Show instance that displays priority as a bracketed label.
instance Show Priority where
  show Low    = "[LOW]"
  show Medium = "[MED]"
  show High   = "[!!!]"

-- | A note with a title, body, tags, and priority.
data Note = Note
  { noteTitle :: String
  , noteBody  :: String
  , noteTags  :: [String]
  , priority  :: Priority
  }

-- | Typeclass for types that can be displayed as a formatted string.
class Displayable a where
  display :: a -> String

-- | Display a single note as: "[priority] title (tags: tag1, tag2)"
instance Displayable Note where
  display note =
    show (priority note)
    ++ " "
    ++ noteTitle note
    ++ " (tags: "
    ++ intercalate ", " (noteTags note)
    ++ ")"

-- | Display a list of notes, one per line.
instance Displayable [Note] where
  display notes = unlines (map display notes)

-- | Typeclass for types that can be searched by a string term.
class Searchable a where
  search :: String -> a -> Bool

-- | Search a note: returns True if the term appears in the title,
--   body, or matches any tag exactly.
instance Searchable Note where
  search term note =
    term `isInfixOf` noteTitle note
    || term `isInfixOf` noteBody note
    || any (== term) (noteTags note)

main :: IO ()
main = do
  let note1 = Note
        { noteTitle = "My Note"
        , noteBody  = "Learn about typeclasses"
        , noteTags  = ["haskell", "fp"]
        , priority  = High
        }

  putStrLn (show High)
  putStrLn (display note1)
  print (search "haskell" note1)
  print (search "python" note1)
