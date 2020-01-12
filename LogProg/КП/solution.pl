
% проверка пола человека 
check_female(P) :- mother(P,_),!.
check_male(P) :- father(P,_),!.


wife(Person, Wife) :- father(Person, Child), mother(Wife, Child),!.

husband(Wife, Husband) :- mother(Wife,Child), father(Husband, Child),!.

% если у них общие родители, женщина - чья-то мать, мужчина - чей-то отец
sister(Person, Sister) :- father(Father, Person), father(Father, Sister), 
                          not(member(Person,[Sister])), check_female(Sister).
sister(Person, Sister) :- not(father(_, Person)), mother(Mother, Person), mother(Mother, Sister), 
                           not(member(Person,[Sister])), check_female(Sister).


brother(Person, Brother) :- father(Father, Person), father(Father, Brother), 
                            not(member(Person,[Brother])), check_male(Brother).
brother(Person, Brother) :- not(father(_, Person)), mother(Mother, Person), mother(Mother, Brother),  
                            not(member(Person,[Brother])), check_male(Brother).


son(Person, Son) :- father(Person, Son), check_male(Son),!.
son(Person, Son) :- mother(Person, Son), check_male(Son),!.

daughter(Person, D) :-  father(Person, D), check_female(D),!.
daughter(Person, D) :-  mother(Person, D), check_female(D),!.


grandpa(Person, G) :- father(Father, Person), father(G, Father).
grandpa(Person,G) :- mother(Mother, Person), father(G,Mother). 

grandma(Person, G) :- father(Father, Person), mother(G, Father).
grandma(Person,G) :- mother(Mother, Person), mother(G,Mother).

sister_in_law(Person, Sister) :- husband(Person, Husband), setof(S,sister(Husband, S), L), member(Sister,L). 

mam(mother).
dad(father).
grndpa(grandfather).
grndma(grandmother).
sn(son).
dt(daughter).
wf(wife).
hs(husband).
br(brother).
str(sister).
zl(sister_in_law).

% переходы в графе состояний 
move(X,Y,S) :- mother(Y,X), mam(S).
move(X,Y,S) :- father(Y,X), dad(S).
move(X,Y,S) :- grandpa(X,Y), grndpa(S).
move(X,Y,S) :- grandma(X,Y), grndma(S).
move(X,Y,S) :- husband(X,Y), hs(S).
move(X,Y,S) :- wife(X,Y), wf(S).
move(X,Y,S) :- brother(X,Y), br(S).
move(X,Y,S) :- sister(X,Y), str(S).
move(X,Y,S) :- son(X,Y), sn(S).
move(X,Y,S) :- daughter(X,Y), dt(S).
move(X,Y,S) :- sister_in_law(X,Y), zl(S).

                     /* определение степени родства */
% поиск  в глубину 

prolong2([X|T],[Y,X|T],[S1|T2],[S,S1|T2]):-
    move(X,Y,S),
    not(member(Y,[X|T])).
	
path([X|T],X,[X|T], [Y|T2], [Y|T2]).
path(L, Y, R, S1, RS) :- prolong2(L, T, S1, S), path(T,Y,R,S,RS).

dfs_search(X,Y,R,S):-  path([X], Y, R,[start],L), append(S,[Z],L).

% предикат вывода цепочки родственников, который использует поиск в глубину
relatives(S,X,Y) :- dfs_search(X,Y,_,S).


% поиск в ширину 

prolong([X|T],[Y,X|T]):-
    move(X,Y,_),
    not(member(Y,[X|T])).
	
bfs([[X|T]|_],X,[X|T]).

bfs([X|Q],Y,R):-
    findall(P,prolong(X,P),L),
    append(Q,L,QQ),!,
    bfs(QQ,Y,R).
	
bfs([_|Q],Y,R):-
    bfs(Q,Y,R).
	
bfs_search(X,Y,L):-
    bfs([[X]],Y,L1), reverse(L1,L).

% предикат вывода цепочки родственников, который использует поиск в ширину 
relative(L,X,Y) :- bfs_search(X,Y,L1), convert(L1,L).
% получает из цепочки фамилии и имени людей, цепочку родства 
convert([_|[]],[]):-!.
convert([X,Y|T],R) :- move(X,Y,S), append(R1,[S], R), convert([Y|T],R1),!.

