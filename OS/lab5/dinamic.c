
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>

struct Node
{
    unsigned long long value;
    struct Node *next;
};

typedef void(__stdcall *F_ADD)(struct Node **,unsigned long long);
typedef int (__stdcall *F_SEARCH)(struct Node** , unsigned long long );
typedef int (__stdcall * F_DELETE)(struct Node** , unsigned long long );
typedef void (__stdcall * F_PRINT)(struct Node** );

int main(){

    HMODULE lib =  LoadLibrary(TEXT("list.dll"));
    if (lib == NULL)
    {
        printf("Load error : %d\n", GetLastError());
        return 0;
    }

    F_ADD addFun;
    F_SEARCH searchFun;
    F_DELETE deleteFun;
    F_PRINT printFun;


    addFun = (F_ADD)GetProcAddress(lib, TEXT("Add"));
    searchFun = (F_SEARCH)GetProcAddress(lib, TEXT("Search"));
    deleteFun = (F_DELETE)GetProcAddress(lib, TEXT("DeleteEl"));
    printFun = (F_PRINT)GetProcAddress(lib, TEXT("Print"));


    if( addFun == NULL || searchFun == NULL || deleteFun == NULL || printFun == NULL){
        printf("Error: Cannot find function %d\n", GetLastError());
    }

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
            addFun(&head, md5sum);
            break;
        case 2:
            printf("Enter md5sum to delete: ");
            scanf("%llx", &md5sum);
            if (deleteFun(&head, md5sum))
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
            if (searchFun(&head, md5sum))
            {
                printf("In list\n");
            }
            else
            {
                printf("Not in list\n");
            }
            break;
        case 4:
            printFun(&head);
            break;
        case 5:
            return 1;
        default:
            printf("No such command\n");
            break;
        }
        printf("1-add 2-delete 3-find 4-print 5-exit\n");

    }

    FreeLibrary(lib);
    return 0;
}


