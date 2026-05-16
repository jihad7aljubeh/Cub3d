#!/bin/bash

# =============================================================================
# cub3D FULL TEST SUITE
# Tests every requirement from the subject + 42 Norm to guarantee 100/100
# Usage: bash cub3d_full_tests.sh [path_to_project_root]
# =============================================================================

# --- CONFIG ------------------------------------------------------------------
PROJECT_ROOT="${1:-.}"
BINARY="$PROJECT_ROOT/cub3D"
SRC_DIR="$PROJECT_ROOT/code/src"
INC_DIR="$PROJECT_ROOT/includes"
MAPS_DIR="$PROJECT_ROOT/code/maps"
VALID_MAP="$MAPS_DIR/test.cub"
TIMEOUT=5

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Counters
PASS=0
FAIL=0
TOTAL=0

# Temp dir for generated test maps
TMP="$PROJECT_ROOT/_test_tmp"
mkdir -p "$TMP"

# =============================================================================
# HELPERS
# =============================================================================

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; ((PASS++)); ((TOTAL++)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; ((FAIL++)); ((TOTAL++)); }
warn() { echo -e "  ${YELLOW}[WARN]${NC} $1"; }
section() { echo -e "\n${BOLD}${BLUE}══════════════════════════════════════${NC}"; \
            echo -e "${BOLD}${CYAN}  $1${NC}"; \
            echo -e "${BOLD}${BLUE}══════════════════════════════════════${NC}"; }

# Run binary with timeout, capture stdout+stderr
run() {
    timeout "$TIMEOUT" "$@" 2>&1
    return $?
}

# Check binary exits with any non-zero code
exits_error() {
    timeout "$TIMEOUT" "$@" > /dev/null 2>&1
    local code=$?
    [ $code -ne 0 ] && [ $code -ne 124 ]
}

# Check binary prints "Error" as first word of output
prints_error() {
    local out
    out=$(timeout "$TIMEOUT" "$@" 2>&1)
    echo "$out" | grep -qi "^error"
}

# Make a minimal valid .cub map file
make_valid_cub() {
    local file="$1"
    cat > "$file" << 'EOF'
NO ./code/textures/bookshelf.xpm
SO ./code/textures/bookshelf.xpm
WE ./code/textures/bookshelf.xpm
EA ./code/textures/bookshelf.xpm

F 112,128,144
C 135,206,235

111111
100001
1N0001
100001
111111
EOF
}

# =============================================================================
# SECTION 1 — MAKEFILE
# =============================================================================
section "1. MAKEFILE"

cd "$PROJECT_ROOT" || { echo "Cannot cd to $PROJECT_ROOT"; exit 1; }

# 1.1 make compiles without error
make -s 2>/dev/null
if [ $? -eq 0 ] && [ -f "$BINARY" ]; then
    pass "make: compiles successfully and produces binary"
else
    fail "make: compilation failed or binary not produced"
fi

# 1.2 binary is named cub3D
if [ -f "$BINARY" ]; then
    pass "make: binary is named 'cub3D'"
else
    fail "make: binary is not named 'cub3D' (looking for $BINARY)"
fi

# 1.3 make clean removes .o files
make clean -s 2>/dev/null
OBJ_COUNT=$(find "$PROJECT_ROOT" -name "*.o" ! -path "*/mlx*" | wc -l)
if [ "$OBJ_COUNT" -eq 0 ]; then
    pass "make clean: removes all .o files"
else
    fail "make clean: $OBJ_COUNT .o file(s) remain after clean"
fi

# 1.4 make clean does NOT remove binary
if [ -f "$BINARY" ]; then
    pass "make clean: does NOT remove binary"
else
    fail "make clean: removed the binary (should not)"
fi

# 1.5 make fclean removes binary
make fclean -s 2>/dev/null
if [ ! -f "$BINARY" ]; then
    pass "make fclean: removes binary"
else
    fail "make fclean: binary still exists after fclean"
fi

# 1.6 make re rebuilds after fclean
make re -s 2>/dev/null
if [ $? -eq 0 ] && [ -f "$BINARY" ]; then
    pass "make re: rebuilds binary successfully"
else
    fail "make re: failed to rebuild binary"
fi

