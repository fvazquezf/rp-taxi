% taxi.lp

% --- GLOBAL DEFINITIONS (Available at all steps) ---
% Define directions mappings (Name, dX, dY)
direction(u, -1, 0). direction(d, 1, 0).
direction(l, 0, -1). direction(r, 0, 1).

#program initial.

% --- INITIAL STATE ---
% Map the input facts to our fluent predicates at time 0
at(T,X,Y) :- init(at(T,X,Y)).
passenger_at(P,X,Y) :- init(passenger_at(P,X,Y)).
% Initially, no one is in a taxi (unless specified, which is rare)
in_taxi(P,T) :- init(in_taxi(P,T)).

#program dynamic.

% --- GENERATE ACTIONS ---
% At each step, for each taxi, choose exactly one action.
{ move(T,D) : direction(D,_,_); pick(T); drop(T); wait(T) } = 1 :- taxi(T).

% --- ACTION EFFECTS ---

% 1. Move: Update position based on direction
at(T, X+DX, Y+DY) :- move(T,D), 'at(T,X,Y), direction(D,DX,DY).

% 2. Pick: Put passenger in taxi
% Note: We use the 'previous' state to check availability
in_taxi(P,T) :- pick(T), 'at(T,X,Y), 'passenger_at(P,X,Y).

% 3. Drop: Put passenger on ground
passenger_at(P,X,Y) :- drop(T), 'at(T,X,Y), 'in_taxi(P,T).

% --- INERTIA (Frame Axioms) ---

% Taxi position stays if not moving
at(T,X,Y) :- 'at(T,X,Y), not move(T,_).

% Passenger stays on ground unless picked
passenger_at(P,X,Y) :- 'passenger_at(P,X,Y), not picked(P).
% Helper to identify if a passenger was picked this step
picked(P) :- pick(T), 'at(T,X,Y), 'passenger_at(P,X,Y).

% Passenger stays in taxi unless dropped
in_taxi(P,T) :- 'in_taxi(P,T), not dropped(P).
% Helper to identify if a passenger was dropped this step
dropped(P) :- drop(T), 'in_taxi(P,T).

% --- ACTION PRECONDITIONS (Constraints) ---

% Move: Cannot move into a wall
:- move(T,D), 'at(T,X,Y), direction(D,DX,DY), wall(X+DX, Y+DY).

% Move: Cannot move off the grid
:- move(T,D), 'at(T,X,Y), direction(D,DX,DY), not row(X+DX).
:- move(T,D), 'at(T,X,Y), direction(D,DX,DY), not col(Y+DY).

% Pick: Cannot pick if no passenger is at the taxi's location
:- pick(T), 'at(T,X,Y), not 'passenger_at(_,X,Y).

% Pick: Cannot pick if taxi is already occupied
:- pick(T), 'in_taxi(_,T).

% Drop: Cannot drop if taxi is empty
:- drop(T), not 'in_taxi(_,T).

% Swap: Two taxis cannot swap positions (e.g., T1 moves L, T2 moves R into each other)
:- move(T1,_), move(T2,_), 'at(T1,X2,Y2), 'at(T2,X1,Y1), at(T1,X1,Y1), at(T2,X2,Y2), T1 < T2.

% Collision: Two taxis cannot be in the same cell
:- at(T1,X,Y), at(T2,X,Y), T1 < T2.

#program final.

% --- GOAL CHECK ---
% All passengers must be at a station
:- passenger(P), not goal_reached(P).

goal_reached(P) :- passenger_at(P,X,Y), station(X,Y).

#show move/2.
#show pick/1.
#show drop/1.
#show wait/1.