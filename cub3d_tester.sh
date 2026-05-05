#!/bin/bash
# ============================================================================
#  STRICT CUB3D TESTER (mandatory part)
#  - Map characters allowed: 0 (empty), 1 (wall), N S E W (player start)
#  - Tests every detail from the cub3D evaluation sheet
#  - Checks: arguments, file extension, identifiers, textures, RGB,
#           duplicates, missing elements, map closure, player, etc.
#
#  USAGE:
#    1. Place this script in the ROOT of your cub3D project (next to Makefile)
#    2. chmod +x cub3d_tester.sh
#    3. ./cub3d_tester.sh
#
#  Your executable MUST be named:  cub3D
#  On parsing errors your program MUST:
#      - print "Error\n" to STDERR (or at minimum contain "Error")
#      - exit with a non-zero status
#      - NOT open any window
# ============================================================================

EXEC="./cub3D"
MAPS_DIR="./tester_maps"
TEX_DIR="./tester_maps/textures"
LOG_DIR="./tester_logs"

# colors
G='\033[0;32m'   # green
R='\033[0;31m'   # red
Y='\033[1;33m'   # yellow
B='\033[1;34m'   # blue
C='\033[0;36m'   # cyan
W='\033[1;37m'   # white
N='\033[0m'      # reset

PASS=0
FAIL=0
TOTAL=0
FAILED_TESTS=()

# ----------------------------------------------------------------------------
# helpers
# ----------------------------------------------------------------------------

print_header() {
    echo -e "\n${B}============================================================${N}"
    echo -e "${B} $1${N}"
    echo -e "${B}============================================================${N}"
}

print_section() {
    echo -e "\n${C}--- $1 ---${N}"
}

# write file with literal content (preserves trailing spaces and empty lines)
write_map() {
    local path="$1"
    shift
    printf '%s\n' "$@" > "$path"
}

# check executable
check_exec() {
    if [ ! -f "$EXEC" ]; then
        echo -e "${R}[FATAL]${N} Executable '$EXEC' not found."
        echo -e "${Y}Run 'make' first or put this script next to your cub3D binary.${N}"
        exit 1
    fi
    if [ ! -x "$EXEC" ]; then
        echo -e "${R}[FATAL]${N} '$EXEC' is not executable."
        exit 1
    fi
}

# create dummy textures (xpm files)
make_textures() {
    mkdir -p "$TEX_DIR"
    # Minimal valid 2x2 xpm
    cat > "$TEX_DIR/wall.xpm" <<'EOF'
/* XPM */
static char *wall[] = {
"2 2 1 1",
"1 c #FF0000",
"11",
"11"
};
EOF
    cp "$TEX_DIR/wall.xpm" "$TEX_DIR/no.xpm"
    cp "$TEX_DIR/wall.xpm" "$TEX_DIR/so.xpm"
    cp "$TEX_DIR/wall.xpm" "$TEX_DIR/we.xpm"
    cp "$TEX_DIR/wall.xpm" "$TEX_DIR/ea.xpm"
}

# ----------------------------------------------------------------------------
# core test runners
# expected_result: "OK" -> should run without error (program must NOT print Error and exit 0
#                          OR open a window — we kill it after a short delay)
#                  "KO" -> should fail: print Error and exit non-zero, no window opened
# ----------------------------------------------------------------------------

run_invalid() {
    local name="$1"
    local file="$2"
    TOTAL=$((TOTAL+1))

    local out err code
    out=$(timeout 3s "$EXEC" "$file" 2>/tmp/cub_err </dev/null)
    code=$?
    err=$(cat /tmp/cub_err)

    # timeout -> 124 means a window probably opened => parser accepted invalid map
    if [ $code -eq 124 ]; then
        echo -e "  ${R}[KO]${N} $name  ${R}(window opened / hang on invalid map)${N}"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name : window opened on invalid map")
        return
    fi

    # must exit non-zero AND must mention "Error" somewhere
    if [ $code -eq 0 ]; then
        echo -e "  ${R}[KO]${N} $name  ${R}(exit 0 — should have failed)${N}"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name : exited 0, expected error")
        return
    fi

    local combined="${out}${err}"
    if ! echo "$combined" | grep -qi "error"; then
        echo -e "  ${R}[KO]${N} $name  ${R}(no 'Error' message printed)${N}"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name : missing Error message")
        return
    fi

    echo -e "  ${G}[OK]${N} $name"
    PASS=$((PASS+1))
}

