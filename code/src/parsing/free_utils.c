/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   free_utils.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jalju-be <jalju-be@student.42amman.com>    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/05/13 20:23:16 by jalju-be          #+#    #+#             */
/*   Updated: 2026/05/13 20:25:06 by jalju-be         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

int	free_split_retunn(char **arr)
{
	free_split(arr);
	return (-1);
}

int	increaser(int *count)
{
	(*count)++;
	return (1);
}

int	close_free_map(t_game *g, int fd, int flag)
{
	close(fd);
	if (flag == 1)
		free_grid(g->map.grid, g->map.rows);
	return (0);
}

int	free_fire(char *line)
{
	free(line);
	return (0);
}

int	free_helper(t_game *game, char **grid)
{
	free_grid(grid, game->map.rows);
	return (0);
}
