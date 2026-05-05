/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_calloc.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/09 11:54:45 by aabusnin          #+#    #+#             */
/*   Updated: 2025/08/15 19:27:16 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

void	*ft_calloc(size_t number, size_t size)
{
	void	*new;

	if (number == 0 || size == 0)
	{
		new = (char *)malloc(1);
		if (!new)
			return (NULL);
		return (new);
	}
	new = (void *)malloc(number * size);
	if (!new)
		return (NULL);
	ft_bzero(new, size * number);
	return ((void *)new);
}
