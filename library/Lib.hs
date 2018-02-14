module Lib where

import Turtle
-- import qualified Data.Text as Text
import Copy(rsync, watch)
import Env(readProject, Project(..))
import Data.Maybe(fromMaybe)

parser :: Parser (Maybe Text, Maybe Text, Maybe Text, [Text])
parser = (,,,) <$> optional (argText "project" "Project to sync")
               <*> optional (optText "source" 's' "source location for rsync")
               <*> optional (optText "destination" 'd' "Destination location for rsync")
               <*> (many (optText "exclude" 'e' "Exclude Following Paths(Coma separated List)"))

main :: IO ()
main =  do
  (maybeProjectName, maybeSource, maybeDestination, exs) <- options
    "Calls rsync on file system changes."
    parser
  project <-
    case (maybeProjectName, maybeSource, maybeDestination) of
      -- No project name, but there is source and destination in place.
      (Nothing, Just src, Just dest) ->
        return $ Project "custom_call" src dest exs
      (Just projectName, _, _) -> do
        p <- readProject projectName
        return Project {name=projectName,
                        destination=fromMaybe (destination p) maybeDestination,
                        source=fromMaybe (source p) maybeSource,
                        excludes=excludes p <> exs}
      _ ->
        error "Either project name or source/destination pair must be provided (try rsync --help)"
  view $ rsync project
  watch (view . rsync) project