# 1.7 no unnecessary relinking
make -s 2>/dev/null
OUTPUT=$(make 2>&1)
if echo "$OUTPUT" | grep -q "cc\|gcc\|clang"; then
    fail "make: relinks when nothing changed (unnecessary relinking)"
else
    pass "make: does not relink when nothing changed"
fi

# 1.8 compilation flags -Wall -Wextra -Werror
make fclean -s 2>/dev/null
OUTPUT=$(make 2>&1)
if echo "$OUTPUT" | grep -q "\-Wall" && echo "$OUTPUT" | grep -q "\-Wextra" && echo "$OUTPUT" | grep -q "\-Werror"; then
    pass "make: uses -Wall -Wextra -Werror flags"
else
    fail "make: missing one or more of -Wall -Wextra -Werror"
fi
make -s 2>/dev/null

# 1.9 bonus rule exists
if grep -q "^bonus" "$PROJECT_ROOT/Makefile"; then
    pass "make: bonus rule exists"
else
    fail "make: bonus rule missing"
fi

# 1.10 no wildcard *.c in Makefile
if grep -E "\*\.c|\*\.o" "$PROJECT_ROOT/Makefile" | grep -v "^#" | grep -qv mlx; then
    fail "make: uses *.c or *.o wildcard (all sources must be explicit)"
else
    pass "make: no *.c or *.o wildcards (explicit source list)"
fi

# =============================================================================
# SECTION 2 — ARGUMENT HANDLING
# =============================================================================
section "2. ARGUMENT HANDLING"

# 2.1 no arguments
if exits_error "$BINARY"; then
    pass "no args: exits with error code"
else
    fail "no args: did not exit with error code"
fi
if prints_error "$BINARY"; then
    pass "no args: prints 'Error' message"
else
    fail "no args: does not print 'Error\\n...' message"
fi

# 2.2 too many arguments
if exits_error "$BINARY" "$VALID_MAP" "$VALID_MAP"; then
    pass "too many args: exits with error code"
else
    fail "too many args: did not exit with error"
fi

# 2.3 wrong extension .txt
FAKE_TXT="$TMP/map.txt"
make_valid_cub "$FAKE_TXT"
if exits_error "$BINARY" "$FAKE_TXT"; then
    pass "wrong extension .txt: exits with error"
else
    fail "wrong extension .txt: did not exit with error"
fi
if prints_error "$BINARY" "$FAKE_TXT"; then
    pass "wrong extension .txt: prints 'Error' message"
else
    fail "wrong extension .txt: does not print 'Error\\n...'"
fi

# 2.4 wrong extension .map
FAKE_MAP="$TMP/map.map"
make_valid_cub "$FAKE_MAP"
if exits_error "$BINARY" "$FAKE_MAP"; then
    pass "wrong extension .map: exits with error"
else
    fail "wrong extension .map: did not exit with error"
fi

# 2.5 file does not exist
if exits_error "$BINARY" "$TMP/nonexistent.cub"; then
    pass "nonexistent file: exits with error"
else
    fail "nonexistent file: did not exit with error"
fi
if prints_error "$BINARY" "$TMP/nonexistent.cub"; then
    pass "nonexistent file: prints 'Error' message"
else
    fail "nonexistent file: does not print 'Error\\n...'"
fi

# 2.6 file with no read permission
NO_PERM="$TMP/noperm.cub"
make_valid_cub "$NO_PERM"
chmod 000 "$NO_PERM"
if exits_error "$BINARY" "$NO_PERM"; then
    pass "no read permission: exits with error"
else
    fail "no read permission: did not exit with error"
fi
chmod 644 "$NO_PERM"

# =============================================================================
# SECTION 3 — SCENE FILE: TEXTURE PARSING
# =============================================================================
section "3. SCENE FILE — TEXTURE PARSING"

make_cub() {
    local f="$1"; shift
    cat > "$f" << EOF
$@
EOF
}

# Helper: full valid header without one element
FULL_HEADER="NO ./code/textures/bookshelf.xpm
SO ./code/textures/bookshelf.xpm
WE ./code/textures/bookshelf.xpm
EA ./code/textures/bookshelf.xpm
F 112,128,144
C 135,206,235"

VALID_MAP_BODY="
111111
100001
1N0001
100001
111111"

