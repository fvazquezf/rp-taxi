% Grid: 1 Row, 4 Columns
row(1).
col(1..4).

% Static Elements
station(1,4).
% Note: We do NOT define wall(1,1) here. If wall(1,1) exists, the taxi cannot move.

% Dynamic Elements (Initial State)
taxi(1).
init(at(1,1,2)).            % Taxi 1 at (1,2)

passenger(a).
init(passenger_at(a,1,1)).  % Passenger a at (1,1)