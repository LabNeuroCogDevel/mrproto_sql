CREATE TABLE subj (
    lunaid      int,
    sex         char(1),
    dob         timestamp
);

CREATE TABLE visit (
    study       varchar(14),
    lunaid      int,      --  link to subj
    lunadate    char(14),
    petid       char(5),
    ageatscan   float,
    timepoint   int,
    dtbz        bool,
    rac         bool,
    pet         bool
);

create table analysis (
     analysis  varchar(20),
     lunadate  char(14),
     protocol  text,
     runnum    int ,
     dir       text,
     finalfile text,
     rawdir    text -- link to mrinfo dir
);

create TABLE mrinfo (
    
    study     varchar(14),
    lunadate  varchar(14),
    dir       text,
    seqno     int,
    ndcm      int,
    
    id         text,
    Birthdate  text,
    Sex text,
    Date text,
    Time text,
    Name text,
    Operator text,
    Spacing text,
    PhaseEncodingDirection text,
    ImageOrientation text,
    RT float,
    ET float,
    Flip float,
    nRows float,
    nColumns float,
    PhaseEncodingSteps float,
    CoilString text,
    PATSize numeric,
    PATweight numeric,
    SequenceName text,
    StationName text,
    Software text,
    Matrix text,
    sessionname text,
    sessionnum int,
    bad bool
);
