#!/bin/bash

echo "Setting up STRICT Cub3D tester (using real XPM)..."

mkdir -p tester/maps/{valid,invalid}

########################################
# PATH TO YOUR TEXTURES
########################################
TEX="./../textures"

########################################
# VALID MAPS (ALL SHOULD PASS)
########################################

# VALID 1
f="tester/maps/valid/v1.cub"
echo "NO $TEX/bookshelf_00.xpm" > $f
echo "SO $TEX/bookshelf_01.xpm" >> $f
echo "WE $TEX/bookshelf_02.xpm" >> $f
echo "EA $TEX/bookshelf_03.xpm" >> $f
echo "" >> $f
echo "F 220,100,0" >> $f
echo "C 225,30,0" >> $f
echo "" >> $f
echo "111111" >> $f
echo "100001" >> $f
echo "10N001" >> $f
echo "100001" >> $f
echo "111111" >> $f

# VALID 2
f="tester/maps/valid/v2.cub"
echo "NO $TEX/bookshelf_00.xpm" > $f
echo "SO $TEX/bookshelf_01.xpm" >> $f
echo "WE $TEX/bookshelf_02.xpm" >> $f
echo "EA $TEX/bookshelf_03.xpm" >> $f
echo "" >> $f
echo "F 0,0,0" >> $f
echo "C 255,255,255" >> $f
echo "" >> $f
echo "111111" >> $f
echo "100001" >> $f
echo "10E001" >> $f
echo "100001" >> $f
echo "111111" >> $f

# VALID 3 (bigger)
f="tester/maps/valid/v3.cub"
echo "NO $TEX/bookshelf_00.xpm" > $f
echo "SO $TEX/bookshelf_01.xpm" >> $f
echo "WE $TEX/bookshelf_02.xpm" >> $f
echo "EA $TEX/bookshelf_03.xpm" >> $f
echo "" >> $f
echo "F 10,10,10" >> $f
echo "C 200,200,200" >> $f
echo "" >> $f
echo "11111111" >> $f
echo "10000001" >> $f
echo "10S00001" >> $f
echo "10000001" >> $f
echo "11111111" >> $f

########################################
# INVALID MAPS (STRICT)
########################################

# open maps
echo -e "111\n10N\n100" > tester/maps/invalid/open1.cub
echo -e "111111\n100001\n10N000\n111111" > tester/maps/invalid/open2.cub
echo -e "111111\n1N0001\n100001\n111110" > tester/maps/invalid/open3.cub

# multiple players
echo -e "111\n1NE\n111" > tester/maps/invalid/player1.cub
echo -e "111111\n10N0E1\n111111" > tester/maps/invalid/player2.cub
echo -e "111\n1N1\n1S1\n111" > tester/maps/invalid/player3.cub

# invalid chars
echo -e "111\n1X1\n1N1\n111" > tester/maps/invalid/char1.cub
echo -e "111\n1@1\n1N1\n111" > tester/maps/invalid/char2.cub
echo -e "111\n1-1\n1N1\n111" > tester/maps/invalid/char3.cub

# RGB errors
echo -e "F 300,0,0\nC 0,0,0\n111\n1N1\n111" > tester/maps/invalid/rgb1.cub
echo -e "F -1,0,0\nC 0,0,0\n111\n1N1\n111" > tester/maps/invalid/rgb2.cub
echo -e "F 1,2\nC 0,0,0\n111\n1N1\n111" > tester/maps/invalid/rgb3.cub

# texture errors
echo -e "NO ./bad.xpm\n111\n1N1\n111" > tester/maps/invalid/tex1.cub
echo -e "SO ./bad.xpm\n111\n1N1\n111" > tester/maps/invalid/tex2.cub
echo -e "WE ./bad.xpm\n111\n1N1\n111" > tester/maps/invalid/tex3.cub

# structure errors
touch tester/maps/invalid/empty.cub
echo "" > tester/maps/invalid/blank.cub
echo "random text" > tester/maps/invalid/garbage.cub

########################################
# TEST SCRIPT
########################################

echo '#!/bin/bash' > tester/run_tests.sh
echo 'EXEC="../cub3D"' >> tester/run_tests.sh
echo 'TOTAL=0' >> tester/run_tests.sh
echo 'PASS=0' >> tester/run_tests.sh

echo '
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
' >> tester/run_tests.sh

echo 'echo "=== VALID TESTS ==="' >> tester/run_tests.sh
echo 'for f in maps/valid/*.cub; do run $f OK; done' >> tester/run_tests.sh

echo 'echo "=== INVALID TESTS ==="' >> tester/run_tests.sh
echo 'for f in maps/invalid/*.cub; do run $f KO; done' >> tester/run_tests.sh

echo 'echo "RESULT: $PASS / $TOTAL"' >> tester/run_tests.sh

chmod +x tester/run_tests.sh

########################################
# RUN
########################################


