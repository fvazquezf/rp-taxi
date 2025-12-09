% ==============================================================================
% INITIAL STATE
% ==============================================================================
#program initial.

at(T,X,Y) :- init(at(T,X,Y)).
passenger_at(P,X,Y) :- init(passenger_at(P,X,Y)).

% ==============================================================================
% DYNAMIC STATE (Transitions)
% ==============================================================================
#program dynamic.

% Directions can also be always, but dynamic works if defined here
direction(u,-1,0). direction(d,1,0). direction(l,0,-1). direction(r,0,1).

% 1. Generate Actions
% Requires taxi(T) to be present in the current step (provided by #program always)
1 { move(T,D) : direction(D,_,_); pick(T); drop(T); wait(T) } 1 :- taxi(T).

% 2. Effects & Inertia

% Movement logic
target_pos(T, X+DX, Y+DY) :- move(T,D), 'at(T,X,Y), direction(D,DX,DY).
target_pos(T, X, Y)       :- wait(T), 'at(T,X,Y).
target_pos(T, X, Y)       :- pick(T), 'at(T,X,Y).
target_pos(T, X, Y)       :- drop(T), 'at(T,X,Y).

at(T,X,Y) :- target_pos(T,X,Y).

% Passenger logic
picked(P,T)  :- pick(T), 'at(T,X,Y), 'passenger_at(P,X,Y).
in_taxi(P,T) :- picked(P,T).
in_taxi(P,T) :- 'in_taxi(P,T), not drop(T).

dropped(P,T)        :- drop(T), 'in_taxi(P,T).
passenger_at(P,X,Y) :- dropped(P,T), 'at(T,X,Y).
passenger_at(P,X,Y) :- 'passenger_at(P,X,Y), not picked(P,_).

% 3. Constraints

% Standard constraints
:- at(T,X,Y), wall(X,Y).
:- at(T,X,Y), not row(X).
:- at(T,X,Y), not col(Y).
:- at(T1,X,Y), at(T2,X,Y), T1 < T2.
:- move(T1,_), move(T2,_), 'at(T1,X1,Y1), 'at(T2,X2,Y2), at(T1,X2,Y2), at(T2,X1,Y1), T1 < T2.
:- passenger_at(P1,X,Y), passenger_at(P2,X,Y), P1 < P2.
:- at(T,X,Y), in_taxi(_,T), passenger_at(_,X,Y).

% Action validity
:- pick(T), 'in_taxi(_,T).
:- pick(T), 'at(T,X,Y), not 'passenger_at(_,X,Y).
:- drop(T), not 'in_taxi(_,T).

% ==============================================================================
% FINAL STATE (Goal)
% ==============================================================================
#program final.

at_dest(P) :- passenger_at(P,X,Y), station(X,Y).
% Requires passenger(P) to be present in the final step (provided by #program always)
:- passenger(P), not at_dest(P).

% ==============================================================================
% OUTPUT
% ==============================================================================
#show move/2.
#show pick/1.
#show drop/1.
#show wait/1.