-- lunaid and lunadate will be weird for cog
insert into visit 
 select
  study,
  substr(patname,1,5) as lunaid,
  substr(patname,1,14) as lunadate,
  case lunadate 
   when id then null 
   else id 
  end as petid,
  round( (julianday( date(substr(d,1,4)||'-'||substr(d,5,2)||'-'||substr(d,7,2))) - 
   julianday(date(substr(b,1,4)||'-'||substr(b,5,2)||'-'||substr(b,7,2))  ) 
   )/365.25,2) as age,
   1 as timepoint,
   null as dtbz, null as rac, null as pet
 from (
  select
   min(id)        as id,
   max(patname)   as patname,
   min(lunadate)  as lunadate,
   min(Sex)       as Sex,
   min(Birthdate) as b,
   min(Date)      as d,
   study
  from mrinfo group by lunadate, study
 );
 
