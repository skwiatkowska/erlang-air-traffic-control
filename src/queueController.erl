-module(queueController).

-include("object.hrl").


-export([controller/1, compare/2, sendPlanesToController/2]).
-import(dataHandler,[getNPlanes/1]).



sendPlanesToController(Controller, N) ->
    lists:map(
        fun({Name, Type, City, RemTime, DelayTime}) ->
            Controller ! {
                self(),
                #plane{name=Name, type=Type, city=City, remainingTime=RemTime, delayTime=DelayTime}
            }    
        end,
        getNPlanes(N)
    ).



controller(Queue) ->
    receive
	{Source, run} -> %run sim
            Source ! {self(), Queue},
            controller(Queue);


        {_, Plane = #plane{}} -> %add to the queue
            controller(lists:sort(fun compare/2, lists:append(Queue, [Plane])))
        
    end.


compare(Plane1, Plane2) ->
	if
        Plane1#plane.remainingTime == Plane2#plane.remainingTime ->
            Plane1#plane.delayTime > Plane2#plane.delayTime;
        true -> 
            Plane1#plane.remainingTime < Plane2#plane.remainingTime
    end.





