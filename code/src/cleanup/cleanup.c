/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   cleanup.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jehad <jehad@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 16:08:24 by aabusnin          #+#    #+#             */
/*   Updated: 2026/05/05 09:06:43 by jehad            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

static void	free_map(t_game *game)
{
	int	i;

	i = 0;
	while (game->map.grid && game->map.grid[i])
	{
		free(game->map.grid[i]);
		i++;
	}
	free(game->map.grid);
	game->map.grid = NULL;
}

static void	destroy_tex(t_game *game, t_tex *tex)
{
	if (tex->img)
		mlx_destroy_image(game->mlx, tex->img);
	tex->img = NULL;
}

void	error_exit(char *msg)
{
	ft_putstr_fd("Error: ", 2);
	ft_putstr_fd(msg, 2);
	ft_putstr_fd("\n", 2);
	exit(1);
}

void	cleanup(t_game *game)
{
	free_map(game);
	destroy_tex(game, &game->tex.north);
	destroy_tex(game, &game->tex.south);
	destroy_tex(game, &game->tex.east);
	destroy_tex(game, &game->tex.west);
	if (game->img)
		mlx_destroy_image(game->mlx, game->img);
	if (game->win)
		mlx_destroy_window(game->mlx, game->win);
	if (game->mlx)
		mlx_destroy_display(game->mlx);
	free(game->mlx);
	free(game->no_path);
	free(game->so_path);
	free(game->ea_path);
	free(game->we_path);
}
