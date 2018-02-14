module Lib where

import Turtle
-- import qualified Data.Text as Text
import Copy(rsync, watch)
import Env

parser :: Parser Text
parser = argText "project" "Project to sync"


main :: IO ()
main =  do
  projectName <- options
    "Calls rsync on file system changes."
    parser
  project <- readProject projectName
  view $ rsync project
  watch (view . rsync) project