is_person(P):- mother(P,_);mother(_,P).
is_person(P):-father(P,_);father(_,P).



    /* естественно-языковой интерфейс */
	
% запоминает имя и фамилию последнего введенного человека мужского или женского пола 
setval_f(S,X):- check_female(X),!,nb_setval(last_female,X);check_female(S),nb_setval(last_female,S).
setval_m(S,X):- check_male(X),!,nb_setval(last_male,X);check_male(S),nb_setval(last_male,S).

% получает нужные имя и фамилию в зависимости от местоимения 
getval(Pr,Value):- member(Pr,[her]),!,nb_getval(last_female,Value).
getval(Pr,Value):- member(Pr,[his]),!,nb_getval(last_male,Value).

question(L):-question(L,[]).
question --> to_be(N), subject_clause(S), object_clause(X,Y,N),question_mark, 
             {first_answer(S,X,Y)},!,{setval_f(S,X), setval_m(S,X) }.
question --> question_word, to_be(N), subject_clause(P), object_clause(P2), question_mark, 
             {second_answer(P,P2,0)},!,{setval_f(P,P2), setval_m(P,P2)}.

question --> question_word, to_be(N), object_clause(X,Y,N), question_mark,
             {second_answer(0,X,Y)},!,{setval_f(_,X)}.
question --> question_words, relation(R,pl),verb_clause(N),subject_clause(P), h(pl), question_mark,
             {change_n(R,R1), third_answer(R1,P)},!,{setval_f(_,P)}.

subject_clause(S) --> person(S).
subject_clause(V) --> pronoun(S1,nq), {change(S1,S3), getval(S3,V)}.
object_clause(S,S2,N) --> person(S),["'s"], relation(S2,N).
object_clause(V,S,N)--> pronoun(S1,q),{getval(S1,V)}, relation(S,N) .
object_clause(V,S,N)--> pronoun(S1,nq), {change(S1,S3), getval(S3,V)}, relation(S,N).
object_clause(S)--> preposition, person(S).
object_clause(V)--> preposition, pronoun(S1,q), {getval(S1,V)}.

verb_clause(N) --> to_be(N).
verb_clause(N) --> qto_be(N).

question_word --> [who].
question_word -->['Who'].
question_words --> [how],[many].
question_words --> ['How'],[many].
question_mark --> [?].
preposition --> [for].
pronoun(S,q) --> {member(S, [his,her])},[S].
pronoun(S,nq)--> {member(S, [he,she])},[S].
h(ss)-->[has].
h(pl)-->[have].
to_be(ss)-->[is].
to_be(ss)-->['Is'].
to_be(pl)-->[are].
to_be(pl)-->['Are'].
qto_be(ss)-->[does].
qto_be(pl)-->[do].

relation(S,ss) --> {member(S, [father, mother, wife, husband, sister, 
                               brother, grandfather, grandmother, son, 
			       daughter, sister_in_law])},[S].
relation(S,pl) --> {member(S, [fathers, mothers, wifes, husbands, sisters, 
                               brothers, grandfathers, grandmothers, sons, 
			       daughters, sisters_in_law])},[S].


person(X) --> {setof(Y,is_person(Y),L), member(X,L)},[X].
% меням значения на другие, чтобы удобнее было искать 
change(he,his).
change(she,her).
% перевод атома в единственное число 
change_n(brothers,brother).
change_n(sisters, sister).
change_n(mothers, mother).
change_n(wifes, wife).
change_n(husbands, husband).
change_n(grandfathers, grandfather).
change_n(grandmothers, grandmother).
change_n(sons, son).
change_n(daughters, daughter).
change_n(sisters_in_law, sister_in_law).

% проверяет нужно ли поменять предикат, чтобы с точки зрения английского языка
% вывод был корректен 
write_n(X,Y,N):- N > 1, change_n(X,Y); X = Y,!.

first_answer(P1,P2,R) :- relatives([R],P2,P1),!,write("YES, "),write(P1),write(" is "),write(P2),write("'s "), 
                         write(R),write("."); 
			 write("NO, "),write(P1),write(" is not "),write(P2),write("'s "), write(R),write(".").
			 
second_answer(0,P2,R) :- relatives([R],P2,P1),!,write(P1),write(" is "),write(P2),write("'s "), write(R),write(".");
                          write("We can't find "), write(P2),write("'s "), write(R), writeln(".").
			  
