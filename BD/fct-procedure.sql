--Fct

create or replace function EstGagnant (fIdPartie Partie.IdPartie%TYPE) return NUMBER is
-- Retourne 1 si la partie est gagné par le joueur, 0 sinon.
    vNbCartePerdue NUMBER;
    vNbCarteGagne NUMBER;
BEGIN
    select COUNT(*) into vNbCarteGagne
        from 
            EstJoue EJ
        where
            EJ.IdPartie = fIdPartie AND EJ.EstGagnant = 1 AND EJ.EstJoueur = 1;
    
    select COUNT(*) into vNbCartePerdue
        from 
            EstJoue EJ
        where
            EJ.IdPartie = fIdPartie AND EJ.EstJoueur = 0;
    
    if vNbCarteGagne > vNbCartePerdue then
        return(1);
    else
        return(0);
    END IF;
END;
/

create or replace function score (fIdPartie partie.idPartie%TYPE, fTemps EstJoue.TempJoue%TYPE) return NUMBER is
-- Renvoie le  score du joueur pour une partie a un temps donné si fTemps = -1 score de la partie
    vTemps EstJoue.TempJoue%TYPE;
    vTempsPrec EstJoue.TempJoue%TYPE := 0;
    vScore NUMBER := 0;
    vMalus NUMBER := 100; -- Malus si coup raté.
    vCoeff Difficulte.CoeffScore%TYPE;
BEGIN
    select D.CoeffScore, D.malus into vCoeff, vMalus
        from 
            Difficulte D, Partie P
        where 
            D.IdNiveau = P.NiveauPartie AND P.IdPartie = fIdPartie;

    if fTemps = -1 then
        select Duree into vTemps from Partie where IdPartie = fIdPartie;
    else
        vTemps := fTemps;
    END IF;
    
    for ligne_ej in (select * 
                        from
                            EstJoue EJ
                        where
                            EJ.IdPartie = fIdPartie AND EJ.TempJoue <= vTemps ORDER BY (EJ.TempJoue))
                    LOOP
        if ligne_ej.EstJoueur = 0 then
            vTempsPrec := ligne_ej.TempJoue;
        elsif ligne_ej.EstGagnant = 0 then
            vScore := vScore - vMalus;
        else
            vScore := vScore + 100 * vCoeff * 1 / (ligne_ej.TempJoue - vTempsPrec); --Formule du score
        END IF;
    END LOOP;
    
    return(vScore);
END;
/

select score(idPartie, -1) from partie;


create or replace function moins_une_heure (fDate DATE) return date is
-- renvoies une date - 1 heure
    vJour number;
    vMois number;
    vAnnee number;
    vHeure number;
    vMins number;
    vSec number;
BEGIN
    vJour := TO_NUMBER(TO_CHAR(fDate, 'DD'));
    vMois := TO_NUMBER(TO_CHAR(fDate, 'MM'));
    vAnnee := TO_NUMBER(TO_CHAR(fDate, 'YYYY'));
    vHeure := TO_NUMBER(TO_CHAR(fDate, 'HH24'));
    vMins := TO_NUMBER(TO_CHAR(fDate, 'MI'));
    vSec := TO_NUMBER(TO_CHAR(fDate, 'SS'));
    
    if vHeure - 1 < 0 then
        vHeure := 23;
        if vJour - 1 <= 0 then
            if vMois - 1 <= 0 then
                vAnnee := vAnnee - 1;
                vMois := 12;
                vJour := 31;
            elsif vMois - 1 = 2 then
                if (MOD(vAnnee, 400) = 0 OR (MOD(vAnnee, 4) = 0 AND (not MOD(vAnnee, 100) = 0) ) ) then
                    vJour := 29;
                else
                    vJour := 28;
                end if;
            elsif vMois - 1 in (1, 3, 5, 7, 8, 10, 12) then
                vMois := vMois - 1;
                vJour := 31;
            else
                vMois := vMois - 1;
                vJour := 30;
            end if;
        else
            vJour := vJour - 1;
        end if;
    else 
        vHeure := vHeure - 1;
    end if;

    return(TO_DATE(to_char(vAnnee) || '/' || to_char(vMois) || '/' || to_char(vJour) || ' ' || to_char(vHeure) || ':' || to_char(vMins) || ':' || to_char(vSec), 'yyyy/mm/dd hh24:mi:ss')); 
