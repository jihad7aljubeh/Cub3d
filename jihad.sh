#!/bin/bash

# =============================================================================
# cub3D — MAP EDGE CASE TESTS
# All maps use: NO/SO/WE/EA = ./code/textures/bookshelf.xpm
# Adjust paths if your textures are elsewhere
# Usage: bash map_edge_cases.sh [path_to_binary]
# =============================================================================

BINARY="${1:-./cub3D}"
TEX="./code/textures/bookshelf.xpm"
PASS=0
FAIL=0

green() { echo -e "\033[32m[PASS]\033[0m $1"; ((PASS++)); }
red()   { echo -e "\033[31m[FAIL]\033[0m $1"; ((FAIL++)); }
title() { echo -e "\n\033[1;34m── $1 ──\033[0m"; }

header() {
cat << EOF
NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 100,100,100
C 50,50,50

EOF
}

run_should_fail() {
    local name="$1"
    local map="$2"
    local file=$(mktemp /tmp/cub3d_XXXXXX.cub)
    printf "%s" "$map" > "$file"
    timeout 3 "$BINARY" "$file" > /dev/null 2>&1
    local code=$?
    rm -f "$file"
    if [ $code -ne 0 ] && [ $code -ne 124 ]; then
        green "$name"
    else
        red "$name — expected error exit, got $code"
    fi
}

run_should_pass() {
    local name="$1"
    local map="$2"
    local file=$(mktemp /tmp/cub3d_XXXXXX.cub)
    printf "%s" "$map" > "$file"
    "$BINARY" "$file" > /dev/null 2>&1 &
    local PID=$!
    sleep 1
    kill $PID 2>/dev/null
    wait $PID 2>/dev/null
    local code=$?
    rm -f "$file"
    if [ $code -ne 139 ] && [ $code -ne 134 ]; then
        green "$name"
    else
        red "$name — crashed with code $code (segfault/abort)"
    fi
}

H=$(header)

# =============================================================================
title "VALID MAPS — must be accepted"
# =============================================================================

# Minimal possible valid map
run_should_pass "minimal 3x3 map" \
"$(header)111
1N1
111
"

# All 4 player orientations
run_should_pass "player facing North" \
"$(header)11111
1N001
10001
11111
"

run_should_pass "player facing South" \
"$(header)11111
10001
1S001
11111
"

run_should_pass "player facing East" \
"$(header)11111
10001
10E01
11111
"

run_should_pass "player facing West" \
"$(header)11111
10001
1W001
11111
"

# Player in corners (inside wall ring)
run_should_pass "player near top-left corner" \
"$(header)11111
1N001
10001
11111
"

run_should_pass "player near bottom-right corner" \
"$(header)11111
10001
100N1
11111
"

# Map with spaces (spaces are valid map chars per subject)
run_should_pass "spaces as void around the map" \
"$(header)   1111
   1001
1111N01111
1000000001
1111111111
"

run_should_pass "spaces inside map border" \
"$(header)111111111
1  0  001
1  N  001
1  0  001
111111111
"

run_should_pass "asymmetric spaces on one side" \
"$(header)11111
1N001
10001
11111
       
"

# Non-rectangular rows (different row lengths)
run_should_pass "non-rectangular map - rows differ in length" \
"$(header)111111111111
1N0000000001
100000001
1000001
111111
"

# Large map
run_should_pass "large map 20x20" \
"$(header)11111111111111111111
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
1000000000N000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
10000000000000000001
11111111111111111111
"

# Map with corridors
run_should_pass "map with corridors" \
"$(header)1111111111111
1N00100000001
1000100010001
1111100010001
1000000010001
1011111110001
1000000000001
1111111111111
"

# Map with internal walls (pillars)
run_should_pass "map with internal wall pillars" \
"$(header)111111111
100010001
101010101
100000001
101010101
100N10001
101010101
100000001
111111111
"

# Map with empty lines before map section
run_should_pass "empty lines between config and map" \
"NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 100,100,100
C 50,50,50



11111
1N001
11111
"

# Map with tabs in config (spaces and tabs between identifier and path)
run_should_pass "multiple spaces in config lines" \
"NO    $TEX
SO    $TEX
WE    $TEX
EA    $TEX
F   100,100,100
C   50,50,50

11111
1N001
11111
"

# Config in reverse order
run_should_pass "config elements in reverse order" \
"C 50,50,50
F 100,100,100
EA $TEX
WE $TEX
SO $TEX
NO $TEX

11111
1N001
11111
"

# Boundary colors
run_should_pass "floor color 0,0,0 and ceiling 255,255,255" \
"NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 255,255,255

11111
1N001
11111
"

# Map with only 0s inside (open room)
run_should_pass "fully open room inside walls" \
"$(header)1111111
1000001
1000001
100N001
1000001
1000001
1111111
"

# =============================================================================
title "INVALID MAPS — must exit with Error"
# =============================================================================

# --- PLAYER ERRORS ---

run_should_fail "no player at all" \
"$(header)11111
10001
10001
11111
"

run_should_fail "two players same orientation" \
"$(header)11111
1N001
1N001
11111
"

run_should_fail "two players different orientation" \
"$(header)11111
1N001
1S001
11111
"

run_should_fail "four players" \
"$(header)111111
1N00S1
1W00E1
111111
"

# --- ENCLOSURE ERRORS ---

run_should_fail "top row is not all walls" \
"$(header)11011
1N001
10001
11111
"

run_should_fail "bottom row is not all walls" \
"$(header)11111
1N001
10001
11011
"

run_should_fail "left column has gap" \
"$(header)11111
1N001
00001
11111
"

