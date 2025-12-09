#program always.
row(1..5). col(1..9).

% Walls
wall(2,2).
wall(2,4).
wall(2,5).
wall(2,6).
wall(2,7).
wall(2,8).
wall(3,2).
wall(3,4).
wall(3,5).
wall(3,6).
wall(3,7).
wall(3,8).
wall(4,2).
wall(4,4).
wall(4,5).
wall(4,6).
wall(4,7).
wall(4,8).

% Stations
station(5,5).
station(5,7).

% Taxis
taxi(1).
init(at(1,1,1)).
taxi(2).
init(at(2,1,9)).

% Passengers
passenger(a).
init(passenger_at(a,2,3)).
passenger(b).
init(passenger_at(b,4,3)).