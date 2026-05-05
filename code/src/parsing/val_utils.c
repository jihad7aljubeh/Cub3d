/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   val_utils.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jehad <jehad@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/23 04:49:35 by jehad             #+#    #+#             */
/*   Updated: 2026/05/03 06:00:12 by jehad            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

void	flood_fill(char **grid, t_map *map, int x, int y)
{
	char	c;

	if (x < 0 || x >= map->cols || y < 0 || y >= map->rows)
		return ;
	if (x >= (int)ft_strlen(grid[y]))
		return ;
	c = grid[y][x];
	if (c == '1' || c == 'F' || c == ' ')
		return ;
	grid[y][x] = 'F';
	flood_fill(grid, map, x + 1, y);
	flood_fill(grid, map, x - 1, y);
	flood_fill(grid, map, x, y + 1);
	flood_fill(grid, map, x, y - 1);
}

int	player_position(t_game *game, int *x, int *y)
{
	int	i;
	int	j;

	i = 0;
	while (game->map.grid[i])
	{
		j = 0;
		while (game->map.grid[i][j])
		{
			if (ft_strchr("NSEW", game->map.grid[i][j]))
				return (*x = j, *y = i, 1);
			j++;
		}
		i++;
	}
	return (0);
}

int	check_flood(char **grid, int rows, int cols)
{
	int		i;
	int		j;
	char	c;

	i = 0;
	while (i < rows)
	{
		j = 0;
		while (j < cols)
		{
			if (j >= (int)ft_strlen(grid[i]))
				c = ' ';
			else
				c = grid[i][j];
			if (ft_strchr("0NSEW", c))
				return (0);
			j++;
		}
		i++;
	}
	return (1);
}

void	free_grid(char **grid, int rows)
{
	int	i;

	i = 0;
	while (i < rows && grid && grid[i])
	{
		free(grid[i]);
		i++;
	}
	if (grid)
		free(grid);
}

char	**pad_grid(t_game *game)
{
	char	**cpy;
	int		i;
	int		len;

	cpy = malloc(sizeof(char *) * (game->map.rows + 1));
	if (!cpy)
		return (NULL);
	i = 0;
	while (i < game->map.rows)
	{
		len = ft_strlen(game->map.grid[i]);
		cpy[i] = malloc(game->map.cols + 1);
		if (!cpy[i])
			return (free_grid(cpy, i), NULL);
		ft_memcpy(cpy[i], game->map.grid[i], len);
		ft_memset(cpy[i] + len, ' ', game->map.cols - len);
		cpy[i][game->map.cols] = '\0';
		i++;
	}
	cpy[i] = NULL;
	return (cpy);
}
