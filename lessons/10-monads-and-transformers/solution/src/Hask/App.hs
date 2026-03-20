module Hask.App
  ( AppConfig(..)
  , App
  , runApp
  , throwHaskError
  ) where

import Control.Monad.Except  (ExceptT, runExceptT, throwError)
import Control.Monad.Reader  (ReaderT, runReaderT)
import Hask.Error (HaskError(..))

-- | Runtime configuration for the application.
data AppConfig = AppConfig
  { notesFile :: FilePath
  , verbose   :: Bool
  }

-- | The application monad stack.
--
--   * ExceptT HaskError  -- may fail with a HaskError
--   * ReaderT AppConfig  -- has access to configuration
--   * IO                 -- can perform side effects
type App a = ExceptT HaskError (ReaderT AppConfig IO) a

-- | Run an App action with the given configuration.
runApp :: AppConfig -> App a -> IO (Either HaskError a)
runApp config action = runReaderT (runExceptT action) config

-- | Throw a HaskError inside the App monad.
throwHaskError :: HaskError -> App a
throwHaskError = throwError
