#program always.
row(1..1). col(1..8).

% Stations
station(1,7).
station(1,8).

% Taxis
taxi(1).
init(at(1,1,1)).
taxi(2).
init(at(2,1,6)).

% Passengers
passenger(a).
init(passenger_at(a,1,3)).
passenger(b).
init(passenger_at(b,1,4)).