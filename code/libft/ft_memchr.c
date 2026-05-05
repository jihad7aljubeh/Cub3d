/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_memchr.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/07 15:33:06 by aabusnin          #+#    #+#             */
/*   Updated: 2025/08/11 14:24:46 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

void	*ft_memchr(const void *s, int c, size_t n)
{
	unsigned char	*p;
	unsigned char	ch;
	unsigned int	i;

	i = 0;
	p = (unsigned char *)s;
	ch = (unsigned char)c;
	while (i < n)
	{
		if (p[i] == ch)
			return (p + i);
		i++;
	}
	return (NULL);
}
//int	main(void)
//{
//	char c[] = "ayaaham";
//	char s = 'h';
//	printf("%s", ft_strchr(c, s, 3));
//}