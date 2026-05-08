#! /usr/bin/sh

# Usage
# $0 [window name to search for and opaque] [command to execute + options etc.]

winname=$1
if test $# -lt 2; then
    echo "Too few arguments"
    return 2
fi

# Execute the program
shift
cmd="$*"
setsid --fork sh -c -- "$cmd"
procpid=$(ps --ppid $$ -o pid --no-headers --sort pid | head -n 1)


i=50
while test $i -gt 0
do
    echo Searching for "$winname"
    if test "$(wmctrl -l | tr -s ' ' | cut -f 4- -d ' ' | grep -ic ^"$winname"\$)" -eq 1; then
        # Meaning exactly 1 match exists, skip otherwise...
        lineNumber=$(wmctrl -l | tr -s ' ' | cut -f 4- -d ' ' | grep -in ^"$winname"\$ | cut -f 1 -d :)
        # Extracts the hexadecimal window ID (like 0x04800008)
        windowid=$(wmctrl -l | sed -En "$lineNumber{s/(0x[0-9a-fA-F]+).*/\1/;p}")
        picom-trans -w "$windowid" 100
        echo Set "$windowid" to opaque
        echo "Waiting for $procpid"
        while kill -0 "$procpid" >/dev/null 2>&1
        do
            sleep 1
        done
        echo "Finished waiting for $procpid"
        return 0
    fi
    sleep 0.5
    i=$((i - 1))
done
echo "Timeout"
while kill -0 "$procpid" >/dev/null 2>&1
do
    sleep 1
done

