Catalog deployment
==================

This is a set of scripts that can be used to create self contained packages of catalogs and its associated files.  These packages can then be distributed to a disconnected host where it will be executed without involvement with the master that generated the catalog.  Only requirement for external connectivity is in the event you are going to manage packages with in these catalogs.  There is currently no solution for generating a local yum, apt, opencsw, etc, etc, and importing those remote packages.  For best results you should adhere strictly to the best practices associated with the Puppet modules.

Contents
--------

__compile\_catalog\_with\_files.rb__:  

* This is the script that is ran on the Puppet master to build the catalog package.
* The reference node name used needs to have its facts stored locally or accessible via the inventory service.
* Generates a gzipped tar file named `agent_1.compiled_catalog_with_files.tar.gz`
* This generated tar is what you deploy to disconnected machines.
* Basic usage: `compile_catalog_with_files.rb --node agent_1`

__apply\_catalog\_with\_files.rb__:  

* Script that ingests the package generated on the master.
* Builds unique temporary working directory using Puppet.
* Unpacks package into unique temporary location.
* Runs `puppet apply` with the temporary directory as its modulepath.
* Cleans up temporary directory.
* Basic usage: `apply_catalog_with_files.rb --nodefile /root/agent_1.compiled_catalog.with_files.tar.gz`
