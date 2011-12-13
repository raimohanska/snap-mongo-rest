{-# LANGUAGE DeriveDataTypeable, TemplateHaskell, OverloadedStrings #-}

module Employees where

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

data Employee = Employee { number :: Int, name :: String } deriving (Data, Typeable, Show, Eq)
$(deriveBson ''Employee)

employeeDb = "employee"
employeeCollection = "employee"

postEmployee = method POST $ catchError "Internal Error" $ do 
    employee <- readBodyJson :: Snap Employee
    liftIO $ putStrLn $ "New employee: " ++ (show employee)
    objectId <- liftIO $ mongoPost employeeDb employeeCollection employee
    writeLBS $ JSON.encode $ (objectId) 

getEmployee = jsonGet $ employeeById 

employeeById :: MonadIO m => String -> m (Maybe Employee)
employeeById id = mongoFindOne employeeDb (select ["_id" =: (read id :: ObjectId)] employeeCollection)

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
