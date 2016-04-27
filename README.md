# Corsac DAL

[![Build Status](https://travis-ci.org/corsac-dart/dal.svg?branch=master)](https://travis-ci.org/corsac-dart/dal)
[![Code Coverage](https://codecov.io/github/corsac-dart/dal/coverage.svg?branch=master)](https://codecov.io/github/corsac-dart/dal?branch=master)

Database abstraction layer for applications. This library is based on
Repository pattern.

It is _not_ an attempt to implement an ORM framework, in fact,
all the "mapping" logic has been purposely excluded.

Instead, Corsac DAL is mostly a collection of generic interfaces which provides
a convention for writing technology-specific implementations. The task of
mapping state of domain objects to and from particular storage technology is
left to actual implementation.

What's included:

* Generic (opinionated) interface for Repositories
* Generic interface and implementation for filtering criteria.
* IdentityMap implementation
* Some DI bindings (optional, as separate library)

## 1. Repositories

Here is the main interface provided by this library (doc comments excluded):

```dart
abstract class Repository<T> {
  Future put(T entity);
  Future<T> get(id);
  Future<T> findOne(Filter<T> filter);
  Stream<T> find(Filter<T> filter);
  Future<int> count([Filter<T> filter]);
  Future batchPut(Set<T> entities);
  Stream<T> batchGet(Set ids);
}
```

The idea behind this interface is to standardize all common operations
performed with repositories so that it can cover 99% of all use cases.

> There is still 1% left which is a small but nonetheless very important percent
> of use cases. The decision of whether the above interface fits or not should be
> carefully examined and if this interface gives to much of overhead or
> complexity it is usually better to design your own interface which works best
> for the use case.

In order to get the most of this library it is important to understand why
this interface looks like it looks and how is it expected to be used.

### 1.1 Put/Get as opposed to CRUD and Insert/Update/Delete

As you might have noticed there is no distinction between "insert" and
"update" operations in the `Repository` interface.

The roots of this decision goes all the way back to the following question:

> When a life cycle of an entity begins?

Traditional answer of many ORMs and database-centric design in general is: when
the entity is actually stored in a some kind of storage system. This is the
reason why many RDBMS provide "auto-generated" IDs, usually being an auto
incremented integers.

While this approach worked quite well for many years it has some drawbacks to
it:

* For high throughput entities we are likely to reach integer overflow issue.
* Many platforms and runtimes treat integers differently so interoperability
  of such ids also suffers sometimes and leads to unexpected bugs
* Using sequentially increasing integers introduces security risks

This is why many modern storage technologies opted out of using integers in
favor of a bit more sophisticated values like UUIDs, for instance.

There is another conceptually tricky issue with database-issued identifiers.
From the program execution standpoint when we create a new instance of an
entity it will not have it's own identity up until it's persisted, which
means there is a period of time in entity's lifecycle when it's state is
invalid. Which should never be the case.

So in this library we've taken a different approach assuming that entities are
always being created having their identity provided from the very start.
This means that an entity's life cycle starts the moment it's fully loaded
in memory and initialized by our runtime environment.

Repositories in this case serve as "collection-like" containers where we can
"put" our entities and "get" them back.

Obviously this means that we can't rely on database generated IDs anymore, which
is intentional. With this approach we are trying to shift focus away from
details of particular persistence technology and promote domain-centric
workflow for software design.

The `batchPut()` and `batchGet()` methods exist simply to allow more efficient
operations for some use cases.

## 2. Entities and Value Objects

The main `Repository` interface works well mostly for entities, but it won't
work for ValueObject if you happen to need to store them somewhere. So
general advise here would be not to use the `Repository` interface for Value
Objects and use your own use-case-specific abstraction of a repository.

## 3. Complex operations

Sometimes there is a need to perform a complex operation, like update a number
of entities based on certain condition and there is a tendency to extend the
main `Repository` interface with some additional methods to perform such
operation.

The rationale in such cases being that since Repositories are an interface
separating storage layer and domain layer it is responsibility of a Repository
to perform any kind of updates against that storage.

This usually bloats the repository and makes it grow out of control.

Instead, it's better to consider the interface itself as "complete", meaning
there should not be any additions to it. When a use case to perform a more
complex action occurs, the simplest solution would be to create a dedicated
service interface responsible for it.

For example, if we need to archive all blog posts starting from particular
date the service interface can look something like this:

```dart
// goes in domain layer of your project
abstract class ArchiveService {
  Future archivePosts(DateTime createdBefore);
}

// goes in infrastructure layer, assuming MySQL is used as storage
class MySQLArchiveService implements ArchiveService {
  // ...
  Future archivePosts(DateTime createdBefore) {
    // pseudo-code
    mysql.execute(
      'UPDATE posts SET status = "archived" WHERE createdAt < ?',
      [createdBefore]
    );
  }
}
```

# 4. Deleted entities

In short, the assumption here is that entities are never deleted (physically)
from the database. This can be important for many reasons of which can
be performance, security and business requirements.

In real life entities are rarely deleted and usually "deletion" just means
changing of a status of an entity to a meaningful value for a particular
domain.
