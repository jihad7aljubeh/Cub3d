#!/bin/bash
EXEC="../cub3D"
TOTAL=0
PASS=0

run() {
    FILE=$1
    EXPECT=$2
    ((TOTAL++))

    timeout 2 $EXEC $FILE > /dev/null 2>&1
    S=$?

    if [ $S -eq 139 ]; then
        echo "SEGFAULT $FILE"
        return
    fi

    if [ "$EXPECT" = "OK" ]; then
        if [ $S -eq 0 ]; then
            echo "PASS $FILE"
            ((PASS++))
        else
            echo "FAIL $FILE (expected OK)"
        fi
    else
        if [ $S -ne 0 ]; then
            echo "PASS $FILE"
            ((PASS++))
        else
            echo "FAIL $FILE (should fail)"
        fi
    fi
}

echo "=== VALID TESTS ==="
for f in maps/valid/*.cub; do run $f OK; done
echo "=== INVALID TESTS ==="
for f in maps/invalid/*.cub; do run $f KO; done
echo "RESULT: $PASS / $TOTAL"
