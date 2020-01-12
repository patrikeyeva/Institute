
%подсчитывает кол-во вхождений элемента в список 
counter([], _, 0).
counter([X|T], X, M) :- !, counter(T, X, N), M is N+1.
counter([_|T], X, N) :- counter(T, X, N).


find([H|L], H, L) :- !.
find([H|L], X, [H|L1]) :- find(L, X, L1).

% разность множеств (списков)
subtraction(L, [], L) :- !.
subtraction([X|T], [X|T1], L) :- !,  subtraction(T, T1, L).
subtraction([H|T], L, L3) :- find(L, H, L2), !, subtraction(T, L2, L3).
subtraction([H|T], L, [H|L2]) :- subtraction(T, L, L2).

equal(L, X) :- subtraction(L, X, []).

list_member(p(X, N), [p(H, M)|_]) :- N = M, equal(X, H), !.
list_member(X, [_|T]) :- list_member(X, T), !.


% проверка на то, что каннибалов не больше миссионеров
check_safe(X, Y) :- X >= Y, !.
check_safe(X, _) :- X = 0, !.

% состояния в лодке

boat(["К", "М", "М"]).
boat(["К", "К", "К"]).
boat(["М", "М", "М"]).
boat(["К"]).
boat(["М"]).
boat(["К", "М"]).
boat(["М", "М"]).
boat(["К", "К"]).


% предикат move определяет переходы в графе состояний 

move(Left, New_left, 1) :-
  boat(Between),
  subtraction(Left, Between, New_left),
  counter(New_left, "К", N1),
  counter(New_left, "М", N2),
  check_safe(N2, N1),
  subtraction(["К", "К", "К", "М", "М", "М"], New_left, New_right),
  counter(New_right, "К", N3),
  counter(New_right, "М", N4),
  check_safe(N4, N3).

move(Right,New_right, 2) :-
  boat(Between),
  subtraction(New_right, Between, Right),
  counter(New_right, "К", N1),
  counter(New_right, "М", N2),
  check_safe(N2, N1),
  subtraction(["К", "К", "К", "М", "М", "М"], New_right, New_left),
  counter(New_left, "К", N3),
  counter(New_left, "М", N4),
  check_safe(N4, N3).


% предикат продления пути с проверкой на зацикливание

prolong([p(X, 1)|T], [p(Y, 2), p(X, 1)|T]):-
  move(X, Y, 1),
  not(list_member(p(Y, 2), [p(X, 1)|T])).

prolong([p(X, 2)|T], [p(Y, 1), p(X, 2)|T]):-
  move(X, Y, 2),
  not(list_member(p(Y, 1), [p(X, 2)|T])).

% поиск в глубину

dfs_path([p(X, 2)|T], X, [p(X, 2)|T]).

dfs_path([p(R, N)|P], X, L):- prolong([p(R, N)|P], P1), dfs_path(P1, X, L).


dfs_search(Before, After):-
 get_time(Time1),
 % N is 20,     % N ограничивает кол-во перемещений по реке, т.е. выведутся пути, состоящие не более, чем из 20 действий
 dfs_path([p(Before, 1)], After, L),
 get_time(Time2),
 % length(L, N2), N <= N2,       % каждый раз будет искаться путь, который короче или равен предыдущему
 T is Time2 - Time1,
 write('Time is '),
 write(T), writeln(' sec'),
 output(L,1).
 % N is N2.


% поиск в ширину

bfs_path([[p(X, 2)|T]|_], X, [p(X, 2)|T]).

bfs_path([B|P], X, L):-
  findall(W, prolong(B, W), Q),
  append(P, Q, QP),
  !, bfs_path(QP, X, L);
  bfs_path(P, X, L).

 bfs_search(Before, After):-
  get_time(Time1), 
  % N is 20,
  bfs_path([[p(Before, 1)]], After, L),
  get_time(Time2),
  T is Time2 - Time1,
  % length(L, N2), N <= N2,
  write('Time is '),
  write(T), 
  writeln(' sec'),
  output(L,1).

% поиск с итерационным углублением

natural(1).
natural(B) :- natural(A), B is A + 1.

itdpth([p(A, 2)|T], A, [p(A, 2)|T], 0).

itdpth(P, A, L, N) :-
  N > 0,
  prolong(P, Pl),
  Nl is N - 1,
  itdpth(Pl, A, L, Nl).

id_search(Before, After) :-
  get_time(Time1),
  natural(N),
  itdpth([p(Before, 1)], After, L, N),
  get_time(Time2),
  T is Time2 - Time1,
  write('Time is '),
  write(T),
  writeln(' sec'),
  output(L,1), !.

% предикат печати списка в понятной форме

output([p(X, 1)],_):- write("Left bank:"), write(X), subtraction(["К", "К", "К", "М", "М", "М"], X, Y), write(' --- '), write("Right bank:"), writeln(Y).
output([p(X, _)|T],1):- output(T,2), write("Left bank:"), write(X), subtraction(["К", "К", "К", "М", "М", "М"], X, Y), write('-->'), write("Right bank:"), writeln(Y).
output([p(X, _)|T],2):- output(T,1), write("Left bank:"), write(X), subtraction(["К", "К", "К", "М", "М", "М"], X, Y), write('<--'), write("Right bank:"), writeln(Y).

 % dfs_search(["К", "К", "К", "М", "М", "М"],[]).
 % bfs_search(["К", "К", "К", "М", "М", "М"],[]).
 % id_search(["К", "К", "К", "М", "М", "М"],[]).