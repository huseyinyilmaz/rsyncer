module Env where
import Data.Text(Text)
-- import qualified Turtle as Turtle
import GHC.Generics
import Data.Aeson
import qualified Data.List as L
import qualified Data.Yaml as Y
import Data.ByteString as B
import System.Directory (getHomeDirectory)
import Data.Monoid((<>))

data Project = Project {
  name :: Text,
  source :: Text,
  destination :: Text,
  excludes :: [Text]
  } deriving (Generic, Show, Eq)

instance ToJSON Project
instance FromJSON Project

data Config = Config {
  projects :: [Project]
  } deriving (Generic, Show, Eq)

instance ToJSON Config
instance FromJSON Config


readConfig :: IO Config
readConfig = do
  home <- getHomeDirectory
  content <- B.readFile (home <> ".synca_config.yaml")
  case (Y.decode content):: Maybe Config of
    Just c -> return c
    Nothing -> error "Could not find ~/.synca_config.yaml!"

readProject :: Text -> IO Project
readProject n = do
  config <-  readConfig
  case (L.dropWhile (\p -> (name p) /= n)) (projects config) of
    [] -> error "Project was not found in .synca.config.yaml file."
    (p:_) -> return p
