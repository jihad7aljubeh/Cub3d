/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_map_helpers.c                                :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jehad <jehad@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/22 16:05:43 by aabusnin          #+#    #+#             */
/*   Updated: 2026/05/13 03:02:00 by jehad            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

int	is_empty(char *s)
{
	int	i;

	i = 0;
	while (s[i] == ' ' || s[i] == '\t')
		i++;
	return (s[i] == '\0');
}

int	has_cub_extension(char *filename)
{
	int		len;
	char	*base;

	if (!filename)
		return (0);
	len = ft_strlen(filename);
	if (len <= 4)
		return (0);
	if (ft_strcmp(filename + len - 4, ".cub") != 0)
		return (0);
	base = ft_strrchr(filename, '/');
	if (!base)
		base = filename;
	else
		base++;
	if (base[0] == '.' || base[0] == '\0')
		return (0);
	return (1);
}

int	is_identifier_line(char *s)
{
	if (!ft_strncmp(s, "NO ", 3))
		return (1);
	if (!ft_strncmp(s, "SO ", 3))
		return (1);
	if (!ft_strncmp(s, "WE ", 3))
		return (1);
	if (!ft_strncmp(s, "EA ", 3))
		return (1);
	if (!ft_strncmp(s, "F ", 2))
		return (1);
	if (!ft_strncmp(s, "C ", 2))
		return (1);
	return (0);
}

int	is_map_line(char *s)
{
	int	i;

	i = 0;
	while (s[i] == ' ')
		i++;
	return (ft_strchr("10NSEW", s[i]) != NULL);
}

void	set_player_dir(t_game *g, char c)
{
	set_player_dir_vector(g, c);
	set_player_plane(g, c);
}
