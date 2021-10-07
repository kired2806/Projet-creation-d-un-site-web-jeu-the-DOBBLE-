drop table estJoue;
drop table Init;
--drop table Contient;
--drop table Symbole;
--drop table Carte;
drop table Partie;
drop table Joueur;
drop table Difficulte;



create table Difficulte (
    IdNiveau Number,
    Description VARCHAR(200),
    NbSymCarte NUMBER,
    TempsOrdiMin NUMBER,
    TempsOrdiMax NUMBER,
    CoeffScore NUMBER,
    Constraint pk_IdNiveau primary key (IdNiveau),
    Constraint ck_IdNiveau check (IdNiveau in (1, 2, 3)),
    Constraint nn_descriptinos check (Description is not null),
    Constraint nn_NbSymCarte check (NbSymCarte is not null),
    Constraint ck_NbSymCarte check (NbSymCarte in (6, 8, 10)),
    Constraint ck_TempsOrdiMin check (TempsOrdiMin > 0),
    Constraint ck_TempsOrdiMax check (TempsOrdiMax > TempsOrdiMin),
    Constraint ck_CoeffScore check (CoeffScore > 0),
    Constraint nn_CoeffScore check (CoeffScore is not null)
);

ALTER TABLE Difficulte
    ADD malus number;

-- Trigger qui v�rifient que le niveau de difficult� a la cr�ation du compte est bien de 1;

create table Joueur (
    Username VARCHAR(20),
    MDP VARCHAR(40),
    Age NUMBER(3),
    Pseudo VARCHAR(10),
    NiveauMaxActuel NUMBER,
    Constraint pk_Joueur primary key (Username),
    Constraint fk_Joueur_Difficulte foreign key (NiveauMaxActuel) references Difficulte,
    Constraint nn_MDP check (MDP is not null),
    Constraint ck_MDP check (length(MDP) >= 5),
    Constraint nn_Pseudo check (Pseudo is not null),
    Constraint ck_Pseudo check (length(Pseudo) >= 3 and length(Pseudo) <= 10),
    Constraint uni_Pseudo UNIQUE(Pseudo),
    Constraint ck_Age check (Age >= 6),
    Constraint ck_Username check (length(Username) >= 4 and length(Username) <= 20),
    Constraint nn_NiveauMaxActuel check (NiveauMaxActuel is not null)
);

create table Partie(
    IdPartie NUMBER, --Sequence
    Duree NUMBER,
    Note NUMBER,
    Commentaire VARCHAR(100),
    DatePartie DATE,
    NiveauPartie NUMBER,
    Username VARCHAR(20),
    Constraint pk_Partie primary key (IdPartie),
    Constraint fk_Partie_Difficulte foreign key (NiveauPartie) references Difficulte,
    Constraint fk_Partie_Joueur foreign key (Username) references Joueur,
    Constraint ck_Duree check (Duree > 0),
    Constraint ck_note check (note >= 1 and note <= 5),
    Constraint nn_DatePartie check (DatePartie is not null),
    Constraint nn_NiveauPartie check (NiveauPartie is not null),
    Constraint nn_Username check (Username is not null)
);

create table Carte (
    IdCarte NUMBER, --Sequence
    IdNiveau NUMBER,
    Constraint pk_Carte primary key (idCarte),
    Constraint fk_IdNiveau foreign key (IdNiveau) references Difficulte (IdNiveau),
    Constraint nn_IdNiveau check (IdNiveau is not null)
);

Create table Symbole (
    IdSymbole NUMBER,
    SymbPath varchar(50),
    Constraint pk_Symbole primary key (IdSymbole),
    Constraint nn_SymbPath check (SymbPath is not null),
    Constraint uni_SymbPath UNIQUE (SymbPath)
);

Create table Contient (
    IdCarte NUMBER,
    IdSymbole NUMBER,
    Position NUMBER,
    Constraint pk_Contient primary key (IdCarte, IdSymbole),
    Constraint fk_Contient_Carte foreign key (IdCarte) references Carte (IdCarte),
    Constraint fk_Contient_Symbole foreign key (IdSymbole) references Symbole (IdSymbole),
    Constraint uni_IdCarte_Position UNIQUE(IdCarte, Position)
);

