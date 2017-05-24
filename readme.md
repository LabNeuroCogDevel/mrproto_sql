# automation
 setup in cron for foranw@rhea.

 builds(`00_regen_db.bash`) and emails (`email_cron.bash`) nightly midnigth and at 1pm
 
# build
`./00_regen_db.bash` to pull in everything

# compare
`./checksubj.bash` to check a specific subject
`./count_study_column.bash` to see whats going on

# MODIFIYING/ADDING
adding a new dicom item
 - hinfo:hinfo()
 - hinfo:printheader()
 - schema.sql:mrinfo 
 - `./00_regen_db.bash`
 - add tag to `funcs.R:mergeBy` 
 
N.B. `dicom_hinfo` respects order of tags on cli (it doesnt not sort tags)
tags for hinfo, printheader, and mrinfo table should all be in the same order

watchout for inconsitant names between different headers (see `hinfo` and `dicom_from_dir.bash` header options)


