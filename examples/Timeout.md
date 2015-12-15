# Timeout

This example assumes you have a configured Twitter REST `client`. Instructions
on how to configure a client can be found in [examples/Configuration.md][cfg].

[cfg]: https://github.com/sferik/twitter/blob/master/examples/Configuration.md

The REST client supports network timeout settings.  Timeout settings are supplied
in the options argument to REST calls.
Timeout settings are specified as in the [Ruby HTTP library][http_lib].
Per-operation timeouts are specified using the `per_operation_timeout` key, and global timeouts are specified
using the `global_timeout` key.

[http_lib]: https://github.com/httprb/http#timeouts

Here's an example of how to get Justin Bieber's followers, with a 10 second timeout on read:
```ruby
client.follower_ids('justinbieber', per_operation_timeout: {read: 10})
```
