{-# LANGUAGE DeriveDataTypeable, TemplateHaskell #-}

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
import           Data.Bson.Mapping
import           Database.MongoDB
import           Control.Monad.IO.Class

data Resu = Resu { number :: Int, name :: String } deriving (Data, Typeable, Show, Eq)
$(deriveBson ''Resu)

resuDb = "resu"
resuCollection = "resu"

postResu = method POST $ catchError "Internal Error" $ do 
    resu <- readBodyJson :: Snap Resu
    liftIO $ putStrLn $ "New resu: " ++ (show resu)
    objectId <- liftIO $ mongoPost resuDb resuCollection resu
    writeLBS $ JSON.encode $ (objectId) 

getResu = jsonGet $ resuById 

resuById :: MonadIO m => String -> m (Maybe Resu)
resuById id = mongoFindOne resuDb (select ["_id" =: (read id :: ObjectId)] resuCollection)

mongoPost :: Applicative m => MonadIO m => Bson a => Database -> Collection -> a -> m String
mongoPost db collection x = do val <- doMongo db $ insert collection $ toBson x 
                               case val of
                                  ObjId (oid) -> return $ show oid
                                  _           -> fail $ "unexpected id"

mongoFindOne :: MonadIO m => Bson a => Database -> Query -> m (Maybe a)
mongoFindOne db query = do
                 doc <- doMongo db $ findOne query
                 return (doc >>= (fromBson >=> Just))

doMongo :: MonadIO m => Database -> Action m a -> m a
doMongo db action = do
  pipe <- liftIO $ runIOE $ connect (host "127.0.0.1")
  result <- access pipe master db action
  liftIO $ close pipe
  case result of
    Right val -> return val 
    Left failure -> fail $ show failure
