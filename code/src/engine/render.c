/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   render.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 16:07:15 by aabusnin          #+#    #+#             */
/*   Updated: 2026/04/26 16:16:47 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

void	ft_pixel_put(t_game *game, int x, int y, int color)
{
	char	*dst;
	int		offset;

	if (x < 0 || x >= WIN_WIDTH || y < 0 || y >= WIN_HEIGHT)
		return ;
	offset = (y * game->line_len) + (x * (game->bpp / 8));
	dst = game->img_addr + offset;
	*(unsigned int *)dst = color;
}

static void	render_background(t_game *game)
{
	int	x;
	int	y;

	y = 0;
	while (y < WIN_HEIGHT)
	{
		x = 0;
		while (x < WIN_WIDTH)
		{
			if (y < WIN_HEIGHT / 2)
				ft_pixel_put(game, x, y, game->ceil_color);
			else
				ft_pixel_put(game, x, y, game->floor_color);
			x++;
		}
		y++;
	}
}

int	ensure_capacity(t_game *g, int *capacity, int i)
{
	char	**tmp;

	if (i < *capacity - 1)
		return (1);
	*capacity *= 2;
	tmp = realloc(g->map.grid, sizeof(char *) * *capacity);
	if (!tmp)
		return (0);
	g->map.grid = tmp;
	return (1);
}

int	render_frame(t_game *game)
{
	update_movement(game);
	render_background(game);
	raycaster(game);
	mlx_put_image_to_window(game->mlx, game->win, game->img, 0, 0);
	return (0);
}