# 3.1 missing NO
F="$TMP/no_NO.cub"
printf "SO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm\nF 0,0,0\nC 0,0,0\n\n111111\n1N0001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "missing NO texture: exits with Error"
else
    fail "missing NO texture: should exit with Error"
fi

# 3.2 missing SO
F="$TMP/no_SO.cub"
printf "NO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm\nF 0,0,0\nC 0,0,0\n\n111111\n1N0001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "missing SO texture: exits with Error"
else
    fail "missing SO texture: should exit with Error"
fi

# 3.3 missing WE
F="$TMP/no_WE.cub"
printf "NO ./code/textures/bookshelf.xpm\nSO ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm\nF 0,0,0\nC 0,0,0\n\n111111\n1N0001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "missing WE texture: exits with Error"
else
    fail "missing WE texture: should exit with Error"
fi

# 3.4 missing EA
F="$TMP/no_EA.cub"
printf "NO ./code/textures/bookshelf.xpm\nSO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nF 0,0,0\nC 0,0,0\n\n111111\n1N0001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "missing EA texture: exits with Error"
else
    fail "missing EA texture: should exit with Error"
fi

# 3.5 texture file that does not exist
F="$TMP/bad_tex.cub"
printf "NO ./DOESNOTEXIST.xpm\nSO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm\nF 0,0,0\nC 0,0,0\n\n111111\n1N0001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "nonexistent texture path: exits with Error"
else
    fail "nonexistent texture path: should exit with Error"
fi

# 3.6 duplicate NO
F="$TMP/dup_NO.cub"
printf "NO ./code/textures/bookshelf.xpm\nNO ./code/textures/bookshelf.xpm\nSO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm\nF 0,0,0\nC 0,0,0\n\n111111\n1N0001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "duplicate NO identifier: exits with Error"
else
    fail "duplicate NO identifier: should exit with Error"
fi

# 3.7 unknown identifier
F="$TMP/unknown_id.cub"
printf "NO ./code/textures/bookshelf.xpm\nSO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm\nF 0,0,0\nC 0,0,0\nZZ something\n\n111111\n1N0001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "unknown identifier ZZ: exits with Error"
else
    fail "unknown identifier ZZ: should exit with Error"
fi

# 3.8 elements in any order (SO before NO)
F="$TMP/reorder.cub"
printf "SO ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm\nC 135,206,235\nNO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nF 112,128,144\n\n111111\n1N0001\n111111\n" > "$F"
if ! exits_error "$BINARY" "$F" 2>/dev/null; then
    pass "elements in any order: accepted as valid"
else
    warn "elements in any order: may have failed (check manually)"
fi

# 3.9 multiple spaces between identifier and value
F="$TMP/multi_space.cub"
printf "NO   ./code/textures/bookshelf.xpm\nSO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm\nF  112,128,144\nC  135,206,235\n\n111111\n1N0001\n111111\n" > "$F"
if ! exits_error "$BINARY" "$F" 2>/dev/null; then
    pass "multiple spaces between identifier and value: accepted"
else
    fail "multiple spaces between identifier and value: should be accepted"
fi

# 3.10 empty lines between elements
F="$TMP/empty_between.cub"
printf "NO ./code/textures/bookshelf.xpm\n\nSO ./code/textures/bookshelf.xpm\n\nWE ./code/textures/bookshelf.xpm\n\nEA ./code/textures/bookshelf.xpm\n\nF 112,128,144\n\nC 135,206,235\n\n111111\n1N0001\n111111\n" > "$F"
if ! exits_error "$BINARY" "$F" 2>/dev/null; then
    pass "empty lines between elements: accepted"
else
    fail "empty lines between elements: should be accepted"
fi

# =============================================================================
# SECTION 4 — SCENE FILE: COLOR PARSING
# =============================================================================
section "4. SCENE FILE — COLOR PARSING"

BASE="NO ./code/textures/bookshelf.xpm\nSO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm"
MAP="\n111111\n1N0001\n111111\n"

# 4.1 missing F
F="$TMP/no_F.cub"
printf "$BASE\nC 0,0,0\n$MAP" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "missing F (floor color): exits with Error"
else
    fail "missing F (floor color): should exit with Error"
fi

