#program always.
row(1..4). col(1..5).

% Walls
wall(3,4).

% Stations
station(1,5).
station(2,5).
station(3,5).
station(4,5).

% Taxis
taxi(1).
init(at(1,1,1)).
taxi(2).
init(at(2,2,1)).
taxi(3).
init(at(3,3,1)).

% Passengers
passenger(a).
init(passenger_at(a,1,2)).
passenger(b).
init(passenger_at(b,2,2)).
passenger(c).
init(passenger_at(c,3,2)).
passenger(d).
init(passenger_at(d,4,2)).