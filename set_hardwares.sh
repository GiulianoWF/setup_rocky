postgres='psql -U postgres -d novounifodb'

$postgres -t -c "update workstations set workstationprofileid = 1;"
$postgres -t -c "delete from workstationprofilehardware where workstationprofileid = 1 and hardwareid in (20003, 9705, 9710, 9703, 9707);"

