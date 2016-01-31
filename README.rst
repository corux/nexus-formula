=============
nexus-formula
=============

.. image:: https://travis-ci.org/corux/nexus-formula.svg?branch=master
    :target: https://travis-ci.org/corux/nexus-formula

Installs the Sonatype Nexus OSS Server.

Available states
================

.. contents::
    :local:

``nexus``
------------

Meta state, which includes ``nexus.nexus2`` or ``nexus.nexus3``, depending on the configured version.

``nexus.nexus2``
----------------

Installs the Nexus 2 server (stable).

``nexus.nexus3``
----------------

Installs the Nexus 3.0 server (technology preview).
