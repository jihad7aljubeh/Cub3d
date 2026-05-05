/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   movement.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jehad <jehad@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 16:07:44 by aabusnin          #+#    #+#             */
/*   Updated: 2026/05/05 09:07:12 by jehad            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/cub3d.h"

void	move_forward_back(t_game *g, double direction)
{
	double	new_x;
	double	new_y;

	new_x = g->player.x + g->player.dir_x * MOVE_SPEED * direction;
	new_y = g->player.y + g->player.dir_y * MOVE_SPEED * direction;
	if (g->map.grid[(int)g->player.y][(int)new_x] != '1')
		g->player.x = new_x;
	if (g->map.grid[(int)new_y][(int)g->player.x] != '1')
		g->player.y = new_y;
}

void	move_left_right(t_game *g, double direction)
{
	double	new_x;
	double	new_y;

	new_x = g->player.x + g->player.plane_x * MOVE_SPEED * direction;
	new_y = g->player.y + g->player.plane_y * MOVE_SPEED * direction;
	if (g->map.grid[(int)g->player.y][(int)new_x] != '1')
		g->player.x = new_x;
	if (g->map.grid[(int)new_y][(int)g->player.x] != '1')
		g->player.y = new_y;
}

void	rotate_player(t_game *g, double rot_dir)
{
	double	old_dir_x;
	double	old_plane_x;
	double	rot;

	rot = ROT_SPEED * rot_dir;
	old_dir_x = g->player.dir_x;
	g->player.dir_x = g->player.dir_x * cos(rot) - g->player.dir_y * sin(rot);
	g->player.dir_y = old_dir_x * sin(rot) + g->player.dir_y * cos(rot);
	old_plane_x = g->player.plane_x;
	g->player.plane_x = g->player.plane_x * cos(rot) - g->player.plane_y
		* sin(rot);
	g->player.plane_y = old_plane_x * sin(rot) + g->player.plane_y * cos(rot);
}

void	update_movement(t_game *g)
{
	if (g->keys.w)
		move_forward_back(g, 1.0);
	if (g->keys.s)
		move_forward_back(g, -1.0);
	if (g->keys.a)
		move_left_right(g, -1.0);
	if (g->keys.d)
		move_left_right(g, 1.0);
	if (g->keys.left)
		rotate_player(g, -1.0);
	if (g->keys.right)
		rotate_player(g, 1.0);
}
