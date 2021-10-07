-- View

-- Vue pour le trigger blocage temporaire
create or replace view v_resumePartie (Username, IdPartie, EstGagnant, DatePartie, score) as
    select Username, IdPartie, EstGagnant(IdPartie), DatePartie, score(IdPartie, -1) from Partie;

create or replace view v_HightScore (Pseudo, Score, NiveauPartie, DatePartie, IdPartie) as
    select J.Pseudo, vRP.Score, P.NiveauPartie, vRP.DatePartie, vRP.IdPartie
        from 
            v_resumePartie vRP, Joueur J, Partie P
        where
            vRP.Username = J.Username
            AND P.IdPartie = vRP.IdPartie
        order by vRP.SCORE DESC;

create or replace view v_carte (id, lvl) as
    select * 
        from
            carte;

create or replace view v_path_card_1 (idCarte, idSymb, position, path) as
    select c.*, s.symbpath
        from 
            contient c, symbole s
        where 
            c.idSymbole = s.idSymbole
        order by (c.position);

select * from v_path_card_1 where idCarte = 21;

create or replace view v_difficulte (lvl, TempsOrdiMin, TempsOrdiMax, CoeffScore, Malus) as
    select IdNiveau, TempsOrdiMin, TempsOrdiMax, CoeffScore, Malus
        from Difficulte;

select * from v_difficulte;

-- Grant

-- Test
grant select on v_resumePartie
    TO KRN3228A;

grant select, insert on estJoue
    TO KRN3228A;

grant select, insert on Init
    TO KRN3228A;

grant select, insert on Contient
    TO KRN3228A;

grant select, insert on Symbole
    TO KRN3228A;

grant select, insert on Carte
    TO KRN3228A;
    
grant select, insert on Partie
    TO KRN3228A;
    
grant select, insert on Joueur
    TO KRN3228A;

grant select, insert on Difficulte
    TO KRN3228A;
    
REVOKE ALL PRIVILEGES on estJoue from KRN3228A;




