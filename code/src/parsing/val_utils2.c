/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   val_utils2.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jehad <jehad@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/23 04:49:35 by jehad             #+#    #+#             */
/*   Updated: 2026/05/03 06:00:12 by jehad            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

char	**dup_grid(t_game *game)
{
	char	**cpy;
	int		i;

	cpy = malloc(sizeof(char *) * (game->map.rows + 1));
	if (!cpy)
		return (NULL);
	i = 0;
	while (i < game->map.rows)
	{
		cpy[i] = ft_strdup(game->map.grid[i]);
		if (!cpy[i])
			return (NULL);
		i++;
	}
	cpy[i] = NULL;
	return (cpy);
}

void	mark_outside_space(char **grid, t_map *map, int r, int c)
{
	if (r < 0 || r >= map->rows || c < 0 || c >= map->cols
		|| grid[r][c] != ' ')
		return ;
	grid[r][c] = 'X';
	mark_outside_space(grid, map, r + 1, c);
	mark_outside_space(grid, map, r - 1, c);
	mark_outside_space(grid, map, r, c + 1);
	mark_outside_space(grid, map, r, c - 1);
}

int	check_space_flow(t_game *game)
{
	int	r;
	int	c;
	int	floor_seen;

	r = 0;
	while (r < game->map.rows)
	{
		floor_seen = 0;
		c = 0;
		while (game->map.grid[r][c])
		{
			if (game->map.grid[r][c] == '0' || ft_strchr("NSEW",
					game->map.grid[r][c]))
				floor_seen = 1;
			else if (game->map.grid[r][c] == ' ' && floor_seen)
				return (0);
			c++;
		}
		r++;
	}
	return (1);
}
