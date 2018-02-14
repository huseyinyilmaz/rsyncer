module Lib where

import Turtle
-- import qualified Data.Text as Text
import Copy(rsync, watch, Project(..))
import Env

parser :: Parser (Maybe Text, Maybe Text, Maybe Text, [Text])
parser = (,,,) <$> optional (argText "project" "Project to sync")
               <*> optional (optText "source" 's' "source location for rsync")
               <*> optional (optText "destination" 'd' "Destination location for rsync")
               <*> (many (optText "exclude" 'e' "Exclude Following Paths(Coma separated List)"))


main :: IO ()
main =  do
  (maybeProjectName, maybeSource, maybeDestination, excludes) <- options
    "Calls rsync on file system changes."
    parser
  project <- case (maybeProjectName, maybeSource, maybeDestination) of
    -- No project name, but there is source and destination in place.
    (Nothing, Just source, Just destination) ->
      return Project "custom_call" source destination excludes
    (Just project, maybeSource, maybeDestination) ->
      project
      where
        p = readProject projectName
        s
        project = p
    otherwise ->
      exit "Either project name or source/destination pair must be provided (try rsync --help)"
  view $ rsync project
  watch (view . rsync) project
