#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <math.h>


HANDLE *thread;
DWORD threadId;

double intervalBetweenPoints;
int nPointsForThread;
int nPoints;
double *fun;
double a;

DWORD WINAPI ThreadFunc( LPVOID arg ){
    int number = (int)arg;
    if ( number > nPoints ) return 0;
    if(number == 0){
        double currentPoint = a;
        fun[0] = sin(currentPoint) + cos(currentPoint);
        currentPoint += intervalBetweenPoints;
        for (int i = 1; i < nPointsForThread; i++){
            fun[i] = ( sin(currentPoint) + cos(currentPoint) ) * fun[i-1];
            currentPoint += intervalBetweenPoints;
        }
    }
    else{
        int nPointsCounted = nPointsForThread * number;
        double currentPoint = a + intervalBetweenPoints * nPointsCounted;
        double mas[nPointsForThread];
        for(int i = 0; i < nPointsForThread; i++){
            mas[i] = sin(currentPoint) + cos(currentPoint);
            currentPoint += intervalBetweenPoints;
        }
        nPointsCounted = nPointsForThread * number;
        WaitForSingleObject(thread[number-1], INFINITE);
        for(int j = 0; j < nPointsForThread; j++ ){
            if(nPointsCounted > nPoints - 1 ) break;
            fun[nPointsCounted] = mas[j] * fun[nPointsCounted - 1];
            nPointsCounted ++;
        }
    }
return 0;
}

int main(int argc, char *argv[]){
    double b;
    printf("Enter number of points: ");
    scanf("%d", &nPoints);
    printf("Enter interval: ");
    scanf("%lf %lf", &a, &b);
    int nThreads = nPoints;
    if( b < a){
        double x = a;
        a = b;
        b = x;
    }
    intervalBetweenPoints = (b - a + 1) / (double)nPoints;
    if (argc >= 2) {
        nThreads = atoi(argv[1]);
    }
    nPointsForThread = max(nPoints / nThreads, 1);
    fun = (double*)malloc(sizeof(double)*nPoints);
    thread = (HANDLE*)malloc(sizeof(HANDLE) * nThreads);
    DWORD *threadId = (DWORD*)malloc(sizeof(DWORD) * nThreads);
    for(int i = 0 ; i < nThreads; i++){
            thread[i] = CreateThread(NULL, 0, &ThreadFunc,(LPVOID)i, 0, &threadId[i]);
    }
    printf("Function points : \n");
    for(int i = 0; i < nThreads; i++){
        WaitForSingleObject(thread[i], INFINITE);
        CloseHandle(thread[i]);
        for(int j = i * nPointsForThread; j < (i + 1) * nPointsForThread && j < nPoints; j++){
            printf("%d) ", j+1);
            printf("%.25lf\n", fun[j]);
        }
    }
return 0;
}

