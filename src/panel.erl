-module(panel).

-include("object.hrl").
-export([main/0, simulate/1]).

-import(queueController,[compare/2, sendPlanesToController/2]).
-import(dataHandler,[createNewPlane/0, addNewCity/0, printAllPlanes/0, printAllCities/0, getNumberOfAllPlanes/0]).


main() ->
   options().  




chooseActionPrompt() ->
   NumberOfAction = io:get_line(""),
   case NumberOfAction of
	"1\n" ->
          printAllPlanes(),
	    options();


      "2\n" ->
	    createNewPlane(),
          options(); 


      "3\n" ->
         prepareProcessesBeforeStartSim(),
         chooseActionPrompt();
         
      "4\n" ->
		printAllCities(),
	    	options();

	"5\n" ->
	     addNewCity(),
          options(); 


      "6\n" ->
		quit();
         
 
      _Else ->
	    main()
   end.


options() ->
   io:format("\n\tSYMULATOR RUCHU LOTNICZEGO\n"),
   io:format("1 - pokaz wszystkie samoloty w bazie\n"),
   io:format("2 - dodaj nowy samolot do bazy\n"),
   io:format("3 - SYMULACJA na przykladowych danych\n"),
   io:format("4 - pokaz wszystkie miasta w bazie\n"),
   io:format("5 - dodaj nowe miasto do bazy\n"),
   io:format("6 - wyjscie\n\n\n"),
   chooseActionPrompt().



prepareProcessesBeforeStartSim() ->
   io:format(os:cmd(clear)),

   Pid_controller = spawn(queueController, controller, [[]]),           
   sendPlanesToController(Pid_controller, getNumberOfPlanesToSimulation()),

   Pid_sim = spawn(fun initializeSimulation/0),
   Pid_controller ! {Pid_sim, run},

   Pid_watch_sim = spawn(fun watchOrKillSimulation/0),
   Pid_watch_sim ! {watch, Pid_sim}.





getNumberOfPlanesToSimulation() ->
   io:format("\nPodaj liczbe samolotow:\t"),
   Number = io:get_line(""),
   {X, _} = string:to_integer(Number),

   case X of
      error -> 
         io:format("Bledna wartosc. Podaj liczbe.\n"),
         getNumberOfPlanesToSimulation();
      _Else -> 
         Max = getNumberOfAllPlanes(),
         case X of 
            X when X =< 0 -> 
               io:format("Podaj dodatnia liczbe.\n"),
               getNumberOfPlanesToSimulation();

		 X when X > Max ->
			io:format("W bazie znajduje sie ~p samolotow. Podaj mniejsza liczbe.\n", [Max]),
               getNumberOfPlanesToSimulation();

            _Else ->
               X
         end
      end.



initializeSimulation() ->
   io:format(os:cmd(clear)),
   timer:sleep(800),

   receive
      {_, Queue} ->
         simulate(Queue)
   end.



watchOrKillSimulation() ->
   receive 
        {watch, Pid_sim} ->
            NumberOfAction = io:get_line(""),   
            case NumberOfAction of 
                "x\n" ->
                     exit(Pid_sim, kill),
				main();

                _Else ->
                    watchOrKillSimulation()
            end,
            watchOrKillSimulation()
    end.



simulate(Queue) ->
   timer:sleep(2400),
   io:format(os:cmd(clear)),
   io:format("Wcisnij x, aby przerwac.\n"),
   timer:sleep(400),

   #plane{remainingTime=T} = lists:nth(1, Queue),
   if
	 T =:= 0 -> 
         DelayedQueue = delayPlanesWithTheSameTime(Queue);
       true -> 
         DelayedQueue = Queue
   end,


%sort planes
   SortedQueue = lists:sort(fun queueController:compare/2, DelayedQueue),


%print informations
   lists:foreach(
      fun(Plane) ->
         if 
            Plane#plane.remainingTime =/= 0 ->
               io:format("~s:\t~s - ~s,\t pozostaly czas: ~p, opoznienie: ~p~n", [Plane#plane.name, Plane#plane.type, Plane#plane.city, Plane#plane.remainingTime, Plane#plane.delayTime]);

            true ->  
io:format("~s -> ~s - ~s.~n~n", [Plane#plane.name, Plane#plane.type, Plane#plane.city]),
               timer:sleep(800)
         end
      end,
      SortedQueue
   ), 


%filter
 FilteredQueue = lists:filter(fun(Plane) -> Plane#plane.remainingTime /= 0 end, SortedQueue),



%decrease remainingTime
   DecrementQueue = lists:foldl(
      fun(P = #plane{remainingTime=RemTime}, NewQueue) -> 
         lists:append(NewQueue, [P#plane{remainingTime = RemTime-1}])
      end,
      [],
      FilteredQueue
   ),


   case DecrementQueue of
      D when  D /= [] -> 
         simulate(DecrementQueue);
      _Else -> 
         io:format(os:cmd(clear)),
         options()
   end.


   
%delay other planes when one is landing/starting
delayPlanesWithTheSameTime(Queue) -> 
DelayedQueue = [lists:nth(1, Queue)] ++ lists:foldl(
            fun(Plane = #plane{remainingTime=RemTime, delayTime=DelayTime}, New) ->

               case RemTime of
                  0 -> lists:append(New,[Plane#plane{remainingTime = RemTime+1, delayTime = DelayTime+1}]);
                  _ -> lists:append(New,[Plane])
               end
            end,
            [], 
            lists:nthtail(1, Queue)),
         DelayedQueue.

quit() ->
	halt().

