# IMPLEMENTATION DETAILS

This document is a guide to this implementation: design, ideas, technical
details, and so on. It may change as issues progress.

## Contact

Contact person for this implementation is Sawyer X.

## Motivation

This implementation tries to take a more modular approach to Act2. While
the other main implementation (branch name forthcoming) modularizes the
data layer, this standardizes the data layer and modularizes everything
else. One could argue (for hours) that this provides modularity - or less,
depending which side of the argument you are in.

The main way I view modularizing in this version is by decoupling multiple
components into stand-alone parts which can be worked on by other
developers, allowing to decentralize the development effort.

This idea came up once I realized the main approach (which I did helped
formalize) seemed to be geared into a single person or two doing the work
and didn't allow others to chip in.

## Design

The main design comes from the concepts of [MetaCPAN](http://metacpan.org)
and the respective client for it,
[MetaCPAN::Client](http://metacpan.org/MetaCPAN::Client), which implements
a proper design for an API consuming using entities.

### Component overview

There are several components, listed in buttom-top order:

* Data storage
* Schema (Act::Schema)
* Web API (Act::Web::API)
* Core API (Act::API)
* Entities (Act::Entity::)
* ResultSets (Act::ResultSet)
* Clients (Act::Web, Act::CLI, scripts, etc.)

### Components in detail

#### Data storage

The data storage is, usually, a database, but could theoretically be
anything [DBIx::Class](http://metacpan.org/DBIx::Class) supports.

We aren't touching the data storage directly at any point.

#### Act::Schema

The schema (of  *DBIx::Class* type) is how we actually access the storage.

#### Act::Web::API

The web API is the interface to the schema. It allows you to fetch
information from the database the way it is. It inflates the results
into a hash and serializes that hash into a JSON response to the web
user.

You can use this interface remotely, locally, wherever you want. Set up a
web server and you can now talk to the storage.

Having a web API has some major benefits:

* The URL spec can be whatever you want

Unlike the Act web interface, the web API can reflect the classes in
whatever format you want. It doesn't have to use the same paths as the
Act website, and can be fully RESTful.

As part of this, the web API paths are currently designed to be consistent,
so any client (see below under **Act::Web** and **Act::CLI**) can create
standardized (think "duck-typed") interfaces for fetching the information.
Thus, the client code is smaller and refactored.

* Add meta-data in requests to allow additional features

The limitation of this approach (see **Disadvantages**) can be mitigated by
adding meta-data in the request to the web API, which could be used to do
whatever one wishes.

This allows you to implement prefetching by adding a `prefetch` as a key
in the meta-data, for example.

* Single point for authentication and authorization

The web API is a single point for authentication and authorization. You
needn't worry about working in different contexts. You're always working
in a web context.

* Decentralize the interface for the data

Since the web API is now available for making requests to the data, the
different interfaces are fully decentralized. A website can run on the
same machine, or even the same process, mounted on a different path in the
same PSGI app, or put on a different server, reaching remotely to the web
API.

#### Act::API

The core act API provides the interface to the web API. It is used to make
requests against the web API and return results (either in *ResultSet*
objects or *Entity* objects).

Since all entities objects are read-only, updating, creating, and deleting
entities is also done using **Act::API**.

The API doesn't actually require anything other than a user agent and the
path to the interface. This part could be abstracted, but since it already
only requires an object, that object really can do many other things and
is only defined by providing simple methods for fetching information.

The core API is what client code connects to. If you're writing an interface
to Act, you have the API to help you. Any piece of core logic should be
placed in the core API, as long as it is shared by others.

For example, if, to display a page, an interface wants to fetch thee tags,
this will not necessarily be in the core API, since this is extra
information, and it is up to the interface to decide what to show.

Thus the core API actually maintains a thin layer for fetching information
and inflating objects back, so the client receives objects to play with.

#### Act::Entity

The entity objects (under the **Act::Entity** namespace) provide an
object-oriented interface to the results returned by the API. They contain
the required information using attributes and could additionally provide a
migration path between current version of Act (AKA, "Legacy") and a newer
version of Act.

**Act::Entity::Event**, for instance, could be an instance (get it?)
representing what Act understands an Event to be. It will have the
appropriate attributes to provide the information.

You cannot (or rather, should not) create entity objects yourself, but
instead have the **Act:API** do that for you. You also cannot use these
entity objects to search for others, nor to call actions, such as
updating or deleting. Those will be handled by the core API as well.

Entities can consume roles that inflate their attributes seamlessly
upon instantiation.

#### Act::ResultSet

The Act ResultSet objects helps the user handle and disambiguate results
that might contain zero to more entities.

The distinction between an Act Entity and an Act ResultSet is simple:
a ResultSet contains entities. A ResultSet has an iterator and provides
information about the entities it has (such as their count).

The Act API is expected to return an Entity when provided with an ID
(since that should correlate to only one result) and a ResultSet in
any other case, since you cannot know how many will be returned.

If you receive a resultset, you will *always* get an object back. You can
either check the amount of items or try to iterate on them. Both will be
safe ways to only call code in case there are entities returned.

Making a request using a HASHREF (which is assured to be a hash reference,
and not just a list) is a sure way to always receive a ResultSet.
Otherwise, a single value is taken as the primary ID for that entity.

#### Act::Web / Act::CLI / etc.

The web interface to Act (**Act::Web**) has the same position as any
command-line client to Act (**Act::CLI**). They provide ways to show the
entities that were received from the web API (using the core API).

They can be used by anyone and positioned anywhere. They should have
configuration options on how to reach the web API, such as a remote or
local address.

The main Act website should simply be run locally on the same machine
as the Act web API.

# Where's the code?

While quite a fair amount of code has been written, it hasn't been pushed
yet but will be done so very soon (before Christmas, that's for sure).