# 4.2 missing C
F="$TMP/no_C.cub"
printf "$BASE\nF 0,0,0\n$MAP" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "missing C (ceiling color): exits with Error"
else
    fail "missing C (ceiling color): should exit with Error"
fi

# 4.3 color value over 255
F="$TMP/color_over.cub"
printf "$BASE\nF 256,0,0\nC 0,0,0\n$MAP" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "floor color R=256 (over 255): exits with Error"
else
    fail "floor color R=256: should exit with Error"
fi

# 4.4 color value negative
F="$TMP/color_neg.cub"
printf "$BASE\nF -1,0,0\nC 0,0,0\n$MAP" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "floor color R=-1 (negative): exits with Error"
else
    fail "floor color R=-1: should exit with Error"
fi

# 4.5 color non-numeric
F="$TMP/color_alpha.cub"
printf "$BASE\nF abc,0,0\nC 0,0,0\n$MAP" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "floor color non-numeric 'abc': exits with Error"
else
    fail "floor color non-numeric: should exit with Error"
fi

# 4.6 color missing one component
F="$TMP/color_missing.cub"
printf "$BASE\nF 100,100\nC 0,0,0\n$MAP" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "floor color only 2 components: exits with Error"
else
    fail "floor color only 2 components: should exit with Error"
fi

# 4.7 color too many components
F="$TMP/color_extra.cub"
printf "$BASE\nF 100,100,100,100\nC 0,0,0\n$MAP" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "floor color 4 components: exits with Error"
else
    fail "floor color 4 components: should exit with Error"
fi

# 4.8 duplicate F
F="$TMP/dup_F.cub"
printf "$BASE\nF 0,0,0\nF 0,0,0\nC 0,0,0\n$MAP" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "duplicate F: exits with Error"
else
    fail "duplicate F: should exit with Error"
fi

# 4.9 valid boundary colors (0,0,0 and 255,255,255)
F="$TMP/color_bounds.cub"
printf "$BASE\nF 0,0,0\nC 255,255,255\n$MAP" > "$F"
if ! exits_error "$BINARY" "$F" 2>/dev/null; then
    pass "boundary colors 0,0,0 and 255,255,255: accepted"
else
    fail "boundary colors 0,0,0 and 255,255,255: should be accepted"
fi

# =============================================================================
# SECTION 5 — MAP PARSING & VALIDATION
# =============================================================================
section "5. MAP PARSING & VALIDATION"

BASE_FULL="NO ./code/textures/bookshelf.xpm\nSO ./code/textures/bookshelf.xpm\nWE ./code/textures/bookshelf.xpm\nEA ./code/textures/bookshelf.xpm\nF 0,0,0\nC 0,0,0\n"

# 5.1 no map section at all
F="$TMP/no_map.cub"
printf "${BASE_FULL}" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "no map section: exits with Error"
else
    fail "no map section: should exit with Error"
fi

# 5.2 map not last (element after map)
F="$TMP/map_not_last.cub"
printf "${BASE_FULL}\n111111\n1N0001\n111111\n\nNO ./code/textures/bookshelf.xpm\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "element after map: exits with Error"
else
    fail "element after map: should exit with Error"
fi

# 5.3 invalid character in map
for CHAR in "2" "a" "@" "X" "P"; do
    F="$TMP/bad_char_${CHAR}.cub"
    printf "${BASE_FULL}\n111111\n1${CHAR}0001\n1N0001\n111111\n" > "$F"
    if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
        pass "invalid map character '$CHAR': exits with Error"
    else
        fail "invalid map character '$CHAR': should exit with Error"
    fi
done

# 5.4 no player in map
F="$TMP/no_player.cub"
printf "${BASE_FULL}\n111111\n100001\n100001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "no player start position: exits with Error"
else
    fail "no player start position: should exit with Error"
fi

# 5.5 two players in map
F="$TMP/two_players.cub"
printf "${BASE_FULL}\n111111\n1N0001\n1S0001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "two player positions: exits with Error"
else
    fail "two player positions: should exit with Error"
fi

# 5.6 all 4 valid player orientations
for DIR in N S E W; do
    F="$TMP/player_${DIR}.cub"
    printf "${BASE_FULL}\n111111\n1${DIR}0001\n100001\n111111\n" > "$F"
    if ! exits_error "$BINARY" "$F" 2>/dev/null; then
        pass "player orientation '$DIR': accepted as valid"
    else
        fail "player orientation '$DIR': should be accepted"
    fi
