#include <Windows.h>
#include <stdio.h>


int main(){
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(STARTUPINFO));

    HANDLE mutex;
    mutex = CreateMutex(NULL, TRUE, "myMutex");
    if(mutex == NULL){
        printf("Cannot CreateMutex %ld\n", GetLastError());
        return 1;
    }

    HANDLE mapFile;
    const unsigned char* fName = "mapFile";
    mapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, 4, fName);
    if(mapFile == NULL){
        printf("Cannot CreateFileMapping %ld\n", GetLastError());
        return 1;
    }

    unsigned char *buff = (unsigned char*)MapViewOfFile(mapFile, FILE_MAP_ALL_ACCESS, 0, 0, 4);
    if (buff == NULL){
        printf("Cannot MapViewOfFile %ld\n", GetLastError());
        CloseHandle(mapFile);
        return 1;
    }

    if(!(CreateProcess("child.exe", NULL, NULL, NULL, FALSE, NORMAL_PRIORITY_CLASS, NULL, NULL, &si, &pi))){
        fprintf(stdout,"Cannot CreateProcess: Error %ld\n", GetLastError());
        return 1;
    }

    while(1){
        unsigned char *bytes;
        int num1, num2;
        char symbol;
        printf("Enter expression : ");
        if(scanf("%d", &num1) == EOF) break;
        scanf(" %c", &symbol);
        scanf("%d", &num2);

        bytes = (unsigned char*)(&num1);
        for(int i = 0; i < 4; i++){
            *(buff+i) = *(bytes+i);
        }
        ReleaseMutex(mutex);

        WaitForSingleObject(mutex, INFINITE);
        bytes = (unsigned char*)(&num2);
        for(int i = 0; i < 4; i++){
            *(buff+i) = *(bytes+i);
        }
        ReleaseMutex(mutex);

        WaitForSingleObject(mutex, INFINITE);
        *(buff) = symbol;
        ReleaseMutex(mutex);

        WaitForSingleObject(mutex, INFINITE);
        int res;
        res = *((int*)buff);
        printf("Result = %d\n",res);
      }

    CloseHandle(mutex);
    CloseHandle(mapFile);
    TerminateProcess(pi.hProcess, NO_ERROR);

return 0;
}
