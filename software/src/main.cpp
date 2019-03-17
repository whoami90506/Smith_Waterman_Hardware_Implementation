#include<iostream>
#include<fstream>
#include<vector>
#include<algorithm>
using namespace std;

short alpha, beta;
short tabal[4][4];
bool firstRead = true;
vector<short> seqA, seqB;

bool readfile(ifstream& ifs){
    if(firstRead){
        firstRead = false;

        for(int i = 0; i < 4; ++i){
            for (int j = 0; j < 4; ++j)ifs >> tabal[i][j];
        }
    }

    ifs >> alpha;
    if(ifs.eof())return false;
    if(alpha == -1)return false;

    ifs >> beta;

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


int calculate(){
    int result = 0;
    int **V = new int*[seqA.size()];
    int **E = new int*[seqA.size()];
    int **F = new int*[seqA.size()];
    for(unsigned i = 0; i < seqA.size(); ++i){
        V[i] = new int[seqB.size()];
        E[i] = new int[seqB.size()];
        F[i] = new int[seqB.size()];
    }

    for(unsigned i = 0; i < seqA.size(); ++i){
        for(unsigned j = 0; j < seqB.size(); ++j){
            E[i][j] = j ? max(V[i][j-1] - alpha, E[i][j-1] - beta) : 0;
            F[i][j] = i ? max(V[i-1][j] - alpha, F[i-1][j] - beta) : 0;

            V[i][j] = max(E[i][j], F[i][j]);
            int temp = (i > 0 && j > 0) ? max(V[i-1][j-1] + tabal[seqA[i]] [seqB[j]], 0) : tabal[seqA[i]] [seqB[j]] ;
            V[i][j] = max(V[i][j], temp);

            result = max(V[i][j], result);
        }
    }

    for(unsigned i = 0; i < seqA.size(); ++i){
        delete [] V[i];
        delete [] E[i];
        delete [] F[i];
    }
    delete [] V;
    delete [] E;
    delete [] F;
    return result;
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

    //calculate
    vector<int> result;
    while(readfile(ifs))result.push_back(calculate() );
    ifs.close();

    //output
    for(auto &i : result)cout << i << endl;
    if (argc == 3){
        ofstream os(argv[2]);
        for(auto &i : result)os << i << endl;
        os.close();
    }
}