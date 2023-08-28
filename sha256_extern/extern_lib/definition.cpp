/* Copyright 2022 P4lang Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <bm/bm_sim/extern.h>
#include <bm/bm_sim/field_lists.h>

#include <cstdint>
#include <cstring>
#include <array>
#include <vector>
#include <string>
#include <sstream>
#include <ios>
#include <iomanip>

#include <bits/stdc++.h>
using namespace std;

// Defines
#define int int64_t // 64-bit integer 
// Using 64-bit integers, to avoid overflow, during additions
// But, in the end, we have to take modulo of each number with 2^32, making all numbers having MSB<=31

// Global Variables
int modulo=pow(2,32);

// Function to Rotate Right a 32-bit integer (word), by 'x' bits
int rot_right(int word, int x_bits)
{
    return ((word>>(x_bits)) | (word<<(32-x_bits)));
}

// Function to Compute 'sigma_1(x)'
int sigma1(int x)
{
    return (rot_right(x,17)^(rot_right(x,19))^((x)>>10));
}

// Function to Compute 'sigma_0(x)'
int sigma0(int x)
{
    return (rot_right(x,7)^(rot_right(x,18))^((x)>>3));
}

// Function to Compute 'S0(x)'
int S0(int x)
{
    return (rot_right(x,2)^(rot_right(x,13))^(rot_right(x,22)));
}

// Function to Compute 'S1(x)'
int S1(int x)
{
    return (rot_right(x,6)^(rot_right(x,11))^(rot_right(x,25)));
}

// Function to Compute 'Ch(a,b,c)'
int Ch(int a, int b, int c)
{
    return (a&b)^((~a)&c);
}

// Function to Compute 'Maj(a,b,c)'
int Maj(int a, int b, int c)
{
    return (a&b)^(a&c)^(b&c);
}

// Function to Convert a String, into a String of bits, corresponding to the ASCII Value of Characters in the String
string convert_string_to_bits(string &s)
{
    string ret="";
    for(auto x:s) // Iterate through the whole string 's'
    {
        int ascii_of_x=int(x);
        bitset<8> b(ascii_of_x); // Convert 'ascii_of_x' to a 8-bit binary string, using Bitset
        ret+=b.to_string(); 
    }
    return ret;
}   

// Function to Convert a 32-bit Integer to 'hexadecimal' String
string int_to_hex(int integer)
{
    stringstream ss;
    ss<<hex<<setw(8)<<setfill('0')<<integer;
    string ret;
    ss>>ret;
    return ret;
}

// Function to perform Pre-Processing 
void pre_process(string &input_str_in_bits) // Pre-Processing Step of the Algorithm
{
    int l=int(input_str_in_bits.size());
    input_str_in_bits+="1"; // Step '1'
    int k=0; 
    while(true) // Finding 'k'        
    {
        int curr_length_of_string=int(input_str_in_bits.size());
        int length_of_string_after_appending=k+curr_length_of_string+64;
        if(length_of_string_after_appending%512==0)
        {
            break;
        }
        k++;
    }
    for(int zeroes=0; zeroes<k; zeroes++) // Step '2'
    {
        input_str_in_bits+="0";
    }

    // Step '3' 
    bitset<64> b(l);
    input_str_in_bits+=b.to_string(); // Appending 64-bit String (= 'l' in Integer) to the end of Current String
}

// Function to break the string into chunks (blocks) of 512 bits
vector<string> break_into_chunks(string &input_str_in_bits)
{
    vector<string> ret;
    for(int i=0; i<int(input_str_in_bits.size()); i+=512) 
    {
        ret.push_back(input_str_in_bits.substr(i,512)); // '1' Chunk Added to the List
    }
    return ret;
}

// Function to Resize/Convert the 512-bit Blocks to '16' 32-bit Integers
vector<int> convert_512bits_to_16integers(string &s)
{
    vector<int> ret;
    for(int i=0; i<int(s.size()); i+=32)
    {
        bitset<32> b(s.substr(i,32)); // Using Bitset to Convert String of Bits, to Integer
        ret.push_back(b.to_ulong()); 
    }
    for(auto &x:ret) // Take Modulo with 2^32, for every Integer
    {
        x%=modulo;
    }
    return ret;
}

// Functin to Process the Hash Function, for i'th Message Block
void process_hash_function(int i, vector<int> &curr_block, vector<array<int,8>> &H, vector<int> &k)
{
    // Here, i = Current 'Message Block' Number

    // Initialize the 8 Working Variables, using Last Hash Values
    int a=H[i-1][0];
    int b=H[i-1][1];
    int c=H[i-1][2];
    int d=H[i-1][3];
    int e=H[i-1][4];
    int f=H[i-1][5];
    int g=H[i-1][6];
    int h=H[i-1][7];

    // Create a 64-entry Message Schedule Array w[0..63] of 32-bit Integers
    int w[64];

    // Copy the '16' 32-bit Integers of the Current Message Block, to w[0..15]
    for(int j=0; j<16; j++)
    {
        w[j]=curr_block[j];
    }   

    // Extend the first 16 words (32-bit Integers) into Remaining 48 [16..63] words, using Sigma Functions
    for(int j=16; j<64; j++)
    {
        w[j]=w[j-16]+sigma0(w[j-15])+sigma1(w[j-2])+w[j-7];
        w[j]%=modulo; // Take Modulo, to avoid overflow
    }

    // Main Hashing Loop
    for(int j=0; j<64; j++)
    {
        int temp1=h+S1(e)+Ch(e,f,g)+k[j]+w[j];
        int temp2=S0(a)+Maj(a,b,c);
        h=g;
        g=f;
        f=e;
        e=d+temp1;
        d=c;
        c=b;
        b=a;
        a=temp1+temp2;

        // Taking Modulo with 2^32
        e%=modulo;
        a%=modulo;
    }

    // Update Current Hash Values
    H[i][0]=H[i-1][0]+a;
    H[i][1]=H[i-1][1]+b;
    H[i][2]=H[i-1][2]+c;
    H[i][3]=H[i-1][3]+d;
    H[i][4]=H[i-1][4]+e;
    H[i][5]=H[i-1][5]+f;
    H[i][6]=H[i-1][6]+g;
    H[i][7]=H[i-1][7]+h;

    // Take Modulo with 2^32, for All Current New Hash Values
    for(int j=0; j<8; j++)
    {
        H[i][j]%=modulo;
    }
}


// Function to Process the Hash Function for all Message Blocks of 512-bit and find the Final Hash Value of the Input Message
string process_hash(vector<vector<int>> &M, vector<array<int,8>> &H, vector<int> &k)
{
    for(int i=1; i<=int(M.size()); i++) // For Each 512-bit Message Block, Process the Hash Function
    {
        process_hash_function(i,M[i-1],H,k);
    }
    string ret="";
    for(int i=0; i<8; i++)
    {
        ret+=int_to_hex(H[int(M.size())][i]);
    }
    return ret;
}



std::string get_hash(std::string s){
    // Convert the Input String to Bits
    string input_str_in_bits=convert_string_to_bits(s);

    // Do Pre-Processing on (input_str_in_bits), in the following manner:
    // 1. Append one '1' bit, to (input_str_in_bits)
    // 2. Append 'k'(>=0) '0' bits to (input_str_in_bits), such that length(input_str_in_bits) becomes 
       // exactly divisible by 512 (after completion of each pre-processing sub-step)
    // 3. Append l(length of original message, in terms of bits), as a 64-bit String
    pre_process(input_str_in_bits);

    // Break the Message(input_str_in_bits) into Chunks of 512 Bits
    vector<string> chunks_of_512_bits=break_into_chunks(input_str_in_bits);
    
    // Convert Each 512-Bits Message Chunk into '16' 32-bit integers
    vector<vector<int>> M;
    for(auto x:chunks_of_512_bits)
    {
        M.push_back(convert_512bits_to_16integers(x));
    }

    int number_of_512bit_chunks=int(M.size());

    // Vector to Store 8 Hash Values after each iteration of every 512-bit Block
    vector<array<int,8>> H(number_of_512bit_chunks+1);

    // Assigning Initial Hash Values
    // Actually, these are:
    // First 32 bits of the fractional parts of the square roots of the first 8 primes (from 2 to 19).
    H[0][0]=0x6a09e667;
    H[0][1]=0xbb67ae85;
    H[0][2]=0x3c6ef372;
    H[0][3]=0xa54ff53a;
    H[0][4]=0x510e527f;
    H[0][5]=0x9b05688c;
    H[0][6]=0x1f83d9ab;
    H[0][7]=0x5be0cd19;

    // 'Array of Round' Constants
    // Actually, these are:
    // First 32 bits of the fractional parts of the cube roots of the first 64 primes (from 2 to 311).
    vector<int> k=
    {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    }; 

    // Process the Hash Function of SHA-256 Algorithm, on each 512-bit block of the message successively
    string res=process_hash(M,H,k);

    return res;
}


void sha256_hash_256(bm::Data & a, bm::Data & b) {
	std::string str;
	std::string result = "";

	str = b.get_string();
        
	result = get_hash(str);
	
	a.set(result);
}

void sha256_hash_512(bm::Data & a, bm::Data & b, bm::Data & c) {
        std::string str;
        std::string result = "";

	str = b.get_string();
	str = str + c.get_string();
	
	result = get_hash(str);
        
        a.set(result);
}

void sha256_hash_1024(bm::Data & a, bm::Data & b, bm::Data & c, bm::Data & d, bm::Data & e) {
        std::string str;
        std::string result = "";
        
	str = b.get_string();
	str = str + c.get_string();
        str = str + d.get_string();
	str = str + e.get_string();

	result = get_hash(str);

        a.set(result);
}


BM_REGISTER_EXTERN_FUNCTION(sha256_hash_256, bm::Data &, bm::Data &);
BM_REGISTER_EXTERN_FUNCTION(sha256_hash_512, bm::Data &, bm::Data &, bm::Data &);
BM_REGISTER_EXTERN_FUNCTION(sha256_hash_1024, bm::Data &, bm::Data &, bm::Data &, bm::Data &, bm::Data &);
/*
// Example custom extern object.
class CustomCounter : public bm::ExternType {
 public:
  BM_EXTERN_ATTRIBUTES {
    BM_EXTERN_ATTRIBUTE_ADD(init_count);
  }

  void init() override {
    reset();
  }

  void reset() {
    count = init_count;
  }

  void read(bm::Data &count) const {
    count = this->count;
  }

  void increment_by(const bm::Data &amount) {
    count.set(count.get<size_t>() + amount.get<size_t>());
  }

 private:
  bm::Data init_count{0};
  bm::Data count{0};
};
BM_REGISTER_EXTERN(CustomCounter);
BM_REGISTER_EXTERN_METHOD(CustomCounter, reset);
BM_REGISTER_EXTERN_METHOD(CustomCounter, read, bm::Data &);
BM_REGISTER_EXTERN_METHOD(CustomCounter, increment_by, const bm::Data &);
*/
