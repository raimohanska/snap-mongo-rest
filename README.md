snap-mongo-rest
===============

A simple example of a RESTful web service implemented in Haskell/Snap, with MongoDB backend.

Installation and Running
========================

Install Mongo (Mac : brew install mongodb)
Install GHC >=7 (Mac : brew install haskell-platform)
Install the example:
~~~
cd snap-mongo-rest
cabal install
~~~

You should now have an executable `snap-mongo-rest` that you can run. Make sure the generated executable is on your path and run it.

Testing
=======

You can test it with command-line curl:

~~~
curl -d '{"number":500, "name":"Winston Wolf"}' localhost:8000/employee

=> 4ee74a1128b8fa6367000000

curl localhost:8000/employee/4ee74a1128b8fa6367000000

=> {"name":"Winston Wolf","number":500}
~~~

