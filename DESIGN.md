# THE DESIGN OF ACT

All of the conference management business logic is handled by objects.

The objects that perform the business logic are called *entities*,
and are supplied via an instance of the `Act` class.

The `Act` object encapsulates all the needed context.


## Layered design

The system is organised in layers. Each layer specializes in a particular
aspect of the whole system.

> The essential principle is that any element of a layer depends only on
> the elements in the same layer or on elements of the layer "beneath" it.
> Communication upward must pass through some indirect mechanism.
> 
> Eric Evans, *Domain-Driven Design: Tackling Complexity in the Heart of Software*

In the Act redesign, we have the following layers (descriptions partially
quoted from *Domain-Driven Design*), listed from top to bottom:

* **Presentation layer**: responsible for showing information to the user
  and interpreting the user's commands.
* **Domain layer**: responsible for representing the concepts of the business
  and the business rules.
* **Storage layer**: reponsible for storing the data.
  (This is called the *infrastructure layer* in DDD, because it is actually
  providing generic technical capabilities, of which persitence through a
  database is only a part.)


## Legacy Act application (2004-2014)

Because Act is not written from scratch, but on top of a 10 years old
application, that runs 150+ conferences that we want to continue to
support during and after the transition period, we have to deal with
the legacy.

The legacy Act application is not as cleanly organized as the one we are
trying to build. For example:

- the http handlers mix business logic and presentation
- the presentation layer (templates) sometimes apply access control rules,
- several features have been "bolted on top", without proper design.

To support the legacy conferences, we will use the only cleanly isolated
piece of the old application: the storage layer, i.e. the database
schema (and data) and the corresponding `.ini` files (those live with
the conference-specific data, in the conference repositories).

To prevent the *legacy storage* to leak out into the the *domain layer*,
we have to build an **anti-corruption layer**, that will present an
interface similar to the *storage layer* that would have been built if
starting from scratch.

The *anti-corruption layer* between the *domain layer* and the *legacy
storage layer* lives in the implementation branches.

For various reasons (SEO, a decade of links all over the Internet), we
want to support answering to some of the URL that the legacy application
presents. The "legacy UI" in Act2 is part of the *presentation layer*
and therefore only interacts with the *domain layer*.

Because the legacy conferences repositories contains `.ini` files and
templates that assume they are interacting with objects from the legacy
application (and we don't want to have to touch those repositories),
the *domain layer* will provide the legacy UI with "legacy objects"
that partially support the interfaces of the classes that exist in the
legacy application.

In this sense, Act2 is a [*strangler application*](http://martinfowler.com/bliki/StranglerApplication.html).

## Hard constraints

The following are the only constraints imposed when writing code for Act2:

* any business logic MUST be performed by and through entities
  in the *domain layer*
* no changes are allowed to the legacy database schema
  (this rule will actually be enforced until the legacy Act application
  running on `mod_perl` has been shut down)


## Naming conventions and namespaces

All the elements described below are part of the *domain layer*.

### Act::Interface::

All the modules in the `Act::Interface::` namespace are *interfaces*,
i.e. they `requires` a set of methods to exist (using `Moo::Role`).

All `Act::Interface::` modules live in the `spec` branch.

### Act::Role::

All the modules in the `Act::Role::` namespace provide attributes
or actual method implementations (possibly by consuming other roles).

### Act::Entity::

All the modules in the `Act::Entity::` namespace are classes describing
the entities. They implement the business logic of conference management,
and should only operate at the entity level, oblivious of the data layer.

Each *entity* object must have a corresponding *interface* definition
and implement it.