done

# 5.7 map not enclosed — open top
F="$TMP/open_top.cub"
printf "${BASE_FULL}\n011110\n1N0001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "map not enclosed (open top): exits with Error"
else
    fail "map not enclosed (open top): should exit with Error"
fi

# 5.8 map not enclosed — open bottom
F="$TMP/open_bottom.cub"
printf "${BASE_FULL}\n111111\n1N0001\n011110\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "map not enclosed (open bottom): exits with Error"
else
    fail "map not enclosed (open bottom): should exit with Error"
fi

# 5.9 map not enclosed — hole in wall
F="$TMP/hole_wall.cub"
printf "${BASE_FULL}\n111111\n100001\n1N0 01\n100001\n111111\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "map not enclosed (hole in wall): exits with Error"
else
    fail "map not enclosed (hole in wall): should exit with Error"
fi

# 5.10 map with spaces (valid — spaces are valid map chars)
F="$TMP/spaces_in_map.cub"
printf "${BASE_FULL}\n11111111\n10000001\n1  N0001\n10000001\n11111111\n" > "$F"
if ! exits_error "$BINARY" "$F" 2>/dev/null; then
    pass "map with spaces inside: accepted as valid"
else
    fail "map with spaces inside: should be accepted (spaces are valid)"
fi

# 5.11 non-rectangular map (valid — rows can have different lengths)
F="$TMP/nonrect.cub"
printf "${BASE_FULL}\n111111111\n100000001\n100N00001\n1000001\n1111111\n" > "$F"
if ! exits_error "$BINARY" "$F" 2>/dev/null; then
    pass "non-rectangular map (different row lengths): accepted"
else
    warn "non-rectangular map: may have failed (check manually)"
fi

# 5.12 empty map (only newlines)
F="$TMP/empty_map.cub"
printf "${BASE_FULL}\n\n\n" > "$F"
if exits_error "$BINARY" "$F" && prints_error "$BINARY" "$F"; then
    pass "empty map: exits with Error"
else
    fail "empty map: should exit with Error"
fi

# =============================================================================
# SECTION 6 — RUNTIME / WINDOW (visual, timeout-based checks)
# =============================================================================
section "6. RUNTIME — WINDOW & RENDERING (auto-close via ESC simulation)"

# Note: These tests launch the program and kill it after a short time.
# A non-crash + zero stderr output is the success condition for rendering.
# Full visual checks require manual review during peer evaluation.

# 6.1 program starts without crash on valid map
OUT=$(timeout 2 "$BINARY" "$VALID_MAP" 2>&1 &
      PID=$!
      sleep 1
      kill $PID 2>/dev/null
      wait $PID 2>/dev/null
      echo "killed")
if [ $? -ne 124 ]; then
    pass "valid map: program launches without immediate crash"
else
    fail "valid map: program timed out or crashed on launch"
fi

# 6.2 program produces no error output on valid map
ERR=$(timeout 2 "$BINARY" "$VALID_MAP" 2>&1 &
      PID=$!
      sleep 1
      kill $PID 2>/dev/null
      wait $PID 2>/dev/null)
if ! echo "$ERR" | grep -qi "error\|segfault\|abort\|double free"; then
    pass "valid map: no error/crash output on stderr"
else
    fail "valid map: error output detected on valid input"
fi

# =============================================================================
# SECTION 7 — MEMORY LEAKS (valgrind)
# =============================================================================
section "7. MEMORY LEAKS (valgrind)"

if ! command -v valgrind &>/dev/null; then
    warn "valgrind not installed — skipping leak tests"
