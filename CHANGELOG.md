# 0.6.0

Add connection parameters specifications with connect_to in Docker::API::Connection.

Add Docker::API::Exec methods:
* create
* start
* resize
* inspect

# 0.5.0

Add Docker::API::System methods:
* auth
* ping
* info
* version
* events
* df

Add new response class Docker::API::Response with the following methods:
* json
* path
* success?

Error classes output better error messages.

# 0.4.0

Add Docker::API::Network methods:
* list
* inspect
* create
* remove
* prune
* connect
* disconnect

# 0.3.0

Add Docker::API::Volume methods:
* list
* inspect
* create
* remove
* prune


# 0.2.0

Add Docker::API::Image methods:
* inspect
* history
* list
* search
* tag
* prune
* remove
* export
* import
* push
* commit
* create
* build
* delete_cache

Add Docker::API::System.auth (untested) for basic authentication

# 0.1.0

Add Docker::API::Container methods:
* list
* inspect
* top
* changes
* start
* stop
* restart
* kill
* wait
* update
* rename
* resize
* prune
* pause
* unpause
* remove
* logs
* attach
* create
* stats
* export
* archive