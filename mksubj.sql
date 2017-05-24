insert into subj 
select lunaid, sex, date(substr(b,1,4)||'-'||substr(b,5,2)||'-'||substr(b,7,2)) as dob
 from (
     select substr(lunadate,1,5) as lunaid, min(Sex) as sex, min(Birthdate) as b, min(Date) as d from mrinfo group by lunadate
    );
