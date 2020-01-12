% Task 2: Relational Data

:- ['two.pl'].

% Напечатать средний балл для каждого предмета
%average_score(Subject,X).
sum([X],X).
sum([X|T],S):-sum(T,S1),S is S1+X.

get_mark(Subject,Mark):- findall(Mrk,grade(_,_,Subject,Mrk),Marks),sum(Marks,S), length(Marks,Len), Mark is S/Len.

mark([H],H,X):-get_mark(H,X),!.
mark([_|T],A,X):- append(_,[H,A|_],[H|T]),mark(T,A,X).
mark(Subj,H,X):- append([H],_,Subj), get_mark(H,X).

average_score(Subject,X):- setof(Y,W^A^X^grade(W,X,Y,A),Subj), mark(Subj,Subject,X).


% Для каждой группы, найти количество не сдавших студентов
% group_dont_pass(Group,Number)


get_dont_pass(Group,Number):- findall(Name,grade(Group,Name,_,2),List),length(List,Number).

dont_pass([H],H,N):-get_dont_pass(H,N),!.
dont_pass([_|T],A,X):- append(_,[H,A|_],[H|T]),dont_pass(T,A,X).
dont_pass(Groups,H,X):- append([H],_,Groups), get_dont_pass(H,X).

group_dont_pass(Group,Number):-setof(Grp,W^A^X^grade(Grp,X,W,A),Groups), dont_pass(Groups,Group,Number).


% Найти количество не сдавших студентов для каждого из предметов
% subjects_dont_pass(Subject,Number)

get_dont_pass2(Subject,Number):- findall(Name,grade(_,Name,Subject,2),List),length(List,Number).

dont_pass_exams([H],H,N):-get_dont_pass2(H,N),!.
dont_pass_exams([_|T],A,X):- append(_,[H,A|_],[H|T]),dont_pass_exams(T,A,X).
dont_pass_exams(Groups,H,X):- append([H],_,Groups), get_dont_pass2(H,X).

subjects_dont_pass(Subject,Number):- setof(Sbjct,W^A^X^grade(W,X,Sbjct,A),Subjects), dont_pass_exams(Subjects,Subject,Number).