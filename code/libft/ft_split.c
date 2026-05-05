/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_split.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/10 15:23:49 by aabusnin          #+#    #+#             */
/*   Updated: 2025/08/14 22:14:34 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

static size_t	count_words(const char *s, char c)
{
	int	count;
	int	in_word;

	count = 0;
	in_word = 0;
	while (*s)
	{
		if (*s != c && in_word == 0)
		{
			in_word = 1;
			count++;
		}
		else if (*s == c)
			in_word = 0;
		s++;
	}
	return (count);
}

static char	*word_dup(const char *s, int start, int end)
{
	char	*word;
	int		i;

	word = malloc(end - start + 1);
	if (!word)
		return (NULL);
	i = 0;
	while (start < end)
		word[i++] = s[start++];
	word[i] = '\0';
	return (word);
}

static char	**free_all(char **ss, size_t j)
{
	while (j > 0)
		free(ss[--j]);
	free(ss);
	return (NULL);
}

static char	**fill_word(char **ss, char const *s, char c)
{
	size_t	i;
	size_t	j;
	size_t	start;

	i = 0;
	j = 0;
	while (s[i])
	{
		while (s[i] == c)
			i++;
		if (!s[i])
			break ;
		start = i;
		while (s[i] && s[i] != c)
			i++;
		ss[j] = word_dup(s, start, i);
		if (!ss[j++])
			return (free_all(ss, j));
	}
	ss[j] = NULL;
	return (ss);
}

char	**ft_split(char const *s, char c)
{
	int		words;
	char	**sp;

	if (!s)
		return (NULL);
	words = count_words(s, c);
	sp = malloc((words + 1) * sizeof(char *));
	if (!sp)
		return (NULL);
	return (fill_word(sp, s, c));
}

//int	main(void)
//{
//	char	s[] = "ccc ayhamcmohccmalekcckhaled";
//	char	**d;
//	int		i;

//	d = ft_split(s, 'c');
//	if (!d)
//	{
//		fprintf(stderr, "Split failed\n");
//		return (1);
//	}
//	i = 0;
//	while (d[i])
//	{
//		printf("%s\n", d[i]);
//		free(d[i]);
//		i++;
//	}
//	free(d);
//	return (0);
//}