second_answer(P1,P2,0):- relatives([R],P2,P1),!,write(P1),write(" is "),write(P2),write("'s "), write(R),write(".");
                          write("We don't have enough information about "), write(P1), write(" and "), write(P2), 
			  write(" to answer this question.").						  
						  
third_answer(R,P) :- setof(P1, relatives([R],P,P1), L), length(L, N), !, write(P),write(" has "), write(N), 
                     write_n(X,R,N), write(" "), write(X),write(".");
                     write(P), write(" don't have any "), change_n(X,R), write(X),write(".").
                     



	

father('Alexander Kuptsov', 'Lyudmila Kuptsova').
father('Alexander Kuptsov', 'Anna Kuptsova').
father('Alexey Trofimov', 'Konstantin Trofimov').
father('Andrei Chugin', 'Vasily Chugin').
father('Andrei Chugin', 'Nina Chugin').
father('Vasily Chugin', 'Maria Chugin').
father('Vladimir Kuptsov', 'Irina Kuptsova').
father('Vladimir Kuptsov', 'Sergei Kuptsov').
father('Vyacheslav Patrikeev', 'Lydia Patrikeeva').
father('Vyacheslav Patrikeev', 'Olga Patrikeeva').
father('Gennady Yusov', 'Galina Yusova').
father('Dmitry Tsukanov', 'Lyudmila Tsukanova').
father('Ivan Kuptsov', 'Yuri Kuptsov').
father('Ivan Kuptsov', 'Maria Kuptsova').
father('Leonid Patrikeev', 'Oleg Patrikeev').
father('Leonid Patrikeev', 'Anastasia Patrikeeva').
father('Leonid Patrikeev', 'Ekaterina Patrikeeva').
father('Mikhail Trofimov', 'Maria Trofimova').
father('Mikhail Trofimov', 'Alexey Trofimov').
father('Oleg Patrikeev', 'Vyacheslav Patrikeev').
father('Oleg Patrikeev', 'Elena Patrikeeva').
father('Peter Starikov', 'Antonina Starikova').
father('Peter Starikov', 'Tatiana Starikova').
father('Sergei Kuptsov', 'Elizabeth Kuptsova').
father('Stepan Konov', 'Boris Konov').
father('Yuri Kuptsov', 'Vladimir Kuptsov').
father('Yuri Kuptsov', 'Alexander Kuptsov').
father('Yuri Kuptsov', 'Konstantin Kuptsov').
mother('Alyona Khvorova', 'Yuri Kuptsov').
mother('Alena Khvorova', 'Maria Kuptsova').
mother('Antonina Starikova', 'Maria Trofimova').
mother('Antonina Starikova', 'Alexey Trofimov').
mother('Valentina Ogorodnikova', 'Galina Yusova').
mother('Galina Yusova', 'Irina Kuptsova').
mother('Galina Yusova', 'Sergey Kuptsov').
mother('Evgenia Kolaeva', 'Maria Chugina').
mother('Irina Kuptsova', 'Lydia Patrikeeva').
mother('Irina Kuptsova', 'Olga Patrikeeva').
mother('Leida Pauls', 'Vladimir Kuptsov').
mother('Leida Pauls', 'Alexander Kuptsov').
mother('Leida Pauls', 'Konstantin Kuptsov').
mother('Lyudmila Potapova', 'Konstantin Trofimov').
mother('Maria Trofimova', 'Vyacheslav Patrikeev').
mother('Maria Trofimova', 'Elena Patrikeeva').
mother('Maria Chugina', 'Elizabeth Kuptsova').
mother('Nadezhda Nikitenko', 'Antonina Starikova').
mother('Nadezhda Nikitenko', 'Tatiana Starikova').
mother('Nina Chugina', 'Boris Konov').
mother('Olga Solovushkova', 'Oleg Patrikeev').
mother('Olga Solovushkova', 'Anastasia Patrikeeva').
mother('Olga Solovushkova', 'Ekaterina Patrikeeva').
mother('Tatiana Starikova', 'Lyudmila Tsukanova').
mother('Julia Zhilenkova', 'Lyudmila Kuptsova').
mother('Julia Zhilenkova', 'Anna Kuptsova').


