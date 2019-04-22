#!/bin/bash

# init-screen
perl /opt/otrs/var/httpd/init-screen/httpserver.pl > /dev/null 2>&1 &
INITSCREEN_PID=$!

# set APP ENV vars
printenv | grep APP_ | sed 's/^\(.*\)$/export \1/g' > /etc/profile.d/app-env.sh

# database connection test
while ! su -c "otrs.Console.pl Maint::Database::Check" otrs 2> /tmp/console-maint-database-check.log; 
do
    egrep -o " Message: (.+)" /tmp/console-maint-database-check.log

    # init configuration if empty
    grep "database content is missing" /tmp/console-maint-database-check.log \
    && su -c "/app-init.sh" otrs;
    
    sleep 1;
done

# stop init-screen
kill -9 $INITSCREEN_PID

# run services
exec supervisord