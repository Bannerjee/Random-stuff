#pragma GCC diagnostic ignored "-Wwrite-strings"

#include <windows.h>
#include <psapi.h>
#include <iostream>
#include <conio.h>

using namespace std;

int GetProcessModules(DWORD proc_id,LPTSTR pName)
{
    HMODULE modules[1024];
    HANDLE  proc;
    DWORD   cbNeeded;
    HWND    hwnd;
    unsigned int i;
    char pClass[100];


    if (proc_id == 0 && pName == NULL)
    {
        cout << "Input at least one value!(pid,P_NAME)" << endl;
        return 0;
    }

    
    //get handle,id and class
 
    hwnd = FindWindowA(NULL,pName);
    GetWindowThreadProcessId(hwnd,&proc_id);
    GetClassName(hwnd,pClass,MAX_PATH);


    // Get a handle to the process.

    proc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,FALSE,proc_id);

    if (proc==NULL)
    {
        return 1;
    }

    cout << "PROCESS NAME:  \t"  << pName   << "\n\n";

    cout << "PROCESS ID:    \t"  << proc_id << endl;
    cout << "PROCESS HWND:  \t"  << hwnd    << endl;
    cout << "PROCESS CLASS: \t"  << pClass  << endl;
 
    cout << "PROCESS HANDLE:\t"  << proc    << "\n\n";


   //list of process modules

    if( EnumProcessModules(proc, modules, sizeof(modules), &cbNeeded))
    {
        for ( i = 0; i < (cbNeeded / sizeof(HMODULE)); i++ )
        {
            TCHAR module_name[MAX_PATH];

            // Get the full path to the module's file.

            if ( GetModuleFileNameEx( proc, modules[i], module_name,sizeof(module_name) / sizeof(TCHAR)))
            {
                // Print the module name and handle value.

                cout <<module_name << "(" << modules[i] << ")\n" << endl;
            }
        }
    }
    
    //Release process handle.

    CloseHandle(proc);

    return 0;
}

int main()
{
	//input at least one value here

	DWORD  pid 	  = 0;
	LPTSTR P_NAME = NULL;

    GetProcessModules(pid,P_NAME);

    getch();
    return 0;
}