{-# LANGUAGE DeriveDataTypeable #-}

module Resut where

import           Control.Monad
import           Control.Monad.Trans(liftIO)
import           Snap.Core
import           Data.Typeable
import           Data.Data
import           Data.Aeson.Generic as JSON
import           Data.Maybe(fromJust)
import           Control.Applicative
import           Util.HttpUtil
import           Util.Rest
import           Util.Json

data Resu = Resu { number :: Int, name :: String } deriving (Data, Typeable, Show)

postResu = method POST $ catchError "Internal Error" $ do 
    resu <- readBodyJson :: Snap Resu
    liftIO $ putStrLn $ "New resu: " ++ (show resu)
    writeLBS $ JSON.encode $ ("1" :: String) 


getResu = restfulGet getResu'    
  where getResu' "1" = writeLBS $ JSON.encode $ Resu 2 "lauronen"
        getResu' _   = notFound
