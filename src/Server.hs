{-# LANGUAGE OverloadedStrings #-}

module Server where

import           Snap.Http.Server
import           Snap.Core
import           Resut

main :: IO ()
main = serve defaultConfig

serve :: Config Snap a -> IO()
serve config = httpServe config $ route [ 
  ("/resu", postResu)
  ,("/resu/:id", getResu) ] 

