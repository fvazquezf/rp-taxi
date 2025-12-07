% taxi.lp - Temporal ASP Encoding

% --- GLOBAL DEFINITIONS ---
direction(u,-1,0). direction(d,1,0).
direction(l,0,-1). direction(r,0,1).

#program initial.
% Initial fluents
at(T,X,Y) :- init(at(T,X,Y)).
passenger_at(P,X,Y) :- init(passenger_at(P,X,Y)).
in_taxi(P,T) :- init(in_taxi(P,T)).

goal_reached(P) :- passenger_at(P,X,Y), station(X,Y).

#program step(t).
% --- ACTION CHOICES ---
{ move(T,D) : direction(D,_,_) ; pick(T) ; drop(T) ; wait(T) } = 1 :- taxi(T).

% --- ACTION EFFECTS ---
% Move
at(T, X+DX, Y+DY) :-
    move(T,D), @(at(T,X,Y), t-1), direction(D,DX,DY).

% Pick
in_taxi(P,T) :-
    pick(T), @(at(T,X,Y),t-1), @(passenger_at(P,X,Y),t-1).

% Drop
passenger_at(P,X,Y) :-
    drop(T), @(at(T,X,Y),t-1), @(in_taxi(P,T),t-1).

% --- INERTIA ---
at(T,X,Y) :- @(at(T,X,Y),t-1), not move(T,_).

passenger_at(P,X,Y) :-
    @(passenger_at(P,X,Y),t-1),
    not picked(P).

in_taxi(P,T) :-
    @(in_taxi(P,T),t-1),
    not dropped(P).

picked(P) :- pick(T), @(at(T,X,Y),t-1), @(passenger_at(P,X,Y),t-1).
dropped(P) :- drop(T), @(in_taxi(P,T),t-1).

% --- GOAL ---
goal_reached(P) :- passenger_at(P,X,Y), station(X,Y).

% --- CONSTRAINTS ---
% Move validity
:- move(T,D), @(at(T,X,Y),t-1), direction(D,DX,DY),
   wall(X+DX, Y+DY).
:- move(T,D), @(at(T,X,Y),t-1), direction(D,DX,DY),
   not row(X+DX).
:- move(T,D), @(at(T,X,Y),t-1), direction(D,DX,DY),
   not col(Y+DY).

% Pick/Drop validity
:- pick(T), @(at(T,X,Y),t-1), not @(passenger_at(_,X,Y),t-1).
:- pick(T), @(in_taxi(_,T),t-1).
:- drop(T), not @(in_taxi(_,T),t-1).

% Taxi collisions
:- at(T1,X,Y), at(T2,X,Y), T1 < T2.

% Swap positions
:- move(T1,_), move(T2,_),
   @(at(T1,X2,Y2),t-1), @(at(T2,X1,Y1),t-1),
   at(T1,X1,Y1), at(T2,X2,Y2), T1 < T2.

% Passenger collisions
:- passenger_at(P1,X,Y), passenger_at(P2,X,Y), P1 < P2.
:- passenger_at(P1,X,Y), in_taxi(P2,T), at(T,X,Y), P1 != P2.

#program final.
:- passenger(P), not goal_reached(P).

#show move/2.
#show pick/1.
#show drop/1.
#show wait/1.
#show at/3.
#show passenger_at/3.
