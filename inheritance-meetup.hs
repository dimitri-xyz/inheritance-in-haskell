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

data Order = Order {price::Price, volume::Volume} deriving (Show)

newtype Bid = Bid Order deriving Show
newtype Ask = Ask Order deriving Show







data OrderBook = OrderBook{ bids::[Bid] , asks::[Ask] } deriving (Show)

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
                                    as           <- getOrders jasks
                                    bs           <- getOrders jbids
                                    return (OrderBook {bids=map Bid bs, asks=map Ask as})

convertBitstamp _ = Nothing

getOrders :: [Jvalue] -> Maybe [Order]
getOrders [] = return []
getOrders (jx:jxs) = do -- this is just a "for each" loop
                    ask  <- convertAnOrder jx
                    asks <- getOrders jxs
                    return (ask : asks)
-- getAsks jxs = sequence (map convertAnOrder jxs)


convertAnOrder :: Jvalue -> Maybe Order
convertAnOrder (Jarray [jprice, jvol]) = do
                    sprice         <- getString jprice
                    svol           <- getString jvol
                    return (makeOrder sprice svol)

convertAnOrder _ = Nothing

-----------eliminate this block-----------------


















------------ the end of the chain --------------



makeOrder :: String -> String -> Order
makeOrder price vol = Order {price = Price (read price :: Double), volume = Volume (read vol :: Double)}




------------------------------------------------
------------------------------------------------

main = do
        -- l <- getContents
        -- print $ convertBitstamp $ parse l

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

