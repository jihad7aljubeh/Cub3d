/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_lstnew_bonus.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/12 19:48:17 by aabusnin          #+#    #+#             */
/*   Updated: 2025/10/08 16:02:53 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

t_node	*ft_lstnew(int data)
{
	t_node	*t;

	t = malloc(sizeof(t_node));
	if (!t)
		return (NULL);
	t->data = data;
	t->next = NULL;
	return (t);
}
