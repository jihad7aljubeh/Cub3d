/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_map.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jalju-be <jalju-be@student.42amman.com>    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 16:05:43 by aabusnin          #+#    #+#             */
/*   Updated: 2026/05/13 20:24:34 by jalju-be         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

void	set_player_dir_vector(t_game *g, char c)
{
	if (c == 'N')
	{
		g->player.dir_x = 0;
		g->player.dir_y = -1;
	}
	else if (c == 'S')
	{
		g->player.dir_x = 0;
		g->player.dir_y = 1;
	}
	else if (c == 'E')
	{
		g->player.dir_x = 1;
		g->player.dir_y = 0;
	}
	else if (c == 'W')
	{
		g->player.dir_x = -1;
		g->player.dir_y = 0;
	}
}

static int	init_player_from_map(t_game *g)
{
	int	r;
	int	c;
	int	cnt;

	r = 0;
	cnt = 0;
	while (r < g->map.rows)
	{
		c = 0;
		while (g->map.grid[r][c])
		{
			if (ft_strchr("NSEW", g->map.grid[r][c]))
			{
				cnt++;
				g->player.x = c + 0.5;
				g->player.y = r + 0.5;
				set_player_dir(g, g->map.grid[r][c]);
			}
			c++;
		}
		r++;
	}
	return (cnt == 1);
}

static int	read_map_lines(t_game *g, int fd)
{
	char	*line;
	int		i;
	int		map_started;
	int		id_count;

	i = 0;
	g->map.cols = 0;
	map_started = 0;
	id_count = 0;
	line = get_next_line(fd);
	while (line != NULL)
	{
		if (!is_empty(line) && !process_map_line(g, line, &i, &map_started))
			return (free_fire(line));
		if (!is_empty(line) && !map_started
			&& process_id(g, line, &id_count) == -1)
			return (free_fire(line));
		free(line);
		line = get_next_line(fd);
	}
	g->map.grid[i] = NULL;
	g->map.rows = i;
	return (1);
}

int	parse_map(t_game *game, char *av)
{
	int	fd;

	if (!has_cub_extension(av))
		return (0);
	game->floor_color = -1;
	game->ceil_color = -1;
	fd = open(av, O_RDONLY);
	if (fd < 0)
		return (0);
	game->map.grid = malloc(sizeof(char *) * 4096);
	if (!game->map.grid)
		return (close_free_map(game, fd, 0));
	if (!read_map_lines(game, fd))
		return (close_free_map(game, fd, 1));
	close(fd);
	if (game->map.rows == 0 || !game->no_path || !game->so_path
		|| !game->ea_path || !game->we_path)
		return (0);
	if (game->floor_color == -1 || game->ceil_color == -1)
		return (0);
	return (init_player_from_map(game));
}

int	parse_file(t_game *game, char *av)
{
	if (!parse_map(game, av))
		return (0);
	if (!validate_map(game))
		return (0);
	if (!finalize_map(game))
		return (0);
	return (1);
}
