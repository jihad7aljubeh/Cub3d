/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_map_utils.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jehad <jehad@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 16:05:43 by aabusnin          #+#    #+#             */
/*   Updated: 2026/05/13 02:42:15 by jehad            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

int	process_texture(t_game *g, char *line, int *count)
{
	if (!ft_strncmp(line, "NO ", 3) && !g->no_path)
		return (g->no_path = ft_strtrim(line + 2, " \t\n\r"), (*count)++, 1);
	if (!ft_strncmp(line, "SO ", 3) && !g->so_path)
		return (g->so_path = ft_strtrim(line + 2, " \t\n\r"), (*count)++, 1);
	if (!ft_strncmp(line, "EA ", 3) && !g->ea_path)
		return (g->ea_path = ft_strtrim(line + 2, " \t\n\r"), (*count)++, 1);
	if (!ft_strncmp(line, "WE ", 3) && !g->we_path)
		return (g->we_path = ft_strtrim(line + 2, " \t\n\r"), (*count)++, 1);
	if (!ft_strncmp(line, "NO ", 3) || !ft_strncmp(line, "SO ", 3)
		|| !ft_strncmp(line, "EA ", 3) || !ft_strncmp(line, "WE ", 3))
		return (-1);
	return (0);
}

int	process_color(t_game *g, char *line, int *count)
{
	if (!ft_strncmp(line, "F ", 2) && g->floor_color == -1)
	{
		g->floor_color = parse_color(line + 1);
		if (g->floor_color == -1)
			return (-1);
		return ((*count)++, 1);
	}
	if (!ft_strncmp(line, "C ", 2) && g->ceil_color == -1)
	{
		g->ceil_color = parse_color(line + 1);
		if (g->ceil_color == -1)
			return (-1);
		return ((*count)++, 1);
	}
	if (!ft_strncmp(line, "F ", 2) || !ft_strncmp(line, "C ", 2))
		return (-1);
	return (0);
}

int	store_map_row(t_game *g, char *line, int *i)
{
	char	*trimmed;

	trimmed = ft_strtrim(line, "\n");
	if (!trimmed)
		return (0);
	g->map.grid[*i] = trimmed;
	if ((int)ft_strlen(trimmed) > g->map.cols)
		g->map.cols = (int)ft_strlen(trimmed);
	(*i)++;
	return (1);
}

int	process_map_line(t_game *g, char *line, int *i, int *map_started)
{
	if (!*map_started && !is_identifier_line(line) && is_map_line(line))
		*map_started = 1;
	if (*map_started && is_map_line(line))
		return (store_map_row(g, line, i));
	if (*map_started && !is_empty(line))
		return (0);
	return (1);
}

void	set_player_plane(t_game *g, char c)
{
	if (c == 'N')
	{
		g->player.plane_x = 0.66;
		g->player.plane_y = 0;
	}
	else if (c == 'S')
	{
		g->player.plane_x = -0.66;
		g->player.plane_y = 0;
	}
	else if (c == 'E')
	{
		g->player.plane_x = 0;
		g->player.plane_y = 0.66;
	}
	else if (c == 'W')
	{
		g->player.plane_x = 0;
		g->player.plane_y = -0.66;
	}
}
