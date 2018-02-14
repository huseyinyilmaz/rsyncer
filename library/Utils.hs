module Utils where

import qualified Data.Text.IO as TIO

import Turtle

-- source: https://www.reddit.com/r/haskell/comments/49vft1/turtle_library_output_format_question/d0v6zm3
viewText :: MonadIO io => Shell Text -> io ()
viewText txt = sh (txt >>= liftIO . TIO.putStrLn)
