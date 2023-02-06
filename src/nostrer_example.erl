-module(nostrer_example).

-export([run/0]).

run() ->
    Relay = "relay.damus.io",
    nostrer:connect(Relay).