run_valid() {
    local name="$1"
    local file="$2"
    TOTAL=$((TOTAL+1))

    local out err code
    out=$(timeout 2s "$EXEC" "$file" 2>/tmp/cub_err </dev/null)
    code=$?
    err=$(cat /tmp/cub_err)

    # 124 = timeout: program is still running -> good (window opened)
    if [ $code -eq 124 ]; then
        echo -e "  ${G}[OK]${N} $name  ${C}(window opened)${N}"
        PASS=$((PASS+1))
        return
    fi

    local combined="${out}${err}"
    if echo "$combined" | grep -qi "error"; then
        echo -e "  ${R}[KO]${N} $name  ${R}(printed Error on a valid map)${N}"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name : false positive — valid map rejected")
        return
    fi

    if [ $code -ne 0 ]; then
        echo -e "  ${R}[KO]${N} $name  ${R}(exit code $code on a valid map)${N}"
        FAIL=$((FAIL+1))
        FAILED_TESTS+=("$name : non-zero exit on valid map")
        return
    fi

    echo -e "  ${G}[OK]${N} $name"
    PASS=$((PASS+1))
}

# ============================================================================
# build all the test maps
# ============================================================================

build_maps() {
    rm -rf "$MAPS_DIR"
    mkdir -p "$MAPS_DIR/invalid" "$MAPS_DIR/valid"
    make_textures

    local NO="NO $TEX_DIR/no.xpm"
    local SO="SO $TEX_DIR/so.xpm"
    local WE="WE $TEX_DIR/we.xpm"
    local EA="EA $TEX_DIR/ea.xpm"
    local F="F 220,100,0"
    local C="C 225,30,0"

    # =====================================================================
    # VALID MAPS
    # =====================================================================

    # 1. minimal valid map
    cat > "$MAPS_DIR/valid/01_basic.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

111111
100001
10N001
100001
111111
EOF

    # 2. valid with empty lines between identifiers (allowed by subject)
    cat > "$MAPS_DIR/valid/02_empty_lines.cub" <<EOF
$NO

$SO

$WE

$EA

$F
$C

111111
100001
1000S1
100001
111111
EOF

    # 3. identifiers in random order (allowed)
    cat > "$MAPS_DIR/valid/03_order.cub" <<EOF
$C
$F
$EA
$WE
$SO
$NO

11111
100E1
10001
11111
EOF

    # 4. RGB with extra spaces (allowed: "each info from element separated by 1+ spaces")
    cat > "$MAPS_DIR/valid/04_rgb_spaces.cub" <<EOF
$NO
$SO
$WE
$EA
F   255 ,  100  , 50
C 0,0,0

11111
100W1
10001
11111
EOF

    # 5. map with spaces inside (subject: spaces are valid)
    cat > "$MAPS_DIR/valid/05_spaces_in_map.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

        1111111
        1000001
   11111000001
   1   000N0001
   1   011111111
   11111
EOF

    # 6. boundary RGB values
    cat > "$MAPS_DIR/valid/06_rgb_bounds.cub" <<EOF
$NO
$SO
$WE
$EA
F 0,0,0
C 255,255,255

111
1N1
111
EOF

    # 7. each player direction
    for dir in N S E W; do
        cat > "$MAPS_DIR/valid/07_player_${dir}.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
100${dir}1
10001
11111
EOF
    done

    # =====================================================================
    # INVALID MAPS
    # =====================================================================

    # ---- file / extension errors ----
    cp "$MAPS_DIR/valid/01_basic.cub" "$MAPS_DIR/invalid/wrong_ext.cu"
    cp "$MAPS_DIR/valid/01_basic.cub" "$MAPS_DIR/invalid/wrong_ext.cubb"
    cp "$MAPS_DIR/valid/01_basic.cub" "$MAPS_DIR/invalid/no_ext"
    cp "$MAPS_DIR/valid/01_basic.cub" "$MAPS_DIR/invalid/.cub"
    : > "$MAPS_DIR/invalid/empty.cub"

    # ---- missing identifiers ----
    cat > "$MAPS_DIR/invalid/missing_NO.cub" <<EOF
$SO
$WE
$EA
$F
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/missing_SO.cub" <<EOF
$NO
$WE
$EA
$F
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/missing_WE.cub" <<EOF
$NO
$SO
$EA
$F
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/missing_EA.cub" <<EOF
$NO
$SO
$WE
$F
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/missing_F.cub" <<EOF
$NO
$SO
$WE
$EA
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/missing_C.cub" <<EOF
$NO
$SO
$WE
$EA
$F

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/missing_map.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C
EOF

    # ---- duplicate identifiers ----
    cat > "$MAPS_DIR/invalid/dup_NO.cub" <<EOF
$NO
$NO
$SO
$WE
$EA
$F
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/dup_F.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$F
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/dup_C.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C
$C

111
1N1
111
EOF

    # ---- bad texture path ----
    cat > "$MAPS_DIR/invalid/bad_tex_path.cub" <<EOF
NO ./does_not_exist.xpm
$SO
$WE
$EA
$F
$C

111
1N1
111
EOF

    cat > "$MAPS_DIR/invalid/tex_no_path.cub" <<EOF
NO
$SO
$WE
$EA
$F
$C

111
1N1
111
EOF

    cat > "$MAPS_DIR/invalid/tex_dir_not_file.cub" <<EOF
NO ./tester_maps
$SO
$WE
$EA
$F
$C

111
1N1
111
EOF

    cat > "$MAPS_DIR/invalid/tex_wrong_ext.cub" <<EOF
NO ./tester_maps/textures/wall.txt
$SO
$WE
$EA
$F
$C

111
1N1
111
EOF
    cp "$TEX_DIR/wall.xpm" "$TEX_DIR/wall.txt"

    # ---- bad RGB ----
    cat > "$MAPS_DIR/invalid/rgb_neg.cub" <<EOF
$NO
$SO
$WE
$EA
F -1,0,0
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/rgb_over_255.cub" <<EOF
$NO
$SO
$WE
$EA
F 256,0,0
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/rgb_only_two.cub" <<EOF
$NO
$SO
$WE
$EA
F 100,100
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/rgb_four_values.cub" <<EOF
$NO
$SO
$WE
$EA
F 100,100,100,100
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/rgb_letters.cub" <<EOF
$NO
$SO
$WE
$EA
F a,b,c
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/rgb_empty.cub" <<EOF
$NO
$SO
$WE
$EA
F
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/rgb_no_commas.cub" <<EOF
$NO
$SO
$WE
$EA
F 100 100 100
$C

111
1N1
111
EOF
    cat > "$MAPS_DIR/invalid/rgb_trailing_comma.cub" <<EOF
$NO
$SO
$WE
$EA
F 100,100,100,
$C

111
1N1
111
EOF

    # ---- map characters ----
    cat > "$MAPS_DIR/invalid/bad_char.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
1N0X1
10001
11111
EOF
    cat > "$MAPS_DIR/invalid/bad_char_digit.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
1N021
10001
11111
EOF
    cat > "$MAPS_DIR/invalid/tab_in_map.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
1$(printf '\t')0N1
10001
11111
EOF

    # ---- player issues ----
    cat > "$MAPS_DIR/invalid/no_player.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
10001
10001
11111
EOF
    cat > "$MAPS_DIR/invalid/two_players.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
1N0S1
10001
11111
EOF
    cat > "$MAPS_DIR/invalid/two_same_players.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
1N0N1
10001
11111
EOF

    # ---- map not closed ----
    cat > "$MAPS_DIR/invalid/open_top.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

10001
10001
1N001
11111
EOF
    cat > "$MAPS_DIR/invalid/open_bottom.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
1N001
10001
10001
EOF
    cat > "$MAPS_DIR/invalid/open_left.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
N0001
10001
11111
EOF
    cat > "$MAPS_DIR/invalid/open_right.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
1000N
10001
11111
EOF
    cat > "$MAPS_DIR/invalid/hole_inside.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

1111111
1000001
100 0001
10N0001
1111111
EOF
    cat > "$MAPS_DIR/invalid/zero_touches_space.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

1111111
10000 1
10N0001
1111111
EOF
    cat > "$MAPS_DIR/invalid/player_on_edge.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11N11
10001
11111
EOF

    # ---- map not last ----
    cat > "$MAPS_DIR/invalid/map_not_last.cub" <<EOF
$NO
$SO
$WE
$EA
$F

111
1N1
111

$C
EOF

    cat > "$MAPS_DIR/invalid/text_after_map.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

111
1N1
111
some_garbage_here
EOF

    # ---- empty map area / only spaces ----
    cat > "$MAPS_DIR/invalid/only_spaces_map.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

   
   
EOF

    # ---- unknown identifier ----
    cat > "$MAPS_DIR/invalid/unknown_id.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C
XX foo

111
1N1
111
EOF

    # ---- texture identifier wrong case ----
    cat > "$MAPS_DIR/invalid/lowercase_id.cub" <<EOF
no $TEX_DIR/no.xpm
$SO
$WE
$EA
$F
$C

111
1N1
111
EOF

    # ---- 1x1 / too small (no possible enclosed map) ----
    cat > "$MAPS_DIR/invalid/single_player.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

N
EOF

    # ---- map only of 0s (not closed) ----
    cat > "$MAPS_DIR/invalid/all_zeros.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

00000
0N000
00000
EOF

    # ---- map only of 1s (no player) ----
    cat > "$MAPS_DIR/invalid/all_ones.cub" <<EOF
$NO
$SO
$WE
$EA
$F
$C

11111
11111
11111
EOF
}

