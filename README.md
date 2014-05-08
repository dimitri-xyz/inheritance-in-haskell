inheritance-in-haskell
======================

An example that attempts to understand how to do inheritance in haskell.

The file tries to convert a JSON response received from a call to Bitstamp's orderbook API

https://www.bitstamp.net/api/order_book/

into a value of type OrderBook. It assumes the existence of a generic JSON parser that will parse the text and return a Jvalue. Now we just have to make sure the response is what we expect and create the OrderBook. 

This example contains 4 files. All files derive from "inheritance-base.hs". The source has been formatted so that all code lines up nicely. Each file represents a different way to map inheritance into haskell to eliminate the redundant code present in "base" (i.e. inheritance-base.hs).

The fundamental question here is:

*What are the criteria we should use to choose between these different possibilities?*


---

Here are some thoughts I got through the Haskell Beginners mailing list and the meetup group.

The functional solution allows for Bids and Asks to be put on the same list as they are of the same type. The other two solutions, do not. That's a show stopper, because a "polymorphic" list of bids and asks coming in at different times is exactly what an exchange market is. So, I would like to be able to model that. I would also like to be able to have functions that operate on whole markets (bitstamp, itbit, campbx, etc).

I am choosing the data representation mostly based on what I think it is conceptually. At the same time, what I think the data *is* is strongly informed, by *how I think I'm going to use it*.

There is fundamental tension here, though.

The functional solution is flexible in that I have many ways I can create the same type. just write up a new function. However, it is unsatisfying because it *explicilty* passes the makeAsk or MakeBid functions down the chain. In an Objected-Oriented setting this would be invisible by using *this. The type solution avoids explicitly passing that argument, but Asks and Bids would have to be of different types and we can only have one OrderMaker function per type (or class instance).

Having different types is bad in Haskell because it does not allow for polymorphic lists. In C++ or Java, we can have polymorphic lists. So, we can make different type, give each type its own specialized OrderMaker and put them all in the same list. We can do all but the last step (put the all in the same list) in Haskell. In short, Haskell is forcing me to explicitly pass a functional parameter in this code, because it doesn't allow for two different types to be put inside the same list. *I think there is a fundamental tension here.* As I see it, strong static typing is a limitation that is making my program worse here.

One more thought, I'm not sure it is possible to satisfactorily model an inheritance relationship with 3 or more levels in Haskell (e.g. Ford F-10 ->is a-> Pickup Truck ->is a-> Car ).








