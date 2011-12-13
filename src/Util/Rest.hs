{-# LANGUAGE OverloadedStrings, DeriveDataTypeable #-}

module Util.Rest where

import           Snap.Core
import           Util.HttpUtil
import           Prelude hiding (id, lookup)
import           Data.Aeson.Generic as JSON
import           Data.Data

restfulGet :: (String -> Snap()) -> Snap ()
restfulGet lookup = method GET $ do
    idPar <- getPar("id")
    case idPar of
     Just(id) -> lookup id
     Nothing -> notFound

jsonGet :: Data a => (String -> Snap (Maybe a)) -> Snap ()
jsonGet lookup = restfulGet $ \id -> do
    maybeFound <- lookup id
    case maybeFound of
      Nothing -> notFound
      Just(val) -> writeLBS $ JSON.encode $ val
