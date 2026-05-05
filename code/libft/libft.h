/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   libft.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aabusnin <aabusnin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/07 12:04:17 by aabusnin          #+#    #+#             */
/*   Updated: 2026/02/07 20:28:44 by aabusnin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef LIBFT_H
# define LIBFT_H
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <unistd.h>

/*
** t_op - Cost structure for move calculations
** Each field represents the count of that specific operation needed
*/
typedef struct s_op
{
	int	total;
	int	ra;
	int	rra;
	int	rb;
	int	rrb;
	int	rr;
	int	rrr;
	int	sa;
	int	sb;
	int	ss;
}		t_op;

/*
** t_node - Node structure for push_swap stacks
** 
** ADDED: pos and target_pos fields for position tracking
** - data: the actual integer value
** - index: sorted rank (0 = smallest, 1 = second smallest, etc.)
** - pos: current position in stack (0 = top, 1 = second, etc.)
** - target_pos: where this node should be pushed in target stack
** - cost: operation costs for moving this node
** - next: pointer to next node in stack
*/
typedef struct s_node
{
	int				data;
	int				index;
	int				pos;
	int				target_pos;
	t_op			cost;
	struct s_node	*next;
}					t_node;

int					ft_atoi(const char *str);
void				ft_bzero(void *b, size_t len);
void				*ft_calloc(size_t number, size_t size);

int					ft_isalnum(int c);
int					ft_isascii(int c);
int					ft_isdigit(int c);
int					ft_isprint(int c);
int					ft_isalpha(int c);
int					ft_tolower(int c);
int					ft_toupper(int c);
char				*ft_itoa(int n);

int					ft_memcmp(const void *s1, const void *s2, size_t n);
void				*ft_memchr(const void *s, int c, size_t n);
void				*ft_memcpy(void *dest, const void *src, size_t n);
void				*ft_memmove(void *dest, const void *src, size_t n);
void				*ft_memset(void *s, int c, size_t n);
void				ft_putchar_fd(char c, int fd);
void				ft_putendl_fd(char *s, int fd);
void				ft_putnbr_fd(int n, int fd);
void				ft_putstr_fd(char *s, int fd);
char				**ft_split(char const *s, char c);

char				*ft_strjoin(char const *s1, char const *s2);
size_t				ft_strlcat(char *dst, const char *src, size_t size);
size_t				ft_strlcpy(char *dst, const char *src, size_t len);
char				*ft_strdup(const char *s1);
char				*ft_strchr(const char *str, int c);
char				*ft_strrchr(const char *s, int c);
size_t				ft_strlen(const char *s);
int					ft_strncmp(const char *s1, const char *s2, size_t n);
int					ft_strcmp(const char *s1, const char *s2);
char				*ft_strnstr(const char *str, const char *to_find,
						size_t len);
char				*ft_strtrim(char const *s1, char const *set);
char				*ft_substr(char const *s, unsigned int start, size_t len);
void				ft_striteri(char *s, void (*f)(unsigned int, char *));
char				*ft_strmapi(char const *s, char (*f)(unsigned int, char));

t_node				*ft_lstnew(int data);
void				ft_lstadd_front(t_node **lst, t_node *new);
int					ft_lstsize(t_node *lst);
t_node				*ft_lstlast(t_node *lst);
void				ft_lstadd_back(t_node **lst, t_node *new);
void				ft_lstdelone(t_node *lst, void (*del)(void *));
void				ft_lstclear(t_node **lst, void (*del)(void *));
void				ft_lstiter(t_node *lst, void (*f)(void *));

/*       get next line      */
# ifndef BUFFER_SIZE
#  define BUFFER_SIZE 42
# endif

typedef struct s_fd_list
{
	int					fd;
	char				*stash;
	struct s_fd_list	*next;
}	t_fd_list;

char				*get_next_line(int fd);

#endif