-- source:
-- https://github.com/huseyinyilmaz/cscp/blob/master/src/Copy.hs
module Copy where

import Control.Concurrent (threadDelay, forkIO)
import Control.Concurrent.MVar (newMVar, tryTakeMVar, putMVar)
import Data.Maybe (isJust)
import qualified Data.Text as T
import System.FSNotify
import Turtle
import Turtle.Line(lineToText)
import Utils
import Env(Project(..))
import Data.Maybe(fromMaybe)
import Data.Either(Either(..))
import Control.Monad.Catch(catch)
import System.Exit (ExitCode(..))

-- Watch filesystem
watch :: (Project -> IO()) -> Project -> IO ()
watch fun project = do
  lock <- newMVar ()
  withManager $ \mgr -> do
    putStrLn $ show project
    -- start a watching job (in the background)
    void $ watchTree
      mgr          -- manager
      ((T.unpack . source) project)          -- directory to watch
      (const True) -- predicate
      (\_-> void $ forkIO $ do
          took <- tryTakeMVar lock
          when (isJust took) $ do
            putStrLn "Change detected"
            threadDelay (1 * 1000 * 1000)
            putStrLn "threadDelay completed"
            void $ fun project -- action
            putStrLn "rsync completed"
            putMVar lock ())
    -- sleep forever (until interrupted)
    forever $ threadDelay 1000000

-- Create Exclude list
toExcludeList :: IsString b => [b] -> [b]
toExcludeList exs= do
  ex <- exs
  ["--exclude", ex]

-- run rsync command
rsync :: Project -> Shell ()
rsync project = do
  let args = (["-arPLvz"] ++
              (toExcludeList $ fromMaybe [] (excludes project)) ++
              ["--delete", (source project), (destination project)])

  viewText $ (fmap (lineToText.openEither)) $ runRsync args
  where
    handleError :: ExitCode -> Shell (Either Line Line)
    handleError (ExitFailure c) = return $ Left errorMessage
      where
        errorMessage = "EXIT_CODE: " <> (fromString $ show c)
    handleError val = return $ Left ("UNEXPECTED VALUE: " <> ((fromString . show) val))
    runRsync :: [Text] -> Shell (Either Line Line)
    runRsync args = (inprocWithErr "rsync" args empty) `catch` handleError
    openEither ei = case ei of
                      Left er -> "ERROR: " <> er
                      Right out -> out
