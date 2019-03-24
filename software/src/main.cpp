#include<iostream>
#include<fstream>
#include<string>
#include<algorithm>
using namespace std;

#define TRACE

float alpha, beta, _match, _mismatch;
bool firstRead = true;
string seqA, seqB;

#ifdef TRACE
string targetA_rev, targetB_rev;
#endif//TRACE

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
    float result = tabal(seqA[0], seqB[0] );
    float **V = new float*[seqA.size()];
    float **E = new float*[seqA.size()];
    float **F = new float*[seqA.size()];
    
    #ifdef TRACE
    unsigned flagX = 0, flagY = 0;
    char **map = new char*[seqA.size()];
    #endif//TRACE
    
    for(unsigned i = 0; i < seqA.size(); ++i){
        V[i] = new float[seqB.size()];
        E[i] = new float[seqB.size()];
        F[i] = new float[seqB.size()];
        
        #ifdef TRACE
        map[i] = new char[seqB.size()];
        #endif//TRACE
    }

    for(unsigned i = 0; i < seqA.size(); ++i){
        for(unsigned j = 0; j < seqB.size(); ++j){
            E[i][j] = j ? max(V[i][j-1] - alpha, E[i][j-1] - beta) : 0.0f;
            F[i][j] = i ? max(V[i-1][j] - alpha, F[i-1][j] - beta) : 0.0f;

            //0. new start
            V[i][j] = 0.0f;
            #ifdef TRACE
            map[i][j] = 0;
            #endif//TRACE

            //1. diagonal 
            float temp = (i > 0 && j > 0) ? V[i-1][j-1] : 0.0f;
            temp += tabal(seqA[i], seqB[j]);
            if (temp > V[i][j] ){
                V[i][j] = temp;
                #ifdef TRACE
                map[i][j] = (i > 0 && j > 0) ? 1 : 0;
                #endif//TRACE
            }

            //2. gap A
            if(F[i][j] > V[i][j]){
                V[i][j] = F[i][j];
                #ifdef TRACE
                map[i][j] = 2;
                #endif//TRACE
            }

            //3. gap B
            if(E[i][j] > V[i][j]){
                V[i][j] = E[i][j];
                #ifdef TRACE
                map[i][j] = 3;
                #endif//TRACE
            }

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

    //trace
    #ifdef TRACE
    targetA_rev.clear();
    targetB_rev.clear();

    while(map[flagX][flagY] != 0){
        switch(map[flagX][flagY]){
            case 1:
                targetA_rev.push_back(seqA[flagX--]);
                targetB_rev.push_back(seqB[flagY--]);
                break;

            case 2:
                targetA_rev.push_back(seqA[flagX--]);
                targetB_rev.push_back('-');
                break;

            case 3:
                targetA_rev.push_back('-');
                targetB_rev.push_back(seqB[flagY--]);
                break;

            default :
                cerr << "ERROR with map number : " << int(map[flagX][flagY]) << " .\n";
                map[flagX][flagY] = 0;
        }
    }
    #endif//TRACE

    for(unsigned i = 0; i < seqA.size(); ++i){
        delete [] V[i];
        delete [] E[i];
        delete [] F[i];
        
        #ifdef TRACE
        delete [] map[i];
        #endif//TRACE
    }
    delete [] V;
    delete [] E;
    delete [] F;

    #ifdef TRACE
    delete [] map;
    #endif//TRACE
    
    return result;
}

int main(int argc, char** argv){
    if(argc != 2){
        cout << "Usage: exec [input_file_name]\n";
        return 1;
    }

    ifstream ifs(argv[1]);
    if(!ifs.is_open()){
        cout << "Error: file \"" << argv[1] << "\" doesn't exist!\n";
        return 1;
    }

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