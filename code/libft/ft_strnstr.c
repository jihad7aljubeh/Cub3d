/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_strnstr.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/11 12:59:10 by aabusnin          #+#    #+#             */
/*   Updated: 2025/08/11 20:25:29 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

char	*ft_strnstr(const char *str, const char *to_find, size_t len)
{
	size_t	s;
	size_t	i;

	if (!*to_find)
		return ((char *)str);
	s = 0;
	while (str[s] && s < len)
	{
		if (str[s] == to_find[0])
		{
			i = 1;
			while (to_find[i] && str[s + i] == to_find[i] && (s + i) < len)
				i++;
			if (to_find[i] == '\0')
				return ((char *)&str[s]);
		}
		s++;
	}
	return (0);
}

//int main ()
//{
//    char s[] = "ayham abusnineh";
//    char t[] = "m ab";
//    char *f = ft_strnstr(s, t, 8);
//    printf("%s", f);
//}
