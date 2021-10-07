drop table Detail;
drop table Commande;
drop table Client;
drop table Produit;


create table Produit 
(idP number,
nomP varchar2(50),
prixP number(5,2),
constraint pk_produit primary key(idP)
);

create table Client 
(idC number,
nomC varchar2(50),
prenomC varchar2(50),
constraint pk_client primary key(idC)
);

create table Commande 
(idCo number,
dateC date,
idC number,
constraint pk_commande primary key(idCo),
constraint fk_commande_client foreign key (idC) references Client(idC),
constraint nn_idc check (idc is not null)
);

create table Detail
(idCo number,
idP number,
nombre number,
constraint pk_Detail primary key(idCo, idP),
constraint fk_detail_commande foreign key (idCo) references Commande(idCo),
constraint fk_detail_produit foreign key (idP) references Produit(idP)
);

insert into Client values (1,'Pinel-Sauvagnat','Karen');
insert into Client values (2,'Moreno','Jose');

insert into Produit values (1,'Chocolatine',1);
insert into Produit values (2,'Croissant',0.9);
insert into Produit values (3,'Brioche',0.95);
insert into Produit values (4, 'Pain au raisin',1.1);

insert into Commande values (1,to_date('01/01/2017','DD/MM/YYYY'),1);
insert into Detail values (1,1,10);
insert into Detail values (1,3,10);

insert into Commande values (2,to_date('01/01/2017','DD/MM/YYYY'),2);
insert into Detail values (2,1,30);

insert into Commande values (3,to_date('02/01/2017','DD/MM/YYYY'),1);
insert into Detail values (3,1,10);
insert into Detail values (3,3,10);
insert into Detail values (3,4,10);

insert into Commande values (4,to_date('06/01/2017','DD/MM/YYYY'),2);
insert into Detail values (4,1,40);

commit;



-- procedure permettant de renvoyer pour une dated donnée (cDateC) le produit le plus vendu et le produit le moins vendu
create or replace procedure min_max_ventes(vdateC Commande.datec%TYPE, vidPmin out Produit.idP%TYPE, vidPmax out Produit.idP%TYPE) as

begin

-- l'utilisation du rownum est nécessaire ici pour ne revnoyer qu'un seul produit (plusieurs produits peuvent correspondre au max).
select idP  into vidPmin from (
select idP 
from Commande, Detail
where commande.idCo = Detail.idCo
and dateC=vdateC
group by idP
having sum(nombre)=(select max(sum(nombre))
            from Commande, detail
             where commande.idCo = Detail.idCo
            and dateC=vdateC
            group by idP))
where rownum=1;
            

select idP into vidPmax from (
select idP 
from Commande, Detail
where commande.idCo = Detail.idCo
and dateC=vdateC
group by idP
having sum(nombre)=(select min(sum(nombre))
                    from commande, detail
                    where commande.idCo = Detail.idCo
                    and dateC=vdateC
                    group by idP))
where rownum=1;
            
            
end;
/


set serveroutput on;
DECLARE
 vpmi Produit.idP%TYPE;
 vpma Produit.idP%TYPE;
begin
 min_max_ventes(to_date('01/01/2017','DD/MM/YYYY'),vpmi, vpma);
 dbms_output.put_line(vpmi||' '|| vpma);

end;
/