END;
/

create or replace function moins_quatre_heure (fDate DATE) return date is
-- renvoies une date - 4 heure
    vJour number;
    vMois number;
    vAnnee number;
    vHeure number;
    vMins number;
    vSec number;
BEGIN
    vJour := TO_NUMBER(TO_CHAR(fDate, 'DD'));
    vMois := TO_NUMBER(TO_CHAR(fDate, 'MM'));
    vAnnee := TO_NUMBER(TO_CHAR(fDate, 'YYYY'));
    vHeure := TO_NUMBER(TO_CHAR(fDate, 'HH24'));
    vMins := TO_NUMBER(TO_CHAR(fDate, 'MI'));
    vSec := TO_NUMBER(TO_CHAR(fDate, 'SS'));
    
    if vHeure - 4 < 0 then
        vHeure := vHeure + 20;
        if vJour - 1 <= 0 then
            if vMois - 1 <= 0 then
                vAnnee := vAnnee - 1;
                vMois := 12;
                vJour := 31;
            elsif vMois - 1 = 2 then
                if (MOD(vAnnee, 400) = 0 OR (MOD(vAnnee, 4) = 0 AND (not MOD(vAnnee, 100) = 0) ) ) then
                    vJour := 29;
                else
                    vJour := 28;
                end if;
            elsif vMois - 1 in (1, 3, 5, 7, 8, 10, 12) then
                vMois := vMois - 1;
                vJour := 31;
            else
                vMois := vMois - 1;
                vJour := 30;
            end if;
        else
            vJour := vJour - 1;
        end if;
    else 
        vHeure := vHeure - 4;
    end if;

    return(TO_DATE(to_char(vAnnee) || '/' || to_char(vMois) || '/' || to_char(vJour) || ' ' || to_char(vHeure) || ':' || to_char(vMins) || ':' || to_char(vSec), 'yyyy/mm/dd hh24:mi:ss')); 
END;
/

--Insert symbole
create or replace procedure insertSymb (pPath Symbole.SymbPath%TYPE, retour out NUMBER) as
BEGIN
    insert into symbole values (seqIdSymbole.nextval, pPath);
    retour := 0;
    commit;

EXCEPTION
    when dup_val_on_index then
        retour := 1;
    when others then
        retour := SQLCODE;

END;
/


--Insert Card
create or replace procedure insertCarte (pIdNiveau Carte.IdNiveau%TYPE, retour out NUMBER) as
BEGIN
    insert into Carte values (seqIdCarte.nextval, pIdNiveau);
    retour := 0;
    commit;
EXCEPTION
    when dup_val_on_index then
        retour := 1;
    when others then
        retour := SQLCODE;
END;
/

create or replace procedure insertContient (pIdSymbole Contient.IdSymbole%TYPE, pPosition Contient.Position%TYPE, retour out NUMBER) as
BEGIN
    insert into Contient values (seqIdCarte.currval, pIdSymbole, pPosition);
    retour := 0;
    commit;
EXCEPTION
    when dup_val_on_index then
        retour :=1;
    when others then
        retour := SQLCODE;
END;
/


create or replace procedure insertJoueur (pUsername Joueur.Username%TYPE, pMdp Joueur.Mdp%TYPE, pAge Joueur.Age%TYPE, pPseudo Joueur.Pseudo%TYPE, retour out NUMBER) as
BEGIN
    insert into Joueur values (pUsername, pMdp, pAge, pPseudo, 1);
    retour := 0;
    commit;
EXCEPTION
    when dup_val_on_index then
        retour := 1;
    when others then
        if SQLCODE like UPPER('%uni_Pseudo%') then
            retour := 2;
        else
            retour := SQLCODE;
        end if;
END;
/


create or replace procedure connectionTest (pUsername Joueur.username%TYPE, pMdp Joueur.Mdp%TYPE, pPseudo out Joueur.Pseudo%TYPE, retour out NUMBER) as
BEGIN
    select pseudo into pPseudo
        from 
            Joueur
        where
            Username = pUsername AND Mdp = pMdp;
    
    retour := 0;

EXCEPTION
    when no_data_found then
        retour := 1;
    when others then
        retour := SQLCODE;
END;
/

select * from Joueur;
delete from Joueur where username = 'Toto54';




































