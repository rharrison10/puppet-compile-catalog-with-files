Catalog deployment
==================

This is a set of scripts that can be used to create self contained packages of catalogs and its associated files.  These packages can then be distributed to a disconnected host where it will be executed without involvement with the master that generated the catalog.  Only requirement for external connectivity is in the event you are going to manage packages with in these catalogs.  There is currently no solution for generating a local yum, apt, opencsw, etc, etc, and importing those remote packages.

Contents
--------

_compile\_catalog\_with\_files.rb_
