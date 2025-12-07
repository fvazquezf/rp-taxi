% taxi.lp

% --- GLOBAL DEFINITIONS ---
direction(u, -1, 0). direction(d, 1, 0).
direction(l, 0, -1). direction(r, 0, 1).

#program initial.
% --- INITIAL STATE ---
at(T,X,Y) :- init(at(T,X,Y)).
passenger_at(P,X,Y) :- init(passenger_at(P,X,Y)).
in_taxi(P,T) :- init(in_taxi(P,T)).

% Define goal_reached at step 0
goal_reached(P) :- passenger_at(P,X,Y), station(X,Y).

#program dynamic.
% --- GENERATE ACTIONS ---
{ move(T,D) : direction(D,_,_); pick(T); drop(T); wait(T) } = 1 :- taxi(T).

% --- ACTION EFFECTS ---
% 1. Move
at(T, X+DX, Y+DY) :- move(T,D), 'at(T,X,Y), direction(D,DX,DY).

% 2. Pick
in_taxi(P,T) :- pick(T), 'at(T,X,Y), 'passenger_at(P,X,Y).

% 3. Drop
passenger_at(P,X,Y) :- drop(T), 'at(T,X,Y), 'in_taxi(P,T).

% --- INERTIA ---
at(T,X,Y) :- 'at(T,X,Y), not move(T,_).

% Passenger stays on ground unless picked
passenger_at(P,X,Y) :- 'passenger_at(P,X,Y), not picked(P).
picked(P) :- pick(T), 'at(T,X,Y), 'passenger_at(P,X,Y).

% Passenger stays in taxi unless dropped
in_taxi(P,T) :- 'in_taxi(P,T), not dropped(P).
dropped(P) :- drop(T), 'in_taxi(P,T).

% --- AUXILIARY ---
% Calculate goal_reached at every step t > 0
goal_reached(P) :- passenger_at(P,X,Y), station(X,Y).

% --- CONSTRAINTS ---
% Movement limits
:- move(T,D), 'at(T,X,Y), direction(D,DX,DY), wall(X+DX, Y+DY).
:- move(T,D), 'at(T,X,Y), direction(D,DX,DY), not row(X+DX).
:- move(T,D), 'at(T,X,Y), direction(D,DX,DY), not col(Y+DY).

% Pick/Drop validity
:- pick(T), 'at(T,X,Y), not 'passenger_at(_,X,Y).
:- pick(T), 'in_taxi(_,T).
:- drop(T), not 'in_taxi(_,T).

% Collisions
:- at(T1,X,Y), at(T2,X,Y), T1 < T2.
:- move(T1,_), move(T2,_), 'at(T1,X2,Y2), 'at(T2,X1,Y1), at(T1,X1,Y1), at(T2,X2,Y2), T1 < T2.

% Person Collisions (Prevent overlap)
:- passenger_at(P1,X,Y), passenger_at(P2,X,Y), P1 < P2.
:- passenger_at(P1,X,Y), in_taxi(P2,T), at(T,X,Y), P1 != P2.

#program final.
% --- GOAL CHECK ---
% This now checks the 'goal_reached' fluent derived in the current step
:- passenger(P), not goal_reached(P).

% --- OUTPUT ---
#show move/2.
#show pick/1.
#show drop/1.
#show wait/1.
#show at/3.
#show passenger_at/3.