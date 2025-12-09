#program always.
row(1..5). col(1..10).

% Walls
wall(1,9).
wall(2,2).
wall(2,3).
wall(2,4).
wall(2,5).
wall(2,7).
wall(2,9).
wall(3,5).
wall(3,7).
wall(3,9).
wall(4,2).
wall(4,3).
wall(4,7).
wall(4,9).
wall(5,7).

% Stations
station(1,10).
station(3,10).
station(5,10).

% Taxis
taxi(3).
init(at(3,1,3)).
taxi(1).
init(at(1,3,1)).
taxi(2).
init(at(2,3,6)).

% Passengers
passenger(c).
init(passenger_at(c,1,1)).
passenger(b).
init(passenger_at(b,3,3)).
passenger(a).
init(passenger_at(a,5,3)).