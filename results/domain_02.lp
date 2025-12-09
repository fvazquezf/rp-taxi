#program always.
row(1..1). col(1..4).

% Stations
station(1,4).

% Taxis
taxi(1).
init(at(1,1,2)).
taxi(2).
init(at(2,1,3)).

% Passengers
passenger(a).
init(passenger_at(a,1,1)).