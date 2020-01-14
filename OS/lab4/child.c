#include <Windows.h>
#include <stdio.h>



int main(){

    const unsigned char* fName = "mapFile";
    HANDLE mapFile;
    mapFile = OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, fName);
    if(mapFile == NULL){
         printf("Cannot OpenFileMapping %ld\n", GetLastError());
    }

    unsigned char *buff = (unsigned char*)MapViewOfFile(mapFile, FILE_MAP_ALL_ACCESS, 0, 0, 4);
    if (buff == NULL){
        printf("Cannot MapViewOfFile %ld\n", GetLastError());
        CloseHandle(mapFile);
        return 1;
    }

    HANDLE mutex;
    mutex = OpenMutex(MUTEX_ALL_ACCESS, FALSE, "myMutex");


    while(1){
        unsigned char *bytes;
        int res;
        int num1, num2;
        unsigned char symbol;

        WaitForSingleObject(mutex, INFINITE);
        num1 = *((int*)buff);
        ReleaseMutex(mutex);

        WaitForSingleObject(mutex, INFINITE);
        num2 = *((int*)buff);
        ReleaseMutex(mutex);

        WaitForSingleObject(mutex, INFINITE);
        symbol = *buff;

         if(symbol == '*'){
             res = num1 * num2;
         }
         else if(symbol == '/'){
             if(num2*num1 == 0){
                 res = 0;
             }
             else {
                 res = num1 / num2;
             }
         }
         bytes = (unsigned char*)(&res);
         for(int i = 0; i < 4; i++){
            *(buff+i) = *(bytes+i);
         }
         ReleaseMutex(mutex);
    }

return 0;
}