# ============================================================================
# argument tests (no map file involved)
# ============================================================================

run_no_args() {
    local name="argv: no arguments"
    TOTAL=$((TOTAL+1))
    local out err code
    out=$(timeout 3s "$EXEC" 2>/tmp/cub_err </dev/null)
    code=$?
    err=$(cat /tmp/cub_err)
    if [ $code -eq 0 ]; then
        echo -e "  ${R}[KO]${N} $name  ${R}(exit 0)${N}"
        FAIL=$((FAIL+1)); FAILED_TESTS+=("$name")
        return
    fi
    echo -e "  ${G}[OK]${N} $name"
    PASS=$((PASS+1))
}

run_too_many_args() {
    local name="argv: too many arguments"
    TOTAL=$((TOTAL+1))
    local out err code
    out=$(timeout 3s "$EXEC" "$MAPS_DIR/valid/01_basic.cub" "$MAPS_DIR/valid/01_basic.cub" 2>/tmp/cub_err </dev/null)
    code=$?
    if [ $code -eq 124 ]; then
        echo -e "  ${R}[KO]${N} $name  ${R}(window opened)${N}"
        FAIL=$((FAIL+1)); FAILED_TESTS+=("$name")
        return
    fi
    if [ $code -eq 0 ]; then
        echo -e "  ${R}[KO]${N} $name  ${R}(accepted multiple args)${N}"
        FAIL=$((FAIL+1)); FAILED_TESTS+=("$name")
        return
    fi
    echo -e "  ${G}[OK]${N} $name"
    PASS=$((PASS+1))
}

