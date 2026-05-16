*This project has been created as part of the 42 curriculum by jalju-be.*

## Description

Cub3D is a raycasting-based 3D graphics project inspired by Wolfenstein 3D. It parses a scene description file (.cub) containing texture paths, floor/ceiling colors, and a map grid, then renders a first-person view using miniLibX. The engine uses DDA (Digital Differential Analyzer) raycasting to project textured walls onto a 2D window.

## Instructions

### Compilation
```bash
make        # build the cub3D binary
make clean  # remove object files
make fclean # remove object files and binary
make re     # rebuild from scratch
make bonus  # bonus rules (same as all)
```

### Usage
```bash
./cub3D maps/test.cub
```

### Controls
- `W` — Move forward
- `S` — Move backward
- `A` — Strafe left
- `D` — Strafe right
- `←` — Rotate camera left
- `→` — Rotate camera right
- `ESC` — Exit the program

### Dependencies
- **Compiler:** cc with -Wall -Wextra -Werror
- **Graphics:** miniLibX (X11, Xext, mlx_Linux)
- **Math library:** -lm
- **Norminette:** 42 coding style checker

## Resources

- [Lode's Raycasting Tutorial](https://lodev.org/cgtutor/raycasting.html)
- [42 miniLibX documentation](https://github.com/42Paris/minilibx-linux)
- [Wolfenstein 3D](https://en.wikipedia.org/wiki/Wolfenstein_3D)

### AI Usage

AI (opencode) was used to assist with the following tasks during development:
- Identifying norm violations and code issues across all source files
- Fixing segfaults in error-handling paths (cleanup/double-free)
- Correcting map validation logic for space characters
- Refactoring functions exceeding the 25-line norm limit
- Restructuring header files for norm compliance (include guard, 42 header)
- Formatting Makefile and removing dead code