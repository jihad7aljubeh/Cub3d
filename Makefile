NAME    = cub3D
CC      = cc
CFLAGS  = -Wall -Wextra -Werror
MLX_DIR = code/mlx_linux
MLX_URL = https://github.com/42Paris/minilibx-linux.git
MLX     = $(MLX_DIR)/libmlx_Linux.a
LIBFT   = code/libft/libft.a
LIBS    = -L$(MLX_DIR) -lmlx_Linux -lXext -lX11 -lm

OBJS_DIR = code/objs

SRCS    = code/src/main.c \
          code/src/init/init.c \
          code/src/parsing/parse_files.c \
          code/src/parsing/parse_map.c \
          code/src/parsing/parse_textures.c \
          code/src/parsing/validate_map.c \
          code/src/parsing/val_utils.c \
		  code/src/parsing/parse_color.c \
          code/src/engine/raycaster.c \
          code/src/engine/render.c \
          code/src/engine/textures.c \
          code/src/player/movement.c \
          code/src/player/hooks.c \
          code/src/cleanup/cleanup.c

OBJS    = $(SRCS:%.c=$(OBJS_DIR)/%.o)

all: $(MLX) $(LIBFT) $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LIBFT) $(LIBS) -o $(NAME)

$(MLX):
	rm -rf $(MLX_DIR)
	git clone $(MLX_URL) $(MLX_DIR)
	make -C $(MLX_DIR)

$(LIBFT):
	make -C code/libft

$(OBJS_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -Iincludes -I$(MLX_DIR) -Icode/libft/includes -c $< -o $@

clean:
	rm -rf $(OBJS_DIR)
	make -C code/libft clean


fclean: clean
	rm -f $(NAME)
	make -C code/libft fclean
	rm -rf $(MLX_DIR)

re: fclean all

.PHONY: all clean fclean re