run_nonexistent_file() {
    local name="argv: nonexistent .cub file"
    TOTAL=$((TOTAL+1))
    local code
    timeout 3s "$EXEC" "/tmp/__no_such_map_xxx.cub" >/dev/null 2>/tmp/cub_err </dev/null
    code=$?
    if [ $code -eq 0 ] || [ $code -eq 124 ]; then
        echo -e "  ${R}[KO]${N} $name"
        FAIL=$((FAIL+1)); FAILED_TESTS+=("$name")
        return
    fi
    echo -e "  ${G}[OK]${N} $name"
    PASS=$((PASS+1))
}

# ============================================================================
# main
# ============================================================================

main() {
    print_header "STRICT CUB3D TESTER"
    check_exec
    mkdir -p "$LOG_DIR"
    build_maps

    print_section "Argument handling"
    run_no_args
    run_too_many_args
    run_nonexistent_file

    print_section "File / extension errors  (must FAIL)"
    run_invalid "wrong extension .cu"           "$MAPS_DIR/invalid/wrong_ext.cu"
    run_invalid "wrong extension .cubb"         "$MAPS_DIR/invalid/wrong_ext.cubb"
    run_invalid "no extension"                  "$MAPS_DIR/invalid/no_ext"
    run_invalid "filename only '.cub'"          "$MAPS_DIR/invalid/.cub"
    run_invalid "empty .cub file"               "$MAPS_DIR/invalid/empty.cub"

    print_section "Missing identifiers  (must FAIL)"
    run_invalid "missing NO texture"            "$MAPS_DIR/invalid/missing_NO.cub"
    run_invalid "missing SO texture"            "$MAPS_DIR/invalid/missing_SO.cub"
    run_invalid "missing WE texture"            "$MAPS_DIR/invalid/missing_WE.cub"
    run_invalid "missing EA texture"            "$MAPS_DIR/invalid/missing_EA.cub"
    run_invalid "missing F (floor)"             "$MAPS_DIR/invalid/missing_F.cub"
    run_invalid "missing C (ceiling)"           "$MAPS_DIR/invalid/missing_C.cub"
    run_invalid "missing map"                   "$MAPS_DIR/invalid/missing_map.cub"

    print_section "Duplicate identifiers  (must FAIL)"
    run_invalid "duplicate NO"                  "$MAPS_DIR/invalid/dup_NO.cub"
    run_invalid "duplicate F"                   "$MAPS_DIR/invalid/dup_F.cub"
    run_invalid "duplicate C"                   "$MAPS_DIR/invalid/dup_C.cub"

    print_section "Texture errors  (must FAIL)"
    run_invalid "texture path doesn't exist"    "$MAPS_DIR/invalid/bad_tex_path.cub"
    run_invalid "texture identifier no path"    "$MAPS_DIR/invalid/tex_no_path.cub"
    run_invalid "texture path is a directory"   "$MAPS_DIR/invalid/tex_dir_not_file.cub"
    run_invalid "texture wrong extension .txt"  "$MAPS_DIR/invalid/tex_wrong_ext.cub"
    run_invalid "lowercase identifier 'no'"     "$MAPS_DIR/invalid/lowercase_id.cub"
    run_invalid "unknown identifier"            "$MAPS_DIR/invalid/unknown_id.cub"

    print_section "RGB color errors  (must FAIL)"
    run_invalid "RGB negative value"            "$MAPS_DIR/invalid/rgb_neg.cub"
    run_invalid "RGB > 255"                     "$MAPS_DIR/invalid/rgb_over_255.cub"
    run_invalid "RGB only 2 values"             "$MAPS_DIR/invalid/rgb_only_two.cub"
    run_invalid "RGB 4 values"                  "$MAPS_DIR/invalid/rgb_four_values.cub"
    run_invalid "RGB letters"                   "$MAPS_DIR/invalid/rgb_letters.cub"
    run_invalid "RGB empty"                     "$MAPS_DIR/invalid/rgb_empty.cub"
    run_invalid "RGB no commas"                 "$MAPS_DIR/invalid/rgb_no_commas.cub"
    run_invalid "RGB trailing comma"            "$MAPS_DIR/invalid/rgb_trailing_comma.cub"

    print_section "Map characters  (must FAIL)"
    run_invalid "invalid char 'X' in map"       "$MAPS_DIR/invalid/bad_char.cub"
    run_invalid "invalid digit '2' in map"      "$MAPS_DIR/invalid/bad_char_digit.cub"
    run_invalid "TAB inside map"                "$MAPS_DIR/invalid/tab_in_map.cub"

    print_section "Player errors  (must FAIL)"
    run_invalid "no player"                     "$MAPS_DIR/invalid/no_player.cub"
    run_invalid "two players (N + S)"           "$MAPS_DIR/invalid/two_players.cub"
    run_invalid "two players (N + N)"           "$MAPS_DIR/invalid/two_same_players.cub"
    run_invalid "player on edge / not closed"   "$MAPS_DIR/invalid/player_on_edge.cub"

    print_section "Map closure  (must FAIL)"
    run_invalid "open at top"                   "$MAPS_DIR/invalid/open_top.cub"
    run_invalid "open at bottom"                "$MAPS_DIR/invalid/open_bottom.cub"
    run_invalid "open on left"                  "$MAPS_DIR/invalid/open_left.cub"
    run_invalid "open on right"                 "$MAPS_DIR/invalid/open_right.cub"
    run_invalid "hole inside (space adj 0)"     "$MAPS_DIR/invalid/hole_inside.cub"
    run_invalid "0 touches outside space"       "$MAPS_DIR/invalid/zero_touches_space.cub"
    run_invalid "all zeros (no walls)"          "$MAPS_DIR/invalid/all_zeros.cub"
    run_invalid "all ones (no player)"          "$MAPS_DIR/invalid/all_ones.cub"
    run_invalid "single player char only"       "$MAPS_DIR/invalid/single_player.cub"

    print_section "Map placement  (must FAIL)"
    run_invalid "map is not last (id after)"    "$MAPS_DIR/invalid/map_not_last.cub"
    run_invalid "garbage after map"             "$MAPS_DIR/invalid/text_after_map.cub"
    run_invalid "map area only spaces"          "$MAPS_DIR/invalid/only_spaces_map.cub"

    print_section "Valid maps  (must PASS — opens window or runs cleanly)"
    run_valid "basic valid map"                 "$MAPS_DIR/valid/01_basic.cub"
    run_valid "valid with empty lines"          "$MAPS_DIR/valid/02_empty_lines.cub"
    run_valid "identifiers in random order"     "$MAPS_DIR/valid/03_order.cub"
    run_valid "RGB with extra spaces"           "$MAPS_DIR/valid/04_rgb_spaces.cub"
    run_valid "spaces inside map"               "$MAPS_DIR/valid/05_spaces_in_map.cub"
    run_valid "RGB at boundaries 0/255"         "$MAPS_DIR/valid/06_rgb_bounds.cub"
    run_valid "player facing N"                 "$MAPS_DIR/valid/07_player_N.cub"
    run_valid "player facing S"                 "$MAPS_DIR/valid/07_player_S.cub"
    run_valid "player facing E"                 "$MAPS_DIR/valid/07_player_E.cub"
    run_valid "player facing W"                 "$MAPS_DIR/valid/07_player_W.cub"

    # =====================================================================
    # summary
    # =====================================================================
    print_header "RESULTS"
    echo -e "  Total : ${W}$TOTAL${N}"
    echo -e "  Pass  : ${G}$PASS${N}"
    echo -e "  Fail  : ${R}$FAIL${N}"

    if [ $FAIL -gt 0 ]; then
        echo -e "\n${R}Failed tests:${N}"
        for t in "${FAILED_TESTS[@]}"; do
            echo -e "  ${R}*${N} $t"
        done
        echo
        exit 1
    fi
    echo -e "\n${G}All tests passed!${N}\n"
    exit 0
}

main "$@"
