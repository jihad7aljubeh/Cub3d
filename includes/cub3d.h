/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   cub3d.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jehad <jehad@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 15:57:08 by aabusnin          #+#    #+#             */
/*   Updated: 2026/05/05 10:34:26 by jehad            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef CUB3D_H
# define CUB3D_H

# define WIN_WIDTH 1200
# define WIN_HEIGHT 800

# define KEY_ESC 65307
# define KEY_W 119
# define KEY_A 97
# define KEY_S 115
# define KEY_D 100
# define KEY_LEFT 65361
# define KEY_RIGHT 65363

# define MOVE_SPEED 0.05
# define ROT_SPEED 0.03

# include "../code/libft/libft.h"
# include "../code/mlx_linux/mlx.h"
# include <errno.h>
# include <fcntl.h>
# include <math.h>
# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>

typedef struct s_map
{
	char		**grid;
	int			rows;
	int			cols;
}				t_map;

typedef struct s_player
{
	double		x;
	double		y;
	double		dir_x;
	double		dir_y;
	double		plane_x;
	double		plane_y;
}				t_player;

typedef struct s_tex
{
	void		*img;
	char		*addr;
	int			width;
	int			height;
	int			bpp;
	int			line_len;
	int			endian;
}				t_tex;

typedef struct s_textures
{
	t_tex		north;
	t_tex		south;
	t_tex		east;
	t_tex		west;
}				t_textures;

typedef struct s_keys
{
	int			w;
	int			a;
	int			s;
	int			d;
	int			left;
	int			right;
}				t_keys;

typedef struct s_ray
{
	double		cam_x;
	double		dir_x;
	double		dir_y;
	int			map_x;
	int			map_y;
	double		side_dist_x;
	double		side_dist_y;
	double		delta_dist_x;
	double		delta_dist_y;
	double		perp_wall_dist;
	int			step_x;
	int			step_y;
	int			hit;
	int			side;
	int			line_height;
	int			draw_start;
	int			draw_end;
	int			tex_x;
}				t_ray;

typedef struct s_game
{
	void		*mlx;
	void		*win;
	void		*img;
	char		*img_addr;
	int			bpp;
	int			line_len;
	int			endian;
	t_map		map;
	t_player	player;
	t_textures	tex;
	t_keys		keys;
	int			floor_color;
	int			ceil_color;
	char		*no_path;
	char		*so_path;
	char		*ea_path;
	char		*we_path;
}				t_game;

/***********************************/
/*************PARSING***************/
/***********************************/
int				parse_file(t_game *game, char *av);
int				parse_map(t_game *game, char *av);

int				validate_map(t_game *game);
int				player_position(t_game *game, int *x, int *y);
int				check_flood(char **grid, int rows, int cols);
int				parse_color(char *line);
int				process_texture(t_game *g, char *line, int *count);
int				process_color(t_game *g, char *line, int *count);	
int				store_map_row(t_game *g, char *line, int *i);
int				process_map_line(t_game *g,
					char *line, int *i, int *map_started);
int				process_id(t_game *g, char *line, int *count);
int				parse_map(t_game *game, char *av);
void			set_player_plane(t_game *g, char c);
void			set_player_dir(t_game *g, char c);

/***********************************/
/*************VALIDATION UTILS*****/
/***********************************/
void			free_grid(char **grid, int rows);
char			**pad_grid(t_game *game);
char			**dup_grid(t_game *game);
int				check_space_flow(t_game *game);
int				player_position(t_game *game, int *x, int *y);
int				check_flood(char **grid, int rows, int cols);

/***********************************/
/*************CLEANUP***************/
/***********************************/
void			error_exit(char *msg);
void			cleanup(t_game *game);
int				render_frame(t_game *game);
void			init_game(t_game *game);

/***********************************/
/*************ENGINE***************/
/***********************************/
void			raycaster(t_game *game);
void			ft_pixel_put(t_game *game, int x, int y, int color);
int				get_tex_color(t_tex *tex, int x, int y);

/***********************************/
/*************PLAYER***************/
/***********************************/
void			setup_hooks(t_game *game);
int				key_press(int keycode, t_game *game);
int				close_window(t_game *game);

/***********************************/
/*************MOVEMENT***************/
/***********************************/
void			move_forward_back(t_game *g, double direction);
void			move_left_right(t_game *g, double direction);
void			rotate_player(t_game *g, double rot_dir);
void			update_movement(t_game *g);

#endif
