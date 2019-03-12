#include<iostream>
#include<fstream>
#include<vector>
using namespace std;

bool readfile(char* name){
    ifstream ifs(name);
    if(!ifs.is_open()){
        cout << "Error: file \"" << name << "\" doesn't exist!\n";
        return false;
    }

    string temp;
    while(getline(ifs, temp))cout << temp << endl;
    return true;
}


int main(int argc, char** argv){
    if(argc < 2 || argc > 3){
        cout << "Usage: exec [input_file_name] <output_file_name>\n";
        return 1;
    }

    vector<int> alpha, beta;
    vector<vector<short>> seqA, seqB;
    if(!readfile(argv[1] ) )return 1;

}
