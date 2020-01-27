#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include "list.h"

void __stdcall Add(struct Node **head, unsigned long long  elem)
{
    if((*head) == NULL)
    {
        (*head) = (struct Node *)malloc(sizeof(struct Node));
        (*head)->next = NULL;
        (*head)->value = elem;
        return;
    }

    struct Node *node = (struct Node *)malloc(sizeof(struct Node));
    struct Node *h = (*head);
    while (h->next != NULL)
    {
        h = h->next;
    }
    h->next = node;
    node->next = NULL;
    node->value = elem;
}

int __stdcall Search(struct Node **head, unsigned long long  elem)
{
    struct Node *h = (*head);
    while (h != NULL)
    {
        if (h->value == elem)
        {
            return 1;
        }
        h = h->next;
    }
    return 0;
}

int __stdcall DeleteEl(struct Node **head, unsigned long long  elem)
{
    struct Node *h = (*head);
    struct Node *pred = h;
    while (h != NULL)
    {
        if (h->value == elem)
        {
            if(h == (*head))
            {
                (*head) = h->next;
            }
            pred->next = h->next;
            free(h);
            return 1;
        }
        pred = h;
        h = h->next;
    }
    return 0;
}

void __stdcall Print(struct Node **head)
{
    struct Node *h = (*head);
    if(h == NULL) printf("List is empty\n");
    while (h != NULL)
    {
        printf("%llx ", h->value);
        h = h->next;
    }
    printf("\n");
}
