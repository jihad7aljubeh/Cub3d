/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_strtrim.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/09 18:50:49 by aabusnin          #+#    #+#             */
/*   Updated: 2025/08/11 14:15:23 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

char	*ft_strtrim(char const *s1, char const *set)
{
	size_t	i;
	size_t	j;
	char	*s3;

	if (!s1 || !set)
		return (NULL);
	i = 0;
	j = ft_strlen(s1);
	while (s1[i] && ft_strchr(set, s1[i]))
		i++;
	if (i == j)
		return (ft_strdup(""));
	j--;
	while (j > i && ft_strchr(set, s1[j]))
		j--;
	s3 = malloc(j - i + 2);
	if (!s3)
		return (NULL);
	ft_strlcpy(s3, &s1[i], j - i + 2);
	return (s3);
}
//int	main(void)
//{
//	char	s1[];
//	char	set[];

//	s1[] = "abcbbayhamccaabac";
//	set[] = "abc";
//	printf("%s\n", ft_strtrim(s1, set));
//	return (0);
//}
