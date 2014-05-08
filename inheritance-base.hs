module Main where

import qualified Data.Map as Map

-- import JsonParser
-- parse :: String -> Jvalue

data Jvalue = Jobject   (Map.Map String Jvalue)
            | Jarray    [Jvalue] 
            | Jstring   String
            | Jnumber   Double
            | Jbool     Bool
            | Jnull
            deriving Show

-- Order type

newtype Volume = Volume Double deriving (Show)
newtype Price  = Price  Double deriving (Show)

data Order = Bid {price::Price, volume::Volume} 
           | Ask {price::Price, volume::Volume}
           deriving (Show)








data OrderBook = OrderBook{ bids::[Order] , asks::[Order] } deriving (Show)

--------------------------------------------------------------------------------
-- I need functions to convert parsed responses of type Jvalue to type OrderBook
--------------------------------------------------------------------------------

--------------helper functions------------------

getString :: Jvalue -> Maybe String
getString (Jstring str) = return str
getString  _ = Nothing

getNumber :: Jvalue -> Maybe Double
getNumber (Jnumber num) = return num
getNumber  _ = Nothing
------------------------------------------------

convertBitstamp :: Jvalue -> Maybe OrderBook
convertBitstamp  (Jobject dict) = do
                                    Jarray jasks <- Map.lookup "asks" dict
                                    Jarray jbids <- Map.lookup "bids" dict
                                    as           <- getAsks jasks
                                    bs           <- getBids jbids
                                    return (OrderBook {bids=bs, asks=as})

convertBitstamp _ = Nothing

getAsks :: [Jvalue] -> Maybe [Order]
getAsks [] = return []
getAsks (jx:jxs) = do -- this is just a "for each" loop
                    ask  <- convertAnAsk jx
                    asks <- getAsks jxs
                    return (ask : asks)
-- getAsks jxs = sequence (map convertAnAsk jxs)


convertAnAsk :: Jvalue -> Maybe Order
convertAnAsk (Jarray [jprice, jvol]) = do
                    sprice         <- getString jprice
                    svol           <- getString jvol
                    return (makeAsk sprice svol)

convertAnAsk _ = Nothing

-----------eliminate this block-----------------

getBids :: [Jvalue] -> Maybe [Order]
getBids []       = return []
getBids (jx:jxs) = do   -- this is just a "for each" loop
                bid  <- convertABid jx
                bids <- getBids jxs
                return (bid : bids)
-- getBids jxs = sequence (map convertABid jxs)

convertABid :: Jvalue -> Maybe Order
convertABid (Jarray [jprice, jvol]) = do
                    sprice        <- getString jprice
                    svol          <- getString jvol 
                    return (makeBid sprice svol)

convertABid _ = Nothing


------------ the end of the chain --------------



makeBid :: String -> String -> Order
makeBid price vol = Bid {price = Price (read price :: Double), volume = Volume (read vol :: Double)}

makeAsk :: String -> String -> Order
makeAsk price vol = Ask {price = Price (read price :: Double), volume = Volume (read vol :: Double)}

------------------------------------------------
------------------------------------------------

main = do
        -- l <- getContents
        -- print $ convertBitstamp2 $ parse l

        -- l <- getContents
        let response = Jobject(
                        Map.fromList([
                                        ("asks", Jarray [
                                                            Jarray [ Jstring "430", Jstring "1.2"],
                                                            Jarray [ Jstring "431", Jstring "0.5"]
                                                        ]),

                                        ("bids", Jarray [
                                                            Jarray [ Jstring "420", Jstring "3" ],
                                                            Jarray [ Jstring "419", Jstring "5" ]
                                                        ])
                                     ]))

        print $ convertBitstamp $ response

