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
                                    as           <- getOrders makeAsk jasks
                                    bs           <- getOrders makeBid jbids
                                    return (OrderBook {bids=bs, asks=as})

convertBitstamp _ = Nothing

getOrders :: OrderMaker -> [Jvalue] -> Maybe [Order]
getOrders maker [] = return []
getOrders maker (jx:jxs) = do -- this is just a "for each" loop
                    ask  <- convertAnOrder maker jx
                    asks <- getOrders maker jxs
                    return (ask : asks)
-- getOrders maker jxs = sequence (map (convertAnOrder maker) jxs)


convertAnOrder :: OrderMaker -> Jvalue -> Maybe Order
convertAnOrder maker (Jarray [jprice, jvol]) = do
                    sprice         <- getString jprice
                    svol           <- getString jvol
                    return (maker sprice svol)

convertAnOrder maker _ = Nothing

-----------eliminate this block-----------------


















------------ the end of the chain --------------

type OrderMaker = String -> String -> Order

makeBid :: OrderMaker
makeBid price vol = Bid {price = Price (read price :: Double), volume = Volume (read vol :: Double)}

makeAsk :: OrderMaker
makeAsk price vol = Ask {price = Price (read price :: Double), volume = Volume (read vol :: Double)}

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

