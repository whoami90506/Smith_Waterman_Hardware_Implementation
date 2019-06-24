#include<iostream>
#include<fstream>
#include<string>
#include<algorithm>
#include <iomanip>
using namespace std;

//#define TRACE
//#define DEBUG_PRINTMATRIX

float alpha, beta, _match, _mismatch;
bool firstRead = true;
string seqA, seqB;

#ifdef TRACE
string targetA_rev, targetB_rev;
#endif//TRACE

bool readfile(ifstream& ifs){

    ifs >> _match;
    if(ifs.eof())return false;
    if(alpha < 0)return false;
    ifs >> _mismatch >> alpha >> beta;

    return true;
}

inline float table(char a, char b) {
    return (a == b) ? _match : -1 * _mismatch;
}

template<class T>
void printMatrix(T** m, string name){
    const bool printLabel = true;

    if(printLabel){
        cout << name << endl;
        cout << setw(4) << '_';
        for(auto& i : seqA)cout << setw(4) << i;
        cout << endl;
    }

    for(unsigned j = 0; j < seqB.size(); ++j){
        if(printLabel) cout << setw(4) << seqB[j];
        for(unsigned i = 0; i < seqA.size(); ++i)cout << setw(4) << int(m[i][j]);
        cout << endl;
    }
    cout << endl;
}

float calculate(){
    float result = table(seqA[0], seqB[0] );
    float **V = new float*[seqA.size()];
    float **E = new float*[seqA.size()];
    float **F = new float*[seqA.size()];
    
    #ifdef TRACE
    int flagX = 0, flagY = 0;
    #endif//TRACE
    
    for(unsigned i = 0; i < seqA.size(); ++i){
        V[i] = new float[seqB.size()];
        E[i] = new float[seqB.size()];
        F[i] = new float[seqB.size()];
    }

    for(unsigned i = 0; i < seqA.size(); ++i){
        for(unsigned j = 0; j < seqB.size(); ++j){
            E[i][j] = j ? max(V[i][j-1] - alpha, E[i][j-1] - beta) : 0.0f;
            F[i][j] = i ? max(V[i-1][j] - alpha, F[i-1][j] - beta) : 0.0f;

            //0. new start
            V[i][j] = 0.0f;

            //1. diagonal 
            float temp = (i > 0 && j > 0) ? V[i-1][j-1] : 0.0f;
            temp += table(seqA[i], seqB[j]);
            if (temp > V[i][j] )V[i][j] = temp;

            //2. gap A
            if(F[i][j] > V[i][j])V[i][j] = F[i][j];

            //3. gap B
            if(E[i][j] > V[i][j])V[i][j] = E[i][j];

            //result
            if (V[i][j] > result){
                result = V[i][j];
                #ifdef TRACE
                flagX = i;
                flagY = j;
                #endif//TRACE
            }
        }
    }

    //print matrix
    #ifdef DEBUG_PRINTMATRIX
    printMatrix(E, "E");
    printMatrix(F, "F");
    printMatrix(V, "V");
    #endif//DEBUG_PRINTMATRIX

    //trace
    #ifdef TRACE
    targetA_rev.clear();
    targetB_rev.clear();

    while(flagX >= 0 && flagY >= 0){
        if(V[flagX][flagY] == 0)flagX = -1;
        else if (V[flagX][flagY] == F[flagX][flagY]){
            targetA_rev.push_back(seqA[flagX--]);
            targetB_rev.push_back('-');
        }else if (V[flagX][flagY] == E[flagX][flagY]){
            targetA_rev.push_back('-');
            targetB_rev.push_back(seqB[flagY--]); 
        }else {
            targetA_rev.push_back(seqA[flagX--]);
            targetB_rev.push_back(seqB[flagY--]);
        }
    }
    #endif//TRACE

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
    if(argc != 2){
        cout << "Usage: exec [input_file]\n";
        return 1;
    }

    ifstream ifs(argv[1]);
    if(!ifs.is_open()){
        cout << "Error: file \"" << argv[1] << "\" doesn't exist!\n";
        return 1;
    }
    ifs >> seqA >> seqB;

    //calculate
    while(readfile(ifs)){
        cout << calculate() << endl;
        #ifdef TRACE
        for(string::reverse_iterator i = targetA_rev.rbegin(); i != targetA_rev.rend(); ++i)cout << *i;
        cout << endl;
        for(string::reverse_iterator i = targetB_rev.rbegin(); i != targetB_rev.rend(); ++i)cout << *i;
        cout << endl;
        #endif//TRACE
    }

    ifs.close();
}