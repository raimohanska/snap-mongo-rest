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

postResu = method POST $ catchError "Internal Error" $ do 
    resu <- readBodyJson :: Snap Resu
    liftIO $ putStrLn $ "New resu: " ++ (show resu)
    liftIO $ mongoPost resu
    writeLBS $ JSON.encode $ ("1" :: String) 

getResu = restfulGet getResu'    
  where getResu' id = do maybeResu <- resuById id
                         case maybeResu of
                            Nothing -> notFound
                            Just resu -> writeLBS $ JSON.encode $ resu

resuById :: MonadIO m => String -> m (Maybe Resu)
resuById id = mongoFindOne (select ["_id" =: (read id :: ObjectId)] "resu")

mongoPost :: Applicative m => MonadIO m => Bson a => a -> m Value
mongoPost x = doMongo "resu" $ insert "resu" $ toBson x 

mongoFindOne :: MonadIO m => Bson a => Query -> m (Maybe a)
mongoFindOne query = do
                 doc <- doMongo "resu" $ findOne query
                 case doc of
                    Nothing -> return Nothing
                    Just d -> do result <- fromBson d 
                                 return $ Just result

doMongo :: MonadIO m => Database -> Action m a -> m a
doMongo db action = do
  pipe <- liftIO $ runIOE $ connect (host "127.0.0.1")
  result <- access pipe master db action
  case result of
    Right val -> return val 
    Left failure -> fail $ show failure
