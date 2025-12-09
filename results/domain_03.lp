#program always.
row(1..4). col(1..5).

% Stations
station(4,5).

% Taxis
taxi(1).
init(at(1,1,1)).
taxi(3).
init(at(3,3,1)).

% Passengers
passenger(a).
init(passenger_at(a,1,2)).