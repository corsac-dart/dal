# Corsac Stateless

**Experimental** Repository layer for applications.

Trying to solve complex problem in a simple and flexible way.

This library is not an ORM but purely implementation of generic Repository
layer (including IdentityMap and some other necessities).

There is no logic related to persisting domain objects. Even intermediate
data (like state of Identity Map) is delegated to another experimental
library [Corsac Call Stack](https://github.com/corsac-dart/call-stack).

That is why "Stateless".

## Background and motivation

All entities are stored in some sort of database. However, regardless of how
they are stored we always need this layer of abstraction on top of storage
mechanism which is usually referred to as "Repositories".

There are several meanings to this term, however fundamental idea is always
the same - repositories are special collections which abstract details of
persisting and fetching entity data.

Speaking of collections. How do we usually interact with those? Simple example:

```dart
var list = new List(); // our collection
var user = new User(); // our object
list.add(user); // this is how we add object to the collection
var id = list.first.id; // this is how we access item in the collection
user.activate(); // we mutate the object. Note: we don't need to update
                 // collection since is holds this same object already.
```

Repositories should work somewhat similar. Tricky part with repositories is
that they delegate persistence to external system (database) while
keeping track of entities loaded during current business transaction.
Normally contents of repositories are flushed between transactions to
prevent stale state.

This creates whole set of complicated problems and this is what also led to
invention of such design patterns like UnitOfWork, Proxy and ActiveRecord.

While there is nothing wrong with these patterns there are usually issues
with implementations, which are practically very complicated and
concentrated mainly on the storage side of things.
And that is what feels wrong.

There is nothing wrong in using good ORM framework. However with all the
benefits we also usually get some drawbacks, like:

* Performance (typically ORMs have performance overhead)
* Limited set of supported storages
* Limitations in provided functionality. Usually forcing developers to come
  up with all sorts of workarounds when designing domain layers.
* Learning curve (powerful ORM require some time and patience to
  master it)
* Complications in testing involving different aspects including speed
  and infrastructure.

And again, the fact that ORM frameworks are typically storage-oriented is
not making it easier to build rich and powerful domain layer.

There should be some other and hopefully better ways to solve this problems.

This library is an implementation of one possible alternative.
It is built on following core ideas:

* Provide repository layer which behave very much like collections (as in
  the example above).
* Keep implementation as simple and small as possible.
  Avoid complex technics like Proxy and UnitOfWork while providing similar
  capabilities.
* Minimize impact of using this library on domain layers of it's users.
  Mainly on entities since repositories technically are not considered part
  of domain layer.
* Enable easy prototyping of domain layer.
* Simple testing infrastructure.


## The approach

First, the problem of storing IdentityMap state is delegated to the Call Stack
library. So that this library knows nothing about the application's
life cycle.

Given that, repositories only need access to the state of currently
executing "application transaction", that's all they need to know.

The rest of the implementation is pretty much typical with added
benefit that there is no need to keep track of current "session" or
"UnitOfWork" or anything else similar.

One more difference is a "state subscription" model which enables
interaction with repositories more like with regular collections.

There are also a few assumptions:

* It is expected that entities get their unique identity even before
  they are added to the repository.
* Storage interface is expected to be a "put/get" model rather than
  "insert/update/get".
