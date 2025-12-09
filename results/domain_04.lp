#program always.
row(1..4). col(1..9).

% Walls
wall(2,2).
wall(2,3).
wall(2,4).
wall(2,5).
wall(2,6).
wall(2,7).
wall(2,8).
wall(3,2).
wall(3,8).

% Stations
station(3,5).

% Taxis
taxi(1).
init(at(1,3,1)).

% Passengers
passenger(a).
init(passenger_at(a,1,5)).