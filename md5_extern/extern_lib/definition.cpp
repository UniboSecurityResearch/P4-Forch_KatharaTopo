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
#include <cstring>
#include <cmath>
#include <stdlib.h>
#include <string>

#include <sstream>

using namespace std;

typedef union uwb {
	unsigned w;
	unsigned char b[4];
} MD5union;

typedef unsigned DigestArray[4];

static unsigned func0(unsigned abcd[]){
	return (abcd[1] & abcd[2]) | (~abcd[1] & abcd[3]);
}

static unsigned func1(unsigned abcd[]){
	return (abcd[3] & abcd[1]) | (~abcd[3] & abcd[2]);
}

static unsigned func2(unsigned abcd[]){
	return  abcd[1] ^ abcd[2] ^ abcd[3];
}

static unsigned func3(unsigned abcd[]){
	return abcd[2] ^ (abcd[1] | ~abcd[3]);
}

typedef unsigned(*DgstFctn)(unsigned a[]);

static unsigned *calctable(unsigned *k)
{
	double s, pwr;
	int i;

	pwr = pow(2.0, 32);
	for (i = 0; i<64; i++) {
		s = fabs(sin(1.0 + i));
		k[i] = (unsigned)(s * pwr);
	}
	return k;
}

static unsigned rol(unsigned r, short N)
{
	unsigned  mask1 = (1 << N) - 1;
	return ((r >> (32 - N)) & mask1) | ((r << N) & ~mask1);
}

static unsigned* MD5Hash(string msg)
{
	int mlen = msg.length();
	static DigestArray h0 = { 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476 };
	static DgstFctn ff[] = { &func0, &func1, &func2, &func3 };
	static short M[] = { 1, 5, 3, 7 };
	static short O[] = { 0, 1, 5, 0 };
	static short rot0[] = { 7, 12, 17, 22 };
	static short rot1[] = { 5, 9, 14, 20 };
	static short rot2[] = { 4, 11, 16, 23 };
	static short rot3[] = { 6, 10, 15, 21 };
	static short *rots[] = { rot0, rot1, rot2, rot3 };
	static unsigned kspace[64];
	static unsigned *k;

	static DigestArray h;
	DigestArray abcd;
	DgstFctn fctn;
	short m, o, g;
	unsigned f;
	short *rotn;
	union {
		unsigned w[16];
		char     b[64];
	}mm;
	int os = 0;
	int grp, grps, q, p;
	unsigned char *msg2;

	if (k == NULL) k = calctable(kspace);

	for (q = 0; q<4; q++) h[q] = h0[q];

	{
		grps = 1 + (mlen + 8) / 64;
		msg2 = (unsigned char*)malloc(64 * grps);
		memcpy(msg2, msg.c_str(), mlen);
		msg2[mlen] = (unsigned char)0x80;
		q = mlen + 1;
		while (q < 64 * grps){ msg2[q] = 0; q++; }
		{
			MD5union u;
			u.w = 8 * mlen;
			q -= 8;
			memcpy(msg2 + q, &u.w, 4);
		}
	}

	for (grp = 0; grp<grps; grp++)
	{
		memcpy(mm.b, msg2 + os, 64);
		for (q = 0; q<4; q++) abcd[q] = h[q];
		for (p = 0; p<4; p++) {
			fctn = ff[p];
			rotn = rots[p];
			m = M[p]; o = O[p];
			for (q = 0; q<16; q++) {
				g = (m*q + o) % 16;
				f = abcd[1] + rol(abcd[0] + fctn(abcd) + k[q + 16 * p] + mm.w[g], rotn[q % 4]);

				abcd[0] = abcd[3];
				abcd[3] = abcd[2];
				abcd[2] = abcd[1];
				abcd[1] = f;
			}
		}
		for (p = 0; p<4; p++)
			h[p] += abcd[p];
		os += 64;
	}

	return h;
}
static string GetMD5String(string msg) {
	string str;
	int j, k;
	unsigned *d = MD5Hash(msg);
	MD5union u;
	for (j = 0; j<4; j++){
		u.w = d[j];
		char s[9];
		sprintf(s, "%02x%02x%02x%02x", u.b[0], u.b[1], u.b[2], u.b[3]);
		str += s;
	}

	return str;
}

void md5_hash_256(bm::Data & a, bm::Data & b) {
	string str;
	str = GetMD5String(b.get_string());
	a.set(str);
}

void md5_hash_512(bm::Data & a, bm::Data & b, bm::Data & c) {
        string str;
	str = b.get_string();
	str = str + c.get_string();
        str = GetMD5String(str);
        a.set(str);
}

void md5_hash_1024(bm::Data & a, bm::Data & b, bm::Data & c, bm::Data & d, bm::Data & e) {
        string str;
	str = b.get_string();
        str = str + c.get_string();
        str = str + d.get_string();
	str = str + e.get_string();
	str = GetMD5String(str);
        a.set(str);
}


BM_REGISTER_EXTERN_FUNCTION(md5_hash_256, bm::Data &, bm::Data &);
BM_REGISTER_EXTERN_FUNCTION(md5_hash_512, bm::Data &, bm::Data &, bm::Data &);
BM_REGISTER_EXTERN_FUNCTION(md5_hash_1024, bm::Data &, bm::Data &, bm::Data &, bm::Data &, bm::Data &);
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
