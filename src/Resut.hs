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

data Resu = Resu { number :: Int, name :: String } deriving (Data, Typeable, Show, Eq)
$(deriveBson ''Resu)

postResu = method POST $ catchError "Internal Error" $ do 
    resu <- readBodyJson :: Snap Resu
    liftIO $ putStrLn $ "New resu: " ++ (show resu)
    liftIO $ mongoPost resu
    writeLBS $ JSON.encode $ ("1" :: String) 

getResu = restfulGet getResu'    
  where getResu' id = do maybeResu <- liftIO $ resuById id
                         case maybeResu of
                            Nothing -> notFound
                            Just resu -> writeLBS $ JSON.encode $ resu

mongoPost :: Bson a => a -> IO Value
mongoPost x = doMongo "resu" $ insert "resu" $ toBson x 

mongoFindOne :: Bson a => Query -> IO (Maybe a)
mongoFindOne query = do
                 doc <- doMongo "resu" $ findOne query
                 case doc of
                    Nothing -> return Nothing
                    Just d -> do result <- fromBson d 
                                 return $ Just result

resuById :: String -> IO (Maybe Resu)
resuById id = mongoFindOne (select ["_id" =: (read id :: ObjectId)] "resu")

doMongo :: Database -> Action IO a -> IO a
doMongo db action = do
  pipe <- runIOE $ connect (host "127.0.0.1")
  result <- access pipe master db action
  case result of
    Right val -> return val 
    Left failure -> fail $ show failure
