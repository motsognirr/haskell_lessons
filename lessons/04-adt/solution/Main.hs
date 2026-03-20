module Main where

-- | Priority levels for notes, ordered from lowest to highest.
data Priority = Low | Medium | High
  deriving (Show, Eq, Ord)

-- | A note with an ID, title, body, tags, and priority.
data Note = Note
  { noteId   :: Int
  , title    :: String
  , body     :: String
  , tags     :: [String]
  , priority :: Priority
  } deriving (Show, Eq)

-- | Actions a user can perform on the note collection.
data NoteAction
  = Add Note
  | Delete Int
  | Search String
  | ListAll
  deriving (Show)

-- | Filter notes that contain the given tag.
filterByTag :: String -> [Note] -> [Note]
filterByTag tag = filter (\n -> tag `elem` tags n)

-- | Filter notes that match the given priority.
filterByPriority :: Priority -> [Note] -> [Note]
filterByPriority p = filter (\n -> priority n == p)

-- | Produce a human-readable description of a NoteAction.
describeAction :: NoteAction -> String
describeAction (Add note)    = "Adding note: " ++ title note
describeAction (Delete nid)  = "Deleting note with ID: " ++ show nid
describeAction (Search term) = "Searching for: " ++ term
describeAction ListAll       = "Listing all notes"

main :: IO ()
main = do
  let note1 = Note
        { noteId   = 1
        , title    = "Learn Haskell"
        , body     = "Work through all the lessons"
        , tags     = ["haskell", "programming"]
        , priority = High
        }

  let note2 = Note
        { noteId   = 2
        , title    = "Buy groceries"
        , body     = "Milk, eggs, bread"
        , tags     = ["shopping"]
        , priority = Low
        }

  let note3 = Note
        { noteId   = 3
        , title    = "Haskell project"
        , body     = "Build the hask CLI tool"
        , tags     = ["haskell", "project"]
        , priority = Medium
        }

  let allNotes = [note1, note2, note3]

  -- Test filterByTag
  let haskellNotes = filterByTag "haskell" allNotes
  putStrLn $ "Notes with tag 'haskell': " ++ show (length haskellNotes)

  -- Test filterByPriority
  let highNotes = filterByPriority High allNotes
  putStrLn $ "High priority notes: " ++ show (length highNotes)

  -- Test describeAction
  putStrLn $ describeAction (Add note1)
  putStrLn $ describeAction (Delete 2)
  putStrLn $ describeAction (Search "test")
  putStrLn $ describeAction ListAll
