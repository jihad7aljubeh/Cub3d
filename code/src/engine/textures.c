/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   textures.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jehad <jehad@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 16:07:24 by aabusnin          #+#    #+#             */
/*   Updated: 2026/05/13 03:03:16 by jehad            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

int	get_tex_color(t_tex *tex, int x, int y)
{
	char	*dst;

	if (x < 0 || x >= tex->width || y < 0 || y >= tex->height)
		return (0);
	dst = tex->addr + (y * tex->line_len + x * (tex->bpp / 8));
	return (*(unsigned int *)dst);
}

void	load_single_texture(t_game *game, t_tex *tex, char *path)
{
	tex->img = mlx_xpm_file_to_image(game->mlx, path, &tex->width,
			&tex->height);
	if (!tex->img)
		error_exit("Failed to load XPM texture. Check file path.");
	tex->addr = mlx_get_data_addr(tex->img, &tex->bpp, &tex->line_len,
			&tex->endian);
	if (!tex->addr)
		error_exit("Failed to get texture data address.");
}

void	load_textures(t_game *game)
{
	load_single_texture(game, &game->tex.north, game->no_path);
	load_single_texture(game, &game->tex.south, game->so_path);
	load_single_texture(game, &game->tex.east, game->ea_path);
	load_single_texture(game, &game->tex.west, game->we_path);
}

void	mock_load_textures(t_game *game)
{
	load_single_texture(game, &game->tex.north, "textures/north.xpm");
	load_single_texture(game, &game->tex.south, "textures/south.xpm");
	load_single_texture(game, &game->tex.east, "textures/east.xpm");
	load_single_texture(game, &game->tex.west, "textures/west.xpm");
}
