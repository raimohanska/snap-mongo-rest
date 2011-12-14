module Util.Mongo where

import           Control.Monad
import           Control.Applicative
import           Data.Bson.Mapping
import           Database.MongoDB
import           Control.Monad.IO.Class

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