create table Init (
    IdCarte NUMBER,
    IdPartie NUMBER,
    PositionInit NUMBER, -- 0 joueur, 1 ordi, 2 pioche
    Constraint pk_Init primary key (IdCarte, IdPartie),
    Constraint fk_Init_Carte foreign key (IdCarte) references Carte (IdCarte),
    Constraint fk_Init_Partie foreign key (IdPartie) references Partie (IdPartie),
    Constraint ck_PositionInit check (PositionInit in (0, 1, 2)),
    Constraint nn_PositionInit check (PositionInit is not null)
);

create table estJoue (
    IdPartie NUMBER,
    IdCarte NUMBER,
    TempJoue NUMBER,
    EstJoueur NUMBER, -- 1 = Joueur qui joue / 0 = Ordi qui joue
    EstGagnant NUMBER, -- 1 = Gagant / 0 = Perdant
    PositionCoup NUMBER,
    Constraint pk_estJoue primary key (IdPartie, IdCarte, TempJoue),
    Constraint fk_estJoue_Carte foreign key (IdCarte) references Carte (IdCarte),
    Constraint fk_estJoue_Partie foreign key (IdPartie) references Partie (IdPartie),
    Constraint ck_TempJoue check (TempJoue > 0),
    Constraint nn_EstJoueur check (EstJoueur is not null),
    Constraint nn_EstGagnant check (EstGagnant is not null),
    Constraint ck_EstJoueur check (EstJoueur in (0, 1)),
    Constraint ck_EstGagnant check (EstGagnant in (0, 1)),
    Constraint nn_PositionCoup check (PositionCoup is not null)
);

drop sequence seqIdSymbole;
create sequence seqIdSymbole
    START WITH 1 increment by 1;

drop sequence seqIdCarte;
create sequence seqIdCarte
    START WITH 1 increment by 1;

--================================================================== TEST ==================================================================

create or replace function fct (fnom number) return number as
BEGIN
    return(fnom**2);
end;
/

drop table tes;

create table tes (
    IdTes number,
    val number
);

insert into tes values (1, 2);
insert into tes values (2, 2);
insert into tes values (3, 3);

select fct(IdTes) from tes;

select (TO_CHAR(SYSDATE, 'DD/MM/YYYY')) from dual;

select to_char(SYSDATE, 'DD/MM/YYYY') from dual;
select to_number(to_char(SYSDATE, 'HH24')) from dual;

select  curdate();


select to_char(moins_une_heure(TO_DATE('2019/03/01 00:02:44', 'yyyy/mm/dd hh24:mi:ss')), 'DD/MM/YYYY HH24:MI:SS'), TO_CHAR(TO_DATE('2019/03/01 00:02:44', 'yyyy/mm/dd hh24:mi:ss'), 'DD/MM/YYYY HH24:MI:SS') from dual;
select to_char(moins_quatre_heure(SYSDATE), 'DD/MM/YYYY HH24:MI:SS'), TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') from dual;

select * from v_HighScore where to_char(datePartie, 'DD/MM/YYYY') = to_char(SYSDATE, 'DD/MM/YYYY');


set serveroutput on
DECLARE
    curDate DATE;
    testDate DATE := to_date('2020/02/18 14:20:44', 'yyyy/mm/dd hh24:mi:ss');
    compteur NUMBER;
BEGIN
    select SYSDATE into CurDate from dual;
    if testDate <= curDate and testDate >= moins_une_heure(curDate) then
        dbms_output.put_line('Ok');
    else
        dbms_output.put_line('NOk');
    end if;
    
    select count(*) into compteur from tes where val = 2;
    dbms_output.put_line(compteur);
    
END;
/

select * from Joueur;
select * from contient;
select * from symbole;
select * from carte;
select count(*) from carte where idniveau = 1;
select c.*, s.symbpath
    from 
        contient c, symbole s
    where 
        c.idSymbole = s.idSymbole
        and c.idCarte = 2
    order by (position);



