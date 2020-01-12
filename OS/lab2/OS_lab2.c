#include <Windows.h>
#include <stdio.h>


int main() {
    DWORD nbReaded;
    DWORD nbWrited;
    DWORD nbAvail;
    STARTUPINFO si;
    SECURITY_ATTRIBUTES sa;
    PROCESS_INFORMATION pi;
    HANDLE ChildStd_IN_Rd, ChildStd_OUT_Wr, ChildStd_OUT_Rd, ChildStd_IN_Wr;


    sa.nLength = sizeof(SECURITY_ATTRIBUTES);
    sa.bInheritHandle = TRUE;
    sa.lpSecurityDescriptor = NULL;

    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);

    if (CreatePipe(&ChildStd_IN_Rd, &ChildStd_IN_Wr, &sa, 0))
    {
        if (CreatePipe(&ChildStd_OUT_Rd, &ChildStd_OUT_Wr, &sa, 0))
        {
            GetStartupInfo(&si);

            si.dwFlags = STARTF_USESTDHANDLES;

            si.hStdOutput = ChildStd_OUT_Wr;
            si.hStdError = ChildStd_OUT_Wr;
            si.hStdInput = ChildStd_IN_Rd;

            if (CreateProcess("C:\\Windows\\System32\\cmd.exe", NULL, NULL, NULL, TRUE, NORMAL_PRIORITY_CLASS, NULL, "D:\\", &si, &pi)) {

                CloseHandle(ChildStd_IN_Rd);
                CloseHandle(ChildStd_OUT_Wr);

                nbAvail = 1;

                char buf1[2];
                while (nbAvail) {
                    if (!(ReadFile(ChildStd_OUT_Rd, buf1, 1, &nbReaded, NULL))) {
                        printf("ReadFile: Error %ld\n", GetLastError());
                    }
                    if(!(PeekNamedPipe(ChildStd_OUT_Rd, NULL, 0, NULL, &nbAvail, NULL))) {
                        printf("PeekNamedPipe: Error %ld\n", GetLastError());
                    };
                }
                printf("D:\\>");

                while (1) {
                    char buff[256];
                    unsigned char buf[2];
                    gets(buff);
                    if (!strcmp(buff, "exit")) {
                        break;
                    }
                    char siz[2];
                    char *s = strcat(buff, "\n");
                    siz[0] = strlen(buff);
                    if (!(WriteFile(ChildStd_IN_Wr, buff, strlen(buff), & nbWrited, NULL))) {
                        printf("WriteFile: Error %ld\n", GetLastError());
                    }

                    nbAvail = 1;
                    while(nbAvail){
                        ReadFile(ChildStd_OUT_Rd, buf, 1, &nbReaded, NULL);
                        PeekNamedPipe(ChildStd_OUT_Rd, NULL, 0, NULL, &nbAvail, NULL);
                    }
                    nbAvail = 1;
                    while (nbAvail) {
                        if (ReadFile(ChildStd_OUT_Rd, buf, 2, &nbReaded, NULL)) {
                            for(int i=0; i<nbReaded;i++){
                            int code = (int) buf[i];
                            if ( (code >= 97 && code <= 122) || (code >= 224 && code <= 255) ) {
                                buf[i] = (unsigned char)(code - 32);
                            }
                            printf("%c", buf[i]);
                            }
                        } else {
                            if(GetLastError() == 109) break;
                            printf("ReadFile: Error %ld\n", GetLastError());
                        }
                        if(!(PeekNamedPipe(ChildStd_OUT_Rd, NULL, 0, NULL, &nbAvail, NULL))){
                            printf("PeekNamedPipe: Error %ld\n", GetLastError());
                            break;
                        }
                        if(buf[nbReaded-1]=='\n') nbAvail = 1;
                    }
                }
                CloseHandle(pi.hThread);
                CloseHandle(pi.hProcess);
                CloseHandle(ChildStd_OUT_Rd);
                CloseHandle(ChildStd_IN_Wr);
            } else {
                printf("CreateProcess: Error %ld\n", GetLastError());
            }
        } else {
            printf("CreatePipe_OUT: Error %ld\n", GetLastError());
        }
    } else {
        printf("CreatePipe_IN: Error %ld\n", GetLastError());
    }
    return 0;
}