run_should_fail "right column has gap" \
"$(header)11111
1N001
10000
11111
"

run_should_fail "hole inside a wall" \
"$(header)111111
1N0001
100 01
111111
"

run_should_fail "map open at top-left corner" \
"$(header)01111
1N001
10001
11111
"

run_should_fail "map open at top-right corner" \
"$(header)11110
1N001
10001
11111
"

run_should_fail "map open at bottom-left corner" \
"$(header)11111
1N001
10001
01111
"

run_should_fail "map open at bottom-right corner" \
"$(header)11111
1N001
10001
11110
"

run_should_fail "zero reachable from edge through empty path" \
"$(header)111111
0N0001
100001
111111
"

run_should_fail "player reachable from map edge" \
"$(header)111111
100001
1N0000
111111
"

# --- CHARACTER ERRORS ---

run_should_fail "invalid char: digit 2" \
"$(header)11111
1N001
12001
11111
"

run_should_fail "invalid char: digit 3" \
"$(header)11111
1N001
13001
11111
"

run_should_fail "invalid char: digit 9" \
"$(header)11111
1N001
19001
11111
"

run_should_fail "invalid char: lowercase a" \
"$(header)11111
1N001
1a001
11111
"

run_should_fail "invalid char: uppercase A" \
"$(header)11111
1N001
1A001
11111
"

run_should_fail "invalid char: uppercase P" \
"$(header)11111
1P001
10001
11111
"

run_should_fail "invalid char: uppercase X" \
"$(header)11111
1X001
1N001
11111
"

run_should_fail "invalid char: @" \
"$(header)11111
1@001
1N001
11111
"

run_should_fail "invalid char: !" \
"$(header)11111
1!001
1N001
11111
"

run_should_fail "invalid char: tab in map" \
"$(header)11111
1N0	1
10001
11111
"

# --- EMPTY / MISSING MAP ---

run_should_fail "completely empty file" \
""

run_should_fail "only newlines — no config no map" \
"



"

run_should_fail "config only — no map section" \
"NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 0,0,0
"

run_should_fail "map section is only empty lines" \
"NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 0,0,0



"

run_should_fail "map is a single wall row only" \
"$(header)111111
"

run_should_fail "map is a single line with player" \
"$(header)1N1
"

# --- CONFIG ERRORS ---

run_should_fail "missing NO texture" \
"SO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 0,0,0

11111
1N001
11111
"

run_should_fail "missing SO texture" \
"NO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 0,0,0

11111
1N001
11111
"

run_should_fail "missing WE texture" \
"NO $TEX
SO $TEX
EA $TEX
F 0,0,0
C 0,0,0

11111
1N001
11111
"

run_should_fail "missing EA texture" \
"NO $TEX
SO $TEX
WE $TEX
F 0,0,0
C 0,0,0

11111
1N001
11111
"

run_should_fail "missing F color" \
"NO $TEX
SO $TEX
WE $TEX
EA $TEX
C 0,0,0

11111
1N001
11111
"

run_should_fail "missing C color" \
"NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 0,0,0

11111
1N001
11111
"

run_should_fail "duplicate NO" \
"NO $TEX
NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 0,0,0

11111
1N001
11111
"

run_should_fail "duplicate F" \
"NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 0,0,0
F 0,0,0
C 0,0,0

11111
1N001
11111
"

run_should_fail "unknown identifier ZZ" \
"NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 0,0,0
ZZ something

11111
1N001
11111
"

run_should_fail "identifier with no value" \
"NO
SO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 0,0,0

11111
1N001
11111
"

run_should_fail "texture path does not exist" \
"NO ./DOESNOTEXIST.xpm
SO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 0,0,0

11111
1N001
11111
"

run_should_fail "element after map" \
"NO $TEX
SO $TEX
WE $TEX
EA $TEX
F 0,0,0
C 0,0,0

11111
1N001
11111

NO $TEX
"

# --- COLOR ERRORS ---

run_should_fail "floor R=256" \
"$(header)11111
1N001
11111
" # override F
# override
TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF 256,0,0\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor R=256 over limit" || red "floor R=256 over limit"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF 0,256,0\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor G=256 over limit" || red "floor G=256 over limit"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF 0,0,256\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor B=256 over limit" || red "floor B=256 over limit"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF -1,0,0\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor R=-1 negative" || red "floor R=-1 negative"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF abc,0,0\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor R=abc non-numeric" || red "floor R=abc non-numeric"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF 100,100\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor only 2 components" || red "floor only 2 components"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF 100,100,100,100\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor 4 components" || red "floor 4 components"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF ,100,100\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor empty first component" || red "floor empty first component"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF 100,,100\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor empty middle component" || red "floor empty middle component"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nF 1.5,100,100\nC 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "floor float value 1.5" || red "floor float value 1.5"
rm -f "$TMPF"

TMPF=$(mktemp /tmp/cub3d_XXXXXX.cub)
printf "NO $TEX\nSO $TEX\nWE $TEX\nEA $TEX\nC 255,255,256\nF 0,0,0\n\n11111\n1N001\n11111\n" > "$TMPF"
timeout 3 "$BINARY" "$TMPF" > /dev/null 2>&1
[ $? -ne 0 ] && green "ceiling B=256 over limit" || red "ceiling B=256 over limit"
rm -f "$TMPF"

# =============================================================================
echo ""
echo "────────────────────────────────────"
echo "  RESULTS"
echo "────────────────────────────────────"
echo "  Passed : $PASS"
echo "  Failed : $FAIL"
echo "  Total  : $((PASS + FAIL))"
echo ""
[ $FAIL -eq 0 ] && echo "  ALL PASSED" || echo "  $FAIL FAILED"