-- Trigger.sql

create or replace trigger t_b_i_estJoue
before insert on estJoue
for each row
DECLARE
    vNbSymCarte Difficulte.NbSymCarte%TYPE;
BEGIN
    select D.NbSymCarte into vNbSymCarte
        from
            Difficulte D, Partie P
        WHERE
            P.IdPartie = :new.IdPartie and P.NiveauPartie = D.IdNiveau;

    if :new.PositionCoup > vNbSymCarte then
        raise_application_error(-20000, 'Position Coup invalide');
    END IF;
END;
/


--Blocage temporaire si plusieur défaites dans l'heure
create or replace  trigger tc_i_partie
for insert on partie
compound trigger
    vUsername Partie.username%TYPE;
    vNbPartie NUMBER;
    vNiveauMaxActuel Joueur.NiveauMaxActuel%TYPE;
    vDateLastDefeat DATE;
    vFlag NUMBER;

before each row is
BEGIN
    vUsername := :new.username; -- Pour la partie Statement
    
    -- DEBUT : Blocage des niveaux si l’utilisateur n’a pas l’expérience nécessaire.
    select NiveauMaxActuel into vNiveauMaxActuel
        from
            Joueur
        where
            username = :new.username;
    
    if vNiveauMaxActuel < :new.niveauPartie then
        raise_application_error(-20002, 'Niveau pas débloqué');
    end if;
    -- END : trigger blocage des niveaux
    
END before each row;

AFTER statement is
begin
    --vFLAG := 1;
    
    select dt into vDateLastDefeat
        from
            (select dt, rownum rNum from (
                select datePartie dt
                        from 
                            v_resumePartie
                        where
                            username = vUsername and EstGagnant = 0 and moins_quatre_heure(SYSDATE) <= DatePartie ORDER BY (DatePartie) DESC))
        where
            rNum = 2;
    
    --raise_application_error(-20001, 'vDateLastDefeat = ' || TO_CHAR(vDateLastDefeat, 'DD/MM/YYYY HH24:MI:SS'));
    
    --vFlag := 2;
    select count(*) into vNbPartie 
        from 
            v_resumePartie
        where 
            username = vUsername and EstGagnant = 0 and DatePartie <= vDateLastDefeat and DatePartie >= moins_une_heure(vDateLastDefeat);
            
    --vFlag := 3;
    
    if  vNbPartie >= 5 then
        --vFlag := 3.5;
        raise_application_error(-20001, 'Trop de défaites dans l''heure');
    end if;

    --vFlag := 4;

EXCEPTION
    when no_data_found then
        --raise_application_error(-20001, 'No_data_Found - OK, FLAG = ' || vFlag);
        dbms_output.put_line('Ok'); --Inutile, => Pas de blocage d'heure vu qu'il n'a pas fait de partie dans les 4 dernieres heures.

end AFTER statement;

END;
/
    
select username, EstGagnant, TO_CHAR(DatePartie, 'DD/MM/YYYY HH24:MI:SS') from v_resumePartie ORDER BY (DatePartie) DESC;


select TO_CHAR(dp, 'DD/MM/YYYY HH24:MI:SS'), rNum from
    (select dp, rownum rNum from (
        select DatePartie dp
                from 
                    v_resumePartie
                where
                    username = 'Toto' and EstGagnant = 0 and moins_quatre_heure(SYSDATE) <= DatePartie ORDER BY (DatePartie) DESC)
        where
            rownum != 0)
    where
        rNum != 0;





