#include<iostream>
#include<fstream>
#include<vector>
using namespace std;

short alpha, beta;
short tabal[4][4];
vector<short> seqA, seqB;

bool readfile(ifstream& ifs){
    ifs >> alpha;
    
    if(ifs.eof())return false;
    if(alpha == -1)return false;

    ifs >> beta;
    for(int i = 0; i < 4; ++i){
        for (int j = 0; j < 4; ++j)ifs >> tabal[i][j];
    }

    seqA.clear();
    seqB.clear();
    bool first = true;
    short temp;

    while(true){
        ifs >> temp;
        if (temp == 5){
            if(first){
                first = false;
                continue;
            }
            else break;
        }

        if(first)seqA.push_back(temp);
        else seqB.push_back(temp);
    }

    return true;
}




int main(int argc, char** argv){
    if(argc < 2 || argc > 3){
        cout << "Usage: exec [input_file_name] <output_file_name>\n";
        return 1;
    }

    ifstream ifs(argv[1]);
    if(!ifs.is_open()){
        cout << "Error: file \"" << argv[1] << "\" doesn't exist!\n";
        return 1;
    }

    while(readfile(ifs)){
        for(auto& i:seqA)cout << i << ' ';
        cout << endl;
        for(auto& i:seqB)cout << i << ' ';
        cout << endl;

    }

    ifs.close();

}
