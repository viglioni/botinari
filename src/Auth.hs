{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Auth
  ( getHeaders
  ) where

import Control.Lens ((^.))
import Control.Lens.Operators ((.~))
import Control.Monad.Trans.Except (ExceptT(ExceptT), runExceptT)
import Data.Aeson (ToJSON(toJSON))
import Data.Aeson.Lens (_String, key)
import Data.Text (Text)
import Env (envGetText)
import GHC.Generics (Generic)
import Helpers (textToByteString)
import Http (post)
import IOEither (IOEither)
import Network.Wreq (Options, defaults, header)
import Url (createSessionUrl)

type JWT = Text

data Payload = Payload
  { identifier :: Text
  , password :: Text
  } deriving (Show, Generic)

instance ToJSON Payload

createSession :: IOEither JWT
createSession =
  runExceptT $ do
    did <- ExceptT $ envGetText "DID"
    token <- ExceptT $ envGetText "TOKEN"
    let payload = toJSON (Payload did token)
    res <- ExceptT $ post createSessionUrl payload Nothing
    return $ res ^. key "accessJwt" . _String

addAuthHeader :: JWT -> Options
addAuthHeader jwt = (header "Authorization" .~ [authorization]) defaults
  where
    authorization = textToByteString $ "Bearer " <> jwt

getHeaders :: IOEither Options
getHeaders =
  runExceptT $ do
    jwt <- ExceptT createSession
    return $ addAuthHeader jwt
