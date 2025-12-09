#program always.
row(1..3). col(1..8).

% Walls
wall(2,4).
wall(2,5).
wall(2,6).

% Stations
station(1,8).
station(3,8).

% Taxis
taxi(1).
init(at(1,2,1)).

% Passengers
passenger(a).
init(passenger_at(a,1,2)).
passenger(b).
init(passenger_at(b,2,2)).