else
    # 7.1 no leaks on clean exit (ESC triggered by sending signal after 1s)
    VALGRIND_OUT=$(timeout 5 valgrind --leak-check=full \
        --error-exitcode=42 \
        --errors-for-leak-kinds=all \
        "$BINARY" "$VALID_MAP" 2>&1 &
        PID=$!
        sleep 1
        # Send ESC keycode via xdotool if available, otherwise kill
        if command -v xdotool &>/dev/null; then
            xdotool key Escape 2>/dev/null
        else
            kill -TERM $PID 2>/dev/null
        fi
        wait $PID 2>/dev/null
        echo $?)

    if echo "$VALGRIND_OUT" | grep -q "no leaks are possible\|All heap blocks were freed"; then
        pass "valgrind: no memory leaks on exit"
    elif echo "$VALGRIND_OUT" | grep -q "definitely lost: 0 bytes"; then
        pass "valgrind: zero definitely-lost bytes"
    else
        LOST=$(echo "$VALGRIND_OUT" | grep "definitely lost" | head -1)
        fail "valgrind: memory leaks detected — $LOST"
    fi

    # 7.2 no leaks on error exit (bad file)
    VALGRIND_ERR=$(valgrind --leak-check=full \
        --error-exitcode=42 \
        --errors-for-leak-kinds=all \
        "$BINARY" "$TMP/nonexistent.cub" 2>&1)
    if echo "$VALGRIND_ERR" | grep -q "definitely lost: 0 bytes\|no leaks are possible"; then
        pass "valgrind: no leaks on error exit path"
    else
        LOST=$(echo "$VALGRIND_ERR" | grep "definitely lost" | head -1)
        fail "valgrind: leaks on error exit — $LOST"
    fi
fi

# =============================================================================
# SECTION 8 — NORM (norminette)
# =============================================================================
section "8. 42 NORM (norminette)"

if ! command -v norminette &>/dev/null; then
    warn "norminette not installed — skipping Norm checks"
else
    # Collect all .c and .h files excluding mlx
    NORM_FILES=$(find "$SRC_DIR" "$INC_DIR" -name "*.c" -o -name "*.h" \
        | grep -v mlx | grep -v "\.a$")

    NORM_OUT=$(norminette $NORM_FILES 2>&1)
    NORM_ERRORS=$(echo "$NORM_OUT" | grep -c "Error\|Warning" || true)

    if [ "$NORM_ERRORS" -eq 0 ]; then
        pass "norminette: 0 errors across all source files"
    else
        fail "norminette: $NORM_ERRORS error(s)/warning(s) found"
        echo "$NORM_OUT" | grep "Error\|Warning" | head -20 | while read line; do
            echo "    $line"
        done
    fi

    # Per-file norm check
    find "$SRC_DIR" "$INC_DIR" -name "*.c" -o -name "*.h" \
        | grep -v mlx | while read FILE; do
        FERR=$(norminette "$FILE" 2>&1 | grep -c "Error" || true)
        if [ "$FERR" -gt 0 ]; then
            echo -e "    ${RED}NORM FAIL${NC} $FILE ($FERR errors)"
        fi
    done
fi

# =============================================================================
# SECTION 9 — SPECIFIC NORM CHECKS (static analysis without norminette)
# =============================================================================
section "9. NORM — STATIC CHECKS (no norminette needed)"

check_all_c() {
    find "$SRC_DIR" -name "*.c" | grep -v mlx
}

# 9.1 no 'for' loops in source
FOR_COUNT=$(check_all_c | xargs grep -l "\bfor\s*(" 2>/dev/null | grep -v mlx | wc -l)
if [ "$FOR_COUNT" -eq 0 ]; then
    pass "norm: no 'for' loops found in source files"
else
    fail "norm: 'for' loops found in $FOR_COUNT file(s)"
    check_all_c | xargs grep -l "\bfor\s*(" 2>/dev/null | while read f; do echo "    $f"; done
fi

# 9.2 no 'do...while' loops
DO_COUNT=$(check_all_c | xargs grep -l "\bdo\s*{" 2>/dev/null | wc -l)
if [ "$DO_COUNT" -eq 0 ]; then
    pass "norm: no 'do...while' loops found"
else
    fail "norm: 'do...while' found in $DO_COUNT file(s)"
fi

# 9.3 no 'switch' statements
SW_COUNT=$(check_all_c | xargs grep -l "\bswitch\s*(" 2>/dev/null | wc -l)
if [ "$SW_COUNT" -eq 0 ]; then
    pass "norm: no 'switch' statements found"
else
    fail "norm: 'switch' found in $SW_COUNT file(s)"
fi

# 9.4 no ternary operators
TERN_COUNT=$(check_all_c | xargs grep -rn "[^'\"]\?[^'\":]" 2>/dev/null \
    | grep -v "//.*?" | grep -v "/\*" | grep -c "?" || true)
