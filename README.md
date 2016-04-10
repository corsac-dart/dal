# Corsac DAL

Database abstraction layer for applications based on Repository pattern.

This library is not an attempt to implement an ORM framework, in fact,
all the "mapping" logic has been purposely excluded.

Instead, Corsac DAL is mostly a collection of generic interfaces which provides
a convention for writing technology-specific implementations. The task of
mapping state of domain objects to and from particular storage technology is
left to actual implementation.

What's included:

* Generic (opinionated) interface for Repositories
* Generic interface and implementation for filtering criteria.
* IdentityMap implementation
* Some DI bindings (optional)
