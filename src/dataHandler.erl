-module(dataHandler).

-include("object.hrl").

-compile(export_all).



createNewPlane() ->
   Name = io:get_line("Nazwa samolotu: "),
   file:write_file("./src/database/planes.txt", "\n" ++ Name, [append]),
   io:format("Utworzono nowy samolot ~s~n", [Name]),
   timer:sleep(1000).



addNewCity() ->
   Name = io:get_line("Nazwa miasta: "),
   file:write_file("./src/database/cities.txt", "\n" ++ Name, [append]),
   io:format("Do bazy dodano nowe miasto: ~s~n", [Name]),
   timer:sleep(1000).



printAllPlanes() ->
   io:format("Samoloty w bazie:\n"),
   Planes = parseFile("./src/database/planes.txt"),
   io:format("~p~n~n~n", [Planes]),
   timer:sleep(1000).



printAllCities() ->
   io:format("Miasta w bazie:\n"),
   Cities = parseFile("./src/database/cities.txt"),
   io:format("~p~n~n~n", [Cities]),
   timer:sleep(1000).



getNumberOfAllPlanes() ->
   Planes = parseFile("./src/database/planes.txt"),
   length(Planes).   



parseFile(FileName) ->
    {ok, Binary} = file:read_file(FileName),
    string:tokens(erlang:binary_to_list(Binary), "\r\n").



randomPlane() ->
    Planes = parseFile("./src/database/planes.txt"),
    Cities = parseFile("./src/database/cities.txt"),
    Type = [ladowanie, startowanie],
    {
        lists:nth(rand:uniform(length(Planes)), Planes),
        lists:nth(rand:uniform(length(Type)), Type),
        lists:nth(rand:uniform(length(Cities)), Cities),
        rand:uniform(10),
        rand:uniform(5)
    }.


getNPlanes(N) ->
    lists:foldr(
        fun(_,Acc) -> lists:append(Acc,[randomPlane()]) end,
        [],
        lists:seq(1,N)
    ).

