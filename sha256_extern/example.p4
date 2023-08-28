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

#include <core.p4>
#include <v1model.p4>

#include "extern_lib/declaration.p4"

header eth_h {
    bit<48> dst;
    bit<48> src;
    bit<16> type;
}

header test_h {
    bit<256> a;
    bit<8> b;
    bit<8> c;
    bit<8> d;
}

struct header_t {
    eth_h eth;
    test_h test;
}

struct metadata_t {}

parser MyParser(
    packet_in pkt,
    out header_t hdr,
    inout metadata_t meta,
    inout standard_metadata_t std_meta
) {
    state start {
        pkt.extract(hdr.eth);
        pkt.extract(hdr.test);
        transition accept;
    }
}

control MyVerifyChecksum(
    inout header_t hdr,
    inout metadata_t meta
) {
    apply {}
}

control MyIngress(
    inout header_t hdr,
    inout metadata_t meta,
    inout standard_metadata_t std_meta
) {

    apply {
        sha256_hash_512(hdr.test.a, hdr.test.b, hdr.test.c);
        
	// Always forward the packet to port 1.
        std_meta.egress_spec = 1;
    }
}

control MyEgress(
    inout header_t hdr,
    inout metadata_t meta,
    inout standard_metadata_t std_meta
) {
    apply {}
}

control MyComputeChecksum(
    inout header_t hdr,
    inout metadata_t meta
) {
    apply {}
}

control MyDeparser(
    packet_out pkt,
    in header_t hdr
) {
    apply {
        pkt.emit(hdr.eth);
        pkt.emit(hdr.test);
    }
}

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
