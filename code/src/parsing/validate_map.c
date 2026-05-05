/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   validate_map.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jalju-be <jalju-be@student.42amman.com>    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 16:06:42 by aabusnin          #+#    #+#             */
/*   Updated: 2026/05/05 19:11:12 by jalju-be         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

static int	check_map1(t_game *game)
{
	int	i;
	int	j;
	int	p_cnt;
	int	w_cnt;

	i = -1;
	p_cnt = 0;
	w_cnt = 0;
	while (game->map.grid[++i])
	{
		j = -1;
		while (game->map.grid[i][++j])
		{
			if (!ft_strchr("01NSEW ", game->map.grid[i][j]))
				return (0);
			if (ft_strchr("NSEW", game->map.grid[i][j]))
				p_cnt++;
			else if (game->map.grid[i][j] == '1')
				w_cnt++;
		}
	}
	return (p_cnt == 1 && w_cnt > 0);
}

static int	check_map_closure(char **grid, t_game *game)
{
	int	r;
	int	c;

	r = -1;
	while (++r < game->map.rows)
	{
		c = -1;
		while (++c < game->map.cols)
		{
			if (grid[r][c] == ' ' && (r == 0 || r == game->map.rows - 1
					|| c == 0 || c == game->map.cols - 1))
				mark_outside_space(grid, &game->map, r, c);
			if (ft_strchr("0NSEW", grid[r][c])
				&& ((r == 0 || r == game->map.rows - 1
					|| c == 0 || c == game->map.cols - 1)
				|| (grid[r - 1][c] == 'X' || grid[r + 1][c] == 'X'
					|| grid[r][c - 1] == 'X' || grid[r][c + 1] == 'X')))
				return (0);
		}
	}
	return (1);
}

static int	check_map2(t_game *game)
{
	char	**grid;

	if (!check_space_flow(game))
		return (0);
	grid = pad_grid(game);
	if (!grid)
		return (0);
	if (!check_map_closure(grid, game))
		return (free_grid(grid, game->map.rows), 0);
	free_grid(grid, game->map.rows);
	return (1);
}

static int	check_map3(t_game *game)
{
	char	**grid;
	int		x;
	int		y;
	int		ok;

	grid = dup_grid(game);
	if (!grid)
		return (0);
	if (!player_position(game, &x, &y))
		return (free_grid(grid, game->map.rows), 0);
	flood_fill(grid, &game->map, x, y);
	ok = check_flood(grid, game->map.rows, game->map.cols);
	free_grid(grid, game->map.rows);
	return (ok);
}

int	validate_map(t_game *game)
{
	if (!check_map1(game))
		return (0);
	if (!check_map2(game))
		return (0);
	if (!check_map3(game))
		return (0);
	return (1);
}
