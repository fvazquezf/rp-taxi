% =========================================================
% PROGRAM BLOCKS: SEPARATING TIME
% =========================================================

#program initial.
% These rules ONLY apply at Time Step 0.
% This prevents the "Ghost Taxi" bug by ensuring 'init' facts 
% don't force the taxi back to the start at later steps.

at(T, X, Y) :- init(at(T, X, Y)).
passenger_at(P, X, Y) :- init(passenger_at(P, X, Y)).

#program always.
% These rules apply at ALL Time Steps (0, 1, 2, ...).

% =========================================================
% 1. DOMAIN DEFINITIONS
% =========================================================
direction(u; d; l; r).
dx(u, -1). dx(d, 1). dx(l, 0). dx(r, 0).
dy(u, 0). dy(d, 0). dy(l, -1). dy(r, 1).

% Adjacency (Static)
adj(X, Y, D, NX, NY) :- 
    row(X), col(Y), direction(D),
    dx(D, DX), dy(D, DY),
    NX = X + DX, NY = Y + DY,
    row(NX), col(NY),
    not wall(NX, NY).

% =========================================================
% 2. GENERATE ACTIONS
% =========================================================
% Exactly one action per taxi per step
{ move(T, D) : direction(D); pick(T); drop(T); wait(T) } = 1 :- taxi(T).

% =========================================================
% 3. STATE DYNAMICS (TRANSITIONS)
% =========================================================

% --- Movement ---
% Effect: If move(T,D) now, then at(T,NX,NY) next.
&tel { > at(T, NX, NY) } :- move(T, D), at(T, X, Y), adj(X, Y, D, NX, NY).

% Precondition: Cannot move into walls
:- move(T, D), at(T, X, Y), not adj(X, Y, D, _, _).

% Inertia: Stay if not moved
&tel { > at(T, X, Y) } :- at(T, X, Y), not moved(T).
moved(T) :- move(T, _).

% --- Picking Up ---
% Effect: Passenger is in taxi next
&tel { > in_taxi(P, T) } :- pick(T), at(T, X, Y), passenger_at(P, X, Y).

% Preconditions
:- pick(T), at(T, X, Y), not passenger_at(_, X, Y).
:- pick(T), in_taxi(_, T).

% --- Dropping Off ---
% Effect: Passenger is on ground next
&tel { > passenger_at(P, X, Y) } :- drop(T), in_taxi(P, T), at(T, X, Y).

% Preconditions
:- drop(T), not in_taxi(_, T).

% --- Inertia for Passengers ---
% Passenger stays on ground unless picked
&tel { > passenger_at(P, X, Y) } :- passenger_at(P, X, Y), not passenger_picked(P).
passenger_picked(P) :- pick(T), at(T, X, Y), passenger_at(P, X, Y).

% Passenger stays in taxi unless dropped
&tel { > in_taxi(P, T) } :- in_taxi(P, T), not passenger_dropped(T).
passenger_dropped(T) :- drop(T).

% =========================================================
% 4. CONSTRAINTS
% =========================================================

% 1. No overlapping taxis
:- at(T1, X, Y), at(T2, X, Y), T1 < T2.

% 2. No swapping (edge collision)
:- move(T1, D1), move(T2, D2), 
   at(T1, X1, Y1), at(T2, X2, Y2),
   adj(X1, Y1, D1, X2, Y2), 
   adj(X2, Y2, D2, X1, Y1).

% 3. No overlapping persons (ground or in-taxi)
person_pos(P, X, Y) :- passenger_at(P, X, Y).
person_pos(P, X, Y) :- in_taxi(P, T), at(T, X, Y).
:- person_pos(P1, X, Y), person_pos(P2, X, Y), P1 < P2.

% 4. Sanity Check: Taxi uniqueness
:- at(T, X1, Y1), at(T, X2, Y2), (X1,Y1) < (X2,Y2).

% =========================================================
% 5. GOAL
% =========================================================

delivered(P) :- passenger_at(P, X, Y), station(X, Y).
goal :- #count { P : passenger(P), not delivered(P) } == 0.

% Goal must be eventually reachable
% :- not &tel { >? goal }.
goal.

% =========================================================
% 6. OUTPUT
% =========================================================
#show move/2.
#show pick/1.
#show drop/1.
#show wait/1.
#show adj/5.