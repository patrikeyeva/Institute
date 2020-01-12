% Place your solution here

unique([]):-!.
unique([Head|Tail]):-member(Head, Tail), !, fail;unique(Tail).

not(Goal):-Goal,!, fail;true.

family(son).
family(wife).
family(husband).
family(wifes_father).
family(husband_sister).

male(son).
male(husband).
male(wifes_father).

hasbrother(husband_sister).

younger(son, husband).
younger(son, wife).
younger(son, wifes_father).
younger(wife, wifes_father).
younger(X,X):- true.

not_blood_relatives(X, Y):- not_blood_relative(X,Y);not_blood_relative(Y, X).
not_blood_relative(husband, wife).
not_blood_relative(husband_sister, wife).
not_blood_relative(wife_father, husband).
not_blood_relative(husband_sister, wifes_father).

solve(A,B,C,D,E):- member(person(A, slesar),Solve), member(person(B, economist), Solve),
                   member(person(C, teacher), Solve), member(person(D, lawyer), Solve),
                   member(person(E, engineer), Solve), solve2(Solve), !.

solve2(Solve):-
Solve = [ person(Slesar_name, slesar), person(Economist_name, economist), person(Teacher_name, teacher), person(Lawyer_name, lawyer), person(Engineer_name, engineer)],
family(Slesar_name), family(Economist_name), family(Teacher_name), family(Lawyer_name), family(Engineer_name), 
unique([Slesar_name, Economist_name, Teacher_name, Lawyer_name,Engineer_name]),
not_blood_relatives(Lawyer_name, Teacher_name), male(Economist_name), hasbrother(Engineer_name),
not(younger(Economist_name, Slesar_name)), not(younger(Engineer_name, wife)),
not(younger(Teacher_name, Engineer_name)), not(younger(Teacher_name, wife)).


% solve(Slesar, Economist, Teacher, Lawyer, Engineer).
