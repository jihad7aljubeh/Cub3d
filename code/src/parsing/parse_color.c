/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_color.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jalju-be <jalju-be@student.42amman.com>    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/26 18:17:52 by aabusnin          #+#    #+#             */
/*   Updated: 2026/05/13 20:27:56 by jalju-be         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/cub3d.h"

void	free_split(char **arr)
{
	int	i;

	i = 0;
	if (!arr)
		return ;
	while (arr[i])
		free(arr[i++]);
	free(arr);
}

static int	is_valid_number(char *str)
{
	int	start;
	int	end;

	start = 0;
	while (str[start] == ' ' || str[start] == '\t')
		start++;
	end = ft_strlen(str) - 1;
	while (end >= start && (str[end] == ' ' || str[end] == '\t'))
		end--;
	if (end < start)
		return (0);
	if (str[start] == '-' || str[start] == '+')
		start++;
	if (start > end || !ft_isdigit(str[start]))
		return (0);
	while (start <= end)
	{
		if (!ft_isdigit(str[start]))
			return (0);
		start++;
	}
	return (1);
}

static int	is_valid_color_syntax(char *line)
{
	int	comma_count;
	int	i;
	int	last_non_space;

	comma_count = 0;
	i = 0;
	last_non_space = -1;
	while (line[i])
	{
		if (line[i] == ',')
		{
			comma_count++;
			if (last_non_space == -1)
				return (0);
			last_non_space = -1;
			if (line[i + 1] == ',' || line[i + 1] == '\0')
				return (0);
		}
		else if (line[i] != ' ' && line[i] != '\t')
			last_non_space = i;
		i++;
	}
	if (comma_count != 2)
		return (0);
	return (last_non_space != -1);
}

static int	parse_rgb(char **rgb, int *r, int *g, int *b)
{
	if (!is_valid_number(rgb[0]) || !is_valid_number(rgb[1])
		|| !is_valid_number(rgb[2]))
		return (0);
	*r = ft_atoi(rgb[0]);
	*g = ft_atoi(rgb[1]);
	*b = ft_atoi(rgb[2]);
	if (*r < 0 || *r > 255 || *g < 0 || *g > 255 || *b < 0 || *b > 255)
		return (0);
	return (1);
}

int	parse_color(char *line)
{
	char	**rgb;
	int		r;
	int		g;
	int		b;
	int		len;

	while (*line == ' ' || *line == '\t')
		line++;
	len = ft_strlen(line);
	if (len > 0 && line[len - 1] == '\n')
		line[len - 1] = '\0';
	if (!is_valid_color_syntax(line))
		return (-1);
	rgb = ft_split(line, ',');
	if (!rgb || !rgb[0] || !rgb[1] || !rgb[2] || rgb[3])
		return (free_split_return(rgb));
	if (!parse_rgb(rgb, &r, &g, &b))
		return (free_split_return(rgb));
	free_split(rgb);
	return ((r << 16) | (g << 8) | b);
}
