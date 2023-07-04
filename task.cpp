#include <stdio.h>
#include <conio.h>
#include <iostream>


using namespace std;

FILE* in;
FILE* out;
char f1[50];
char f2[50];
char stream[1];
string content,result;

int main()
{
    cout << "Input file:";
    cin  >> f1;
    cout << "Output file:";
    cin  >> f2;

    in = fopen(f1,"r");
    if(!in)
    {
        cout << "no input file";
        return 1;
    }

  
    while(!feof(in))
    {
        fread(((void*)&stream),sizeof(stream),1,in);
        if(result.back()!='!' && result.back()!='?' && result.back()!='.' && result.back()!='\n' && !result.empty())
        {
            stream[0] = tolower(stream[0]);

        }
        result+=stream;
        stream[0]=0;
    }

    const char* str = result.c_str();

    out = fopen(f2,"w");
    fprintf(out,"%s\n",str);

    fclose(out);
    fclose(in);
}