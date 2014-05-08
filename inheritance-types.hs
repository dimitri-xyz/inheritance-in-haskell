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

class Order a where
    makeOrder :: String -> String -> a

data Ask = Ask {aprice::Price, avolume::Volume} deriving (Show)
instance Order Ask where
    makeOrder = makeAsk

data Bid = Bid {bprice::Price, bvolume::Volume} deriving (Show)
instance Order Bid where
    makeOrder = makeBid

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
                                    as           <- (getOrders jasks :: Maybe [Ask])
                                    bs           <- (getOrders jbids :: Maybe [Bid])
                                    return (OrderBook {bids=bs, asks=as})

convertBitstamp _ = Nothing

getOrders :: Order a => [Jvalue] -> Maybe [a]
getOrders [] = return []
getOrders (jx:jxs) = do -- this is just a "for each" loop
                    order  <- convertAnOrder jx
                    orders <- getOrders jxs
                    return (order : orders)



convertAnOrder :: Order a => Jvalue -> Maybe a
convertAnOrder (Jarray [jprice, jvol]) = do
                    sprice         <- getString jprice
                    svol           <- getString jvol
                    return (makeOrder sprice svol)

convertAnAsk _ = Nothing

-----------eliminate this block-----------------


















------------ the end of the chain --------------



makeBid :: String -> String -> Bid
makeBid price vol = Bid {bprice = Price (read price :: Double), bvolume = Volume (read vol :: Double)}

makeAsk :: String -> String -> Ask
makeAsk price vol = Ask {aprice = Price (read price :: Double), avolume = Volume (read vol :: Double)}

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

