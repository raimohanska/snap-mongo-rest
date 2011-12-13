{-# LANGUAGE OverloadedStrings #-}

module Server where

import           Snap.Http.Server
import           Snap.Core
import           Employees

main :: IO ()
main = serve defaultConfig

serve :: Config Snap a -> IO()
serve config = httpServe config $ route [ 
  ("/employee", postEmployee)
  ,("/employee/:id", getEmployee) ] 