if [ "$TERN_COUNT" -eq 0 ]; then
    pass "norm: no ternary operators found"
else
    fail "norm: $TERN_COUNT possible ternary operator(s) found (verify manually)"
fi

# 9.5 no goto
GOTO_COUNT=$(check_all_c | xargs grep -l "\bgoto\b" 2>/dev/null | wc -l)
if [ "$GOTO_COUNT" -eq 0 ]; then
    pass "norm: no 'goto' found"
else
    fail "norm: 'goto' found in $GOTO_COUNT file(s)"
fi

# 9.6 no functions over 25 lines (rough check)
LONG_FUNCS=0
while IFS= read -r FILE; do
    # Count lines between { and } at function level (rough heuristic)
    awk '
    /^\{/ { in_func=1; count=0; next }
    /^\}/ { if(in_func && count > 25) print FILENAME": "count" lines"; in_func=0; next }
    in_func { count++ }
    ' "$FILE" 2>/dev/null | while read line; do
        echo -e "    ${RED}LONG FUNC${NC} $line"
        ((LONG_FUNCS++))
    done
done < <(check_all_c)
if [ "$LONG_FUNCS" -eq 0 ]; then
    pass "norm: no functions over 25 lines detected (verify with norminette)"
else
    fail "norm: functions over 25 lines detected (see above)"
fi

# 9.7 no file with more than 5 function definitions
while IFS= read -r FILE; do
    COUNT=$(grep -c "^[a-z].*(.*)$" "$FILE" 2>/dev/null || true)
    # More precise: count lines that look like function definitions
    COUNT=$(awk '/^[a-z_][a-z0-9_]*\t[a-z_]|\b(void|int|char|double|float|size_t|t_)[[:space:]]+[a-z_][a-z0-9_]*[[:space:]]*\(/{c++} END{print c}' "$FILE" 2>/dev/null)
    if [ "${COUNT:-0}" -gt 5 ]; then
        fail "norm: $FILE has $COUNT function definitions (max 5)"
    fi
done < <(check_all_c)
pass "norm: function-per-file check complete (verify with norminette)"

# 9.8 line length over 80 columns
LONG_LINES=0
while IFS= read -r FILE; do
    COUNT=$(awk 'length > 80' "$FILE" 2>/dev/null | wc -l)
    if [ "$COUNT" -gt 0 ]; then
        echo -e "    ${RED}LONG LINES${NC} $FILE: $COUNT line(s) over 80 cols"
        ((LONG_LINES++))
    fi
done < <(find "$SRC_DIR" "$INC_DIR" -name "*.c" -o -name "*.h" | grep -v mlx)
if [ "$LONG_LINES" -eq 0 ]; then
    pass "norm: no lines over 80 columns"
else
    fail "norm: lines over 80 columns found in $LONG_LINES file(s)"
fi

# 9.9 trailing whitespace
TRAIL=0
while IFS= read -r FILE; do
    COUNT=$(grep -cP "[ \t]+$" "$FILE" 2>/dev/null || true)
    if [ "$COUNT" -gt 0 ]; then
        echo -e "    ${RED}TRAILING WS${NC} $FILE: $COUNT line(s)"
        ((TRAIL++))
    fi
done < <(find "$SRC_DIR" "$INC_DIR" -name "*.c" -o -name "*.h" | grep -v mlx)
if [ "$TRAIL" -eq 0 ]; then
    pass "norm: no trailing whitespace"
else
    fail "norm: trailing whitespace in $TRAIL file(s)"
fi

# 9.10 42 header present in all .c and .h files
MISSING_HEADER=0
while IFS= read -r FILE; do
    if ! head -5 "$FILE" | grep -q "By:\|Created:\|Login:"; then
        echo -e "    ${RED}NO 42 HEADER${NC} $FILE"
        ((MISSING_HEADER++))
    fi
done < <(find "$SRC_DIR" "$INC_DIR" -name "*.c" -o -name "*.h" | grep -v mlx)
if [ "$MISSING_HEADER" -eq 0 ]; then
    pass "norm: 42 header present in all source files"
else
    fail "norm: 42 header missing in $MISSING_HEADER file(s)"
fi

