#include <stdlib.h>
#include <stdio.h>
#include "list.h"
/*
 gcc -c -DBUILDING_EXAMPLE_DLL list.c
 gcc -shared -o list.dll list.o -Wl,--out-implib,list.a
 gcc -c static.c
 gcc -o static.exe static.o list.dll
*/
int main()
{
    struct Node *head = NULL;
    int command = -1;
    unsigned long long  md5sum ;

    printf("1-add 2-delete 3-find 4-print 5-exit\n");

    while (1)
    {
        scanf("%d", &command);
        switch (command)
        {
        case 1:
            printf("Enter md5sum to add: ");
            scanf("%llx", &md5sum);
            Add(&head, md5sum);
            break;
        case 2:
            printf("Enter md5sum to delete: ");
            scanf("%llx", &md5sum);
            if (DeleteEl(&head, md5sum))
            {
                printf("Deleted\n");
            }
            else
            {
                printf("Not in list\n");
            }
            break;
        case 3:
            printf("Enter md5sum to find: ");
            scanf("%llx", &md5sum);
            if (Search(&head, md5sum))
            {
                printf("In list\n");
            }
            else
            {
                printf("Not in list\n");
            }
            break;
        case 4:
            Print(&head);
            break;
        case 5:
            return 1;
        default:
            printf("No such command\n");
            break;
        }
        printf("1-add 2-delete 3-find 4-print 5-exit\n");

    }
    return 0;
}
