-module(nostrer).

-export([generate_key/0, connect/1, loop/0]).

generate_key() ->
    crypto:generate_key(ecdh, secp256k1).

connect(Addr) ->
    io:format("Open~n"),
    {ok, ConnPid} = gun:open(Addr, 443, #{protocols => [http]}),
    io:format("Wait~n"),
    {ok, _Protocol} = gun:await_up(ConnPid),

    io:format("Upgrade~n"),
    gun:ws_upgrade(ConnPid, "/"),

    loop().

loop() ->
    receive
        {gun_upgrade, _ConnPid, _StreamRef, [<<"websocket">>], _Headers} ->
            io:format("Upgrade success~n");
        {gun_response, _ConnPid, _, _, Status, Headers} ->
            io:format("Upgrade failed ~p~n", [{Status, Headers}]),
            exit({ws_upgrade_failed, Status, Headers});
        {gun_error, _ConnPid, _StreamRef, Reason} ->
            io:format("Upgrade failed ~p~n", [Reason]),
            exit({ws_upgrade_failed, Reason});
        Msg ->
            io:format("Msg ~p~n", [Msg])
    after 10000 ->
        io:format("Still waiting~n")
    end,
    nostrer:loop().
