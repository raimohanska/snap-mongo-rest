{-# LANGUAGE DeriveDataTypeable, TemplateHaskell, OverloadedStrings #-}

module Employees where

import           Snap.Core
import           Data.Typeable
import           Data.Data
import           Data.Aeson.Generic as JSON
import           Util.HttpUtil
import           Util.Rest
import           Util.Json
import           Data.Bson.Mapping
import           Database.MongoDB
import           Control.Monad.IO.Class
import           Util.Mongo

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
