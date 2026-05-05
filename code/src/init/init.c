/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 16:04:38 by aabusnin          #+#    #+#             */
/*   Updated: 2026/04/25 21:18:19 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

void	init_game(t_game *game)
{
	game->mlx = mlx_init();
	if (!game->mlx)
		error_exit("Failed to initialize MLX");
	game->win = mlx_new_window(game->mlx, WIN_WIDTH, WIN_HEIGHT, "Cub3D");
	if (!game->win)
		error_exit("Failed to create window");
	game->img = mlx_new_image(game->mlx, WIN_WIDTH, WIN_HEIGHT);
	if (!game->img)
		error_exit("Failed to create image");
	game->img_addr = mlx_get_data_addr(game->img, &game->bpp, &game->line_len,
			&game->endian);
	if (!game->img_addr)
		error_exit("Failed to get image data address");
	game->floor_color = -1;
	game->ceil_color = -1;
	game->no_path = NULL;
	game->so_path = NULL;
	game->ea_path = NULL;
	game->we_path = NULL;
}
