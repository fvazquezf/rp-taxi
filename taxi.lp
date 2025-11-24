% =========================================================
% 1. DOMAIN DEFINITIONS AND HELPERS
% =========================================================

direction(u; d; l; r).
dx(u, -1). dx(d, 1). dx(l, 0). dx(r, 0).
dy(u, 0). dy(d, 0). dy(l, -1). dy(r, 1).

% Adjacency map (static)
adj(X, Y, D, NX, NY) :- 
    row(X), col(Y), direction(D),
    dx(D, DX), dy(D, DY),
    NX = X + DX, NY = Y + DY,
    row(NX), col(NY),
    not wall(NX, NY).

% Helper: 'initial' is true ONLY at step 0 (when there is no past)
initial :- not &tel { < &true }.

% =========================================================
% 2. GENERATE ACTIONS
% =========================================================

% Exactly one action per taxi per step
{ move(T, D) : direction(D); pick(T); drop(T); wait(T) } = 1 :- taxi(T).

% =========================================================
% 3. STATE DYNAMICS
% =========================================================

% --- Initialization (CORRECTED) ---
% Only load 'init' facts if we are in the initial state.
at(T, X, Y) :- init(at(T, X, Y)), initial.
passenger_at(P, X, Y) :- init(passenger_at(P, X, Y)), initial.

% --- Movement ---
% Effect: Move updates position
&tel { > at(T, NX, NY) } :- move(T, D), at(T, X, Y), adj(X, Y, D, NX, NY).

% Precondition: Cannot move into wall
:- move(T, D), at(T, X, Y), not adj(X, Y, D, _, _).

% Inertia: Stay if not moved
&tel { > at(T, X, Y) } :- at(T, X, Y), not moved(T).
moved(T) :- move(T, _).

% --- Picking Up ---
% Effect: Passenger enters taxi
&tel { > in_taxi(P, T) } :- pick(T), at(T, X, Y), passenger_at(P, X, Y).

% Preconditions:
:- pick(T), at(T, X, Y), not passenger_at(_, X, Y). % No passenger here
:- pick(T), in_taxi(_, T).                          % Taxi full

% --- Dropping Off ---
% Effect: Passenger leaves taxi
&tel { > passenger_at(P, X, Y) } :- drop(T), in_taxi(P, T), at(T, X, Y).

% Preconditions:
:- drop(T), not in_taxi(_, T).                      % Taxi empty

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

% 1. Collision: Two taxis cannot be in the same cell
:- at(T1, X, Y), at(T2, X, Y), T1 < T2.

% 2. Swapping: Edge collision
:- move(T1, D1), move(T2, D2), 
   at(T1, X1, Y1), at(T2, X2, Y2),
   adj(X1, Y1, D1, X2, Y2), 
   adj(X2, Y2, D2, X1, Y1).

% 3. Overlap: Two people (in taxi or on ground) cannot be in same cell
person_pos(P, X, Y) :- passenger_at(P, X, Y).
person_pos(P, X, Y) :- in_taxi(P, T), at(T, X, Y).
:- person_pos(P1, X, Y), person_pos(P2, X, Y), P1 < P2.

% 4. SANITY CHECK: A taxi cannot be in two places at once
% (This catches the ghost taxi bug if initialization fails)
:- at(T, X1, Y1), at(T, X2, Y2), (X1,Y1) < (X2,Y2).

% =========================================================
% 5. GOAL
% =========================================================

% Delivered if at station and NOT in a taxi (implied by passenger_at logic)
delivered(P) :- passenger_at(P, X, Y), station(X, Y).

% Goal: All passengers delivered
goal :- #count { P : passenger(P), not delivered(P) } == 0.

% Enforce Goal: It must eventually be true
:- not &tel { >? goal }.

% =========================================================
% 6. OUTPUT
% =========================================================
#show move/2.
#show pick/1.
#show drop/1.
#show wait/1.