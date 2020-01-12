#include <bits/stdc++.h>
using namespace std;

int main(){
map < string, vector<string> > pred; //ключ-предок, значения - код семьи
map < string, vector <string> > child; //ключ-код семьи, значения - имя ребёнка
map < string, bool > people; 
ifstream fin("FamilyTreeLida.ged");
string str,name,surname,name_surname,sex,index,person;
while(fin >> str){
    if(str == "GIVN"){
        fin >> name;
        fin >> str >> str;
        fin >> surname;
        name_surname = name + " " + surname;
    }
    else if(str == "SEX"){
        fin>>sex;
        if(sex == "M") people[name_surname] = true;
        else people[name_surname] = false;
    }
    else if(str == "FAMC"){ // чей-то ребёнок
        fin >> index;
        child[index].push_back(name_surname);
    }
    else if(str == "FAMS"){ // значит чей-то родитель
        fin >> index;
        pred[name_surname].push_back(index);
    }
}
fin.close();
ofstream fout("output.pl");
vector <string> mother;
for(auto elem : pred){
        person=elem.first;
        for(auto id: elem.second){ // id-код семьи
           for(auto prsn : child[id]){
                if(people[person])fout << "father(\'" << person << "\',\'" << prsn << "\')." << "\n";
                else mother.push_back("mother(\'" + person + "\',\'"+ prsn+ "\')."+"\n");
           }
       }
}
for(auto elem : mother)fout << elem;
fout.close();
return 0;
}
