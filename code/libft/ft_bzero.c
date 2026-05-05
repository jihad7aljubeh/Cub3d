/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_bzero.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/05 16:21:51 by aabusnin          #+#    #+#             */
/*   Updated: 2025/08/11 13:30:30 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

void	ft_bzero(void *b, size_t len)
{
	unsigned char	*p;
	size_t			i;

	p = (unsigned char *)b;
	i = 0;
	while (i < len)
	{
		p[i] = 0;
		i++;
	}
}
//int	main(void)
//{
//	char	str[];

//	str[] = "Hello, world!";
//	ft_bzero(str + 3, 4);
//	for (int i = 0; i < sizeof(str) - 1; i++)
//		putchar(str[i] ? str[i] : '\0'); // Print '.' for nulls
//	putchar('\n');
//	return (0);
//}
