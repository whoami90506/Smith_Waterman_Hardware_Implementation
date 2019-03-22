#include<iostream>
#include<fstream>
#include<string>
#include<algorithm>
using namespace std;

float alpha, beta, _match, _mismatch;
bool firstRead = true;
string seqA, seqB;

bool readfile(ifstream& ifs){

    ifs >> alpha;
    if(ifs.eof())return false;
    if(alpha < 0)return false;
    ifs >> beta >> _match >> _mismatch >> seqA >> seqB;

    return true;
}

inline float tabal(char a, char b) {
    return (a == b) ? _match : _mismatch;
}

float calculate(){
    float result = 0.0;
    float **V = new float*[seqA.size()];
    float **E = new float*[seqA.size()];
    float **F = new float*[seqA.size()];
    for(unsigned i = 0; i < seqA.size(); ++i){
        V[i] = new float[seqB.size()];
        E[i] = new float[seqB.size()];
        F[i] = new float[seqB.size()];
    }

    for(unsigned i = 0; i < seqA.size(); ++i){
        for(unsigned j = 0; j < seqB.size(); ++j){
            E[i][j] = j ? max(V[i][j-1] - alpha, E[i][j-1] - beta) : 0.0f;
            F[i][j] = i ? max(V[i-1][j] - alpha, F[i-1][j] - beta) : 0.0f;

            V[i][j] = max(E[i][j], F[i][j]);
            float temp = (i > 0 && j > 0) ? max(V[i-1][j-1] + tabal(seqA[i], seqB[j]), 0.0f) : tabal(seqA[i], seqB[j]) ;
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