/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/15 10:00:00 by student           #+#    #+#             */
/*   Updated: 2025/10/20 18:31:49 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

/*
** Main implementation of get_next_line with linked list support.
** Manages multiple file descriptors simultaneously using a static list.
** Returns one line per call, including the newline if present.
*/

#include "libft.h"

static t_fd_list	*get_fd_node(t_fd_list **head, int fd)
{
	t_fd_list	*curr;
	t_fd_list	*new;

	curr = *head;
	while (curr)
	{
		if (curr->fd == fd)
			return (curr);
		curr = curr->next;
	}
	new = malloc(sizeof(t_fd_list));
	if (!new)
		return (NULL);
	new->fd = fd;
	new->stash = NULL;
	new->next = *head;
	*head = new;
	return (new);
}

static void	remove_fd_node(t_fd_list **head, int fd)
{
	t_fd_list	*curr;
	t_fd_list	*prev;

	curr = *head;
	prev = NULL;
	while (curr)
	{
		if (curr->fd == fd)
		{
			if (prev)
				prev->next = curr->next;
			else
				*head = curr->next;
			free(curr->stash);
			free(curr);
			return ;
		}
		prev = curr;
		curr = curr->next;
	}
}

static char	*extract_line(t_fd_list *node)
{
	char	*line;
	char	*newline_pos;
	char	*temp;
	size_t	len;

	if (!node->stash || !*node->stash)
		return (NULL);
	newline_pos = ft_strchr(node->stash, '\n');
	if (newline_pos)
	{
		len = newline_pos - node->stash + 1;
		line = ft_substr(node->stash, 0, len);
		temp = ft_substr(node->stash, len, ft_strlen(node->stash) - len);
		free(node->stash);
		node->stash = temp;
		return (line);
	}
	line = ft_substr(node->stash, 0, ft_strlen(node->stash));
	free(node->stash);
	node->stash = NULL;
	return (line);
}

static int	read_to_stash(int fd, t_fd_list *node)
{
	char	*buffer;
	char	*temp;
	ssize_t	bytes;

	buffer = malloc(BUFFER_SIZE + 1);
	if (!buffer)
		return (-1);
	bytes = read(fd, buffer, BUFFER_SIZE);
	while (bytes > 0)
	{
		buffer[bytes] = '\0';
		temp = ft_strjoin(node->stash, buffer);
		free(node->stash);
		node->stash = temp;
		if (!node->stash || ft_strchr(node->stash, '\n'))
			break ;
		bytes = read(fd, buffer, BUFFER_SIZE);
	}
	free(buffer);
	return (bytes);
}

char	*get_next_line(int fd)
{
	static t_fd_list	*head;
	t_fd_list			*node;
	char				*line;
	int					read_result;

	if (fd < 0 || BUFFER_SIZE <= 0)
		return (NULL);
	node = get_fd_node(&head, fd);
	if (!node)
		return (NULL);
	if (!ft_strchr(node->stash, '\n'))
	{
		read_result = read_to_stash(fd, node);
		if (read_result < 0)
			return (remove_fd_node(&head, fd), NULL);
	}
	line = extract_line(node);
	if (!line)
		remove_fd_node(&head, fd);
	return (line);
}
