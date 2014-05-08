inheritance-in-haskell
======================

An example that attempts to understand how to do inheritance in haskell.

The file tries to convert a JSON response received from a call to Bitstamp's orderbook API

https://www.bitstamp.net/api/order_book/

into a value of type OrderBook. It assumes the existence of a generic JSON parser that will parse the text and return a Jvalue. Now we just have to make sure the response is what we expect and create the OrderBook. 

This example contains 4 files. All files derive from "inheritance-base.hs". The source has been formatted so that all code lines up nicely. Each file represents a different way to map inheritance into haskell to eliminate the redundant code present in "base" (i.e. inheritance-base.hs).

The fundamental question here is:

*What are the criteria we should use to choose between these different possibilities?*
