-- 20180502 hard code some fixes (to pet)
-- these statements should be made before the visit table is created
-- to quickly use changes made to this file:
--    sqlite3 db 'delete from visit'             -- delete all visits
--    sqlite3 db < manually_fix.sql              -- adjust values
--    sqlite3 db < <(cat mksubj.sql mkvisit.sql) -- remake subject and visits
update mrinfo set (id) = ('B0234') where study like 'pet' and id||patname||lunadate like '%B0234%'
