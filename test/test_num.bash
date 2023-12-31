#!/bin/bash

dir=~
[ "$1" != "" ] && dir="$1"   #引数があったら、そちらをホームに変える。

cd $dir/ros2_ws
colcon build
source $dir/.bashrc
timeout 10 ros2 launch mypkg num_talk_listen.launch.py > /tmp/mypkg.log

output=$(cat /tmp/mypkg.log | grep -E 'odd|even|prime|not prime|divisors are|received' | awk -F']:' '{print $2}' | tr -d ' ')

test_lines=100
count=0

while read -r line; do
    if ((count >= test_lines)); then
        break
    fi

    if [[ $line == received* ]]; then
        num=${line//[^0-9]/}
        if ! [[ $num =~ ^[0-9]+$ ]] || ((num < 0)) || ((num > 100)); then
            echo "Test failed: listener_rand output is not an integer between 0 and 100"
            exit 1
        fi
    elif [[ $line == even ]] || [[ $line == odd ]]; then
        if ! [[ $line =~ ^even$|^odd$ ]]; then
            echo "Test failed: listener_even output is not 'even' or 'odd'"
            exit 1
        fi
    elif [[ $line == prime ]] || [[ $line == "not prime" ]]; then
        if ! [[ $line =~ ^prime$|^not\ prime$ ]]; then
            echo "Test failed: listener_prime output is not 'prime' or 'not prime'"
            exit 1
        fi
    elif [[ $line == divisors* ]]; then
        divisors=${line//[^0-9\ ]}
        for divisor in $divisors; do
            if ! [[ $divisor =~ ^[0-9]+$ ]] || ((divisor < 0)) || ((divisor > 100)); then
                echo "Test failed: listener_divisors output is not a list of integers between 0 and 100"
                exit 1
            fi
        done
    fi

    ((count++))
done <<< "$output"

echo "Test passed!"