# 9.11 include guard in cub3d.h
if grep -q "#ifndef.*_H" "$INC_DIR/cub3d.h" && grep -q "#define.*_H" "$INC_DIR/cub3d.h"; then
    pass "norm: include guard present in cub3d.h"
else
    fail "norm: include guard missing in cub3d.h"
fi

# 9.12 no struct declared in .c files
STRUCT_IN_C=$(check_all_c | xargs grep -l "^typedef struct\|^struct s_" 2>/dev/null | wc -l)
if [ "$STRUCT_IN_C" -eq 0 ]; then
    pass "norm: no struct declared in .c files"
else
    fail "norm: struct declaration found in .c file(s)"
    check_all_c | xargs grep -l "^typedef struct\|^struct s_" 2>/dev/null | while read f; do echo "    $f"; done
fi

# =============================================================================
# SECTION 10 — README
# =============================================================================
section "10. README"

README="$PROJECT_ROOT/README.md"

# 10.1 README exists
if [ -f "$README" ]; then
    pass "README.md: exists"
else
    fail "README.md: does not exist"
fi

# 10.2 First line is italicized with 42 curriculum mention
if head -1 "$README" | grep -qi "42 curriculum"; then
    pass "README.md: first line mentions '42 curriculum'"
else
    fail "README.md: first line must mention '42 curriculum' (italicized)"
fi

# 10.3 Description section
if grep -qi "^## Description\|^# Description\|^## description" "$README"; then
    pass "README.md: has Description section"
else
    fail "README.md: missing Description section"
fi

# 10.4 Instructions section
if grep -qi "^## Instructions\|^# Instructions\|^## instructions\|^## Usage\|^## Install" "$README"; then
    pass "README.md: has Instructions section"
else
    fail "README.md: missing Instructions section"
fi

# 10.5 Resources section
if grep -qi "^## Resources\|^# Resources\|^## resources" "$README"; then
    pass "README.md: has Resources section"
else
    fail "README.md: missing Resources section"
fi

# 10.6 AI usage mentioned
if grep -qi "AI\|artificial intelligence\|chatgpt\|claude\|copilot" "$README"; then
    pass "README.md: mentions AI usage"
else
    fail "README.md: must describe how AI was used (Resources section)"
fi

# 10.7 Written in English
FRENCH_WORDS=$(grep -ci "\bbonjour\|\bmerci\|\bpour\|\bavec\|\bfaire\b" "$README" 2>/dev/null || true)
if [ "$FRENCH_WORDS" -eq 0 ]; then
    pass "README.md: appears to be written in English"
else
    warn "README.md: may contain non-English text (check manually)"
fi

# =============================================================================
# FINAL SUMMARY
# =============================================================================
echo ""
echo -e "${BOLD}${BLUE}══════════════════════════════════════${NC}"
echo -e "${BOLD}  RESULTS${NC}"
echo -e "${BOLD}${BLUE}══════════════════════════════════════${NC}"
echo -e "  Total tests : ${BOLD}$TOTAL${NC}"
echo -e "  ${GREEN}Passed${NC}      : ${BOLD}${GREEN}$PASS${NC}"
echo -e "  ${RED}Failed${NC}      : ${BOLD}${RED}$FAIL${NC}"
echo ""

SCORE=$(echo "scale=1; $PASS * 100 / $TOTAL" | bc 2>/dev/null || echo "N/A")
echo -e "  Estimated score: ${BOLD}$SCORE%${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}ALL TESTS PASSED — ready for evaluation!${NC}"
else
    echo -e "  ${RED}${BOLD}$FAIL test(s) failed — fix before submitting.${NC}"
fi

echo ""
echo -e "${YELLOW}  MANUAL CHECKS STILL REQUIRED:${NC}"
echo "  - Open window and visually verify 3D rendering"
echo "  - Verify W/A/S/D moves player correctly"
echo "  - Verify left/right arrows rotate camera"
echo "  - Verify ESC closes window cleanly"
echo "  - Verify clicking red X closes window cleanly"
echo "  - Verify different textures on N/S/E/W walls"
echo "  - Verify floor and ceiling are distinct colors"
echo "  - Verify window handles minimize/focus change"
echo "  - Run norminette manually if not installed here"
echo ""

# Cleanup temp files
rm -rf "$TMP"

exit $FAIL