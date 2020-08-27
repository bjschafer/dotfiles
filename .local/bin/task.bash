#!/bin/bash
# $1 = tty to watch

hiddenTags="-Deferred -Delegated"

while (true)
do
    clear
    uname -n
    date "+%T"
    task calendar
    echo
    echo OVERDUE
    task +OVERDUE -TODAY "$hiddenTags" list
    echo
    echo TODAY
    task +TODAY -Deferred list
    echo
    echo WEEK
    task -OVERDUE -TODAY "$hiddenTags" +WEEK list
    echo
    echo LATER
    task -OVERDUE -WEEK "$hiddenTags" due.any: list
    echo
    echo NONE
    task "$hiddenTags" due.none: list
    echo
    echo "DELEGATED: $(task count +Delegated) TASKS, task +Delegated list to view."
    echo
    echo "DEFERRED: $(task count +Deferred) TASKS, task +Deferred list to view."
    inotifywait -qq -e modify "$1" "$HOME/vimwiki/"
    sleep 5
done
