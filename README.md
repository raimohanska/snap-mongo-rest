A simple example of a RESTful web service implemented in Haskell/Snap, with MongoDB backend.

The beef is in `src/Employees.hs` and looks like this:

~~~ .haskell

data Employee = Employee { number :: Int, name :: String } deriving (Data, Typeable, Show, Eq)
$(deriveBson ''Employee)

employeeDb = "employee"
employeeCollection = "employee"

postEmployee = method POST $ catchError "Internal Error" $ do 
    employee <- readBodyJson :: Snap Employee
    liftIO $ putStrLn $ "New employee: " ++ (show employee)
    objectId <- liftIO $ mongoPost employeeDb employeeCollection employee
    writeLBS $ JSON.encode $ (objectId) 

getEmployee = jsonGet $ employeeById 

employeeById :: MonadIO m => String -> m (Maybe Employee)
employeeById id = mongoFindOne employeeDb (select ["_id" =: (read id :: ObjectId)] employeeCollection)

mongoPost :: Applicative m => MonadIO m => Bson a => Database -> Collection -> a -> m String
mongoPost db collection x = do val <- doMongo db $ insert collection $ toBson x 
                               case val of
                                  ObjId (oid) -> return $ show oid
                                  _           -> fail $ "unexpected id"

mongoFindOne :: MonadIO m => Bson a => Database -> Query -> m (Maybe a)
mongoFindOne db query = do
                 doc <- doMongo db $ findOne query
                 return (doc >>= (fromBson >=> Just))

doMongo :: MonadIO m => Database -> Action m a -> m a
doMongo db action = do
  pipe <- liftIO $ runIOE $ connect (host "127.0.0.1")
  result <- access pipe master db action
  liftIO $ close pipe
  case result of
    Right val -> return val 
    Left failure -> fail $ show failure
~~~

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

Development
===========

To play around, you can use the script `repl` that fires up GHCI with suitable params.

Then,

~~~ .haskell
Prelude> :l Server
...
*Server> main
...
Listening on http://0.0.0.0:8000/
~~~

`ctrl-C` to stop server. `:r` to reload sources. `main` to run it again.