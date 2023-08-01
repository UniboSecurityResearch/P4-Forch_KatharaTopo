/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

#define COLLECTION_TIMEDELTA 55000
#define STARTING_PAYLOAD_CHUNK_SIZE 2016
#define PAYLOAD_CHUNK_SIZE 2048
#define HASH_BASE 32w0
#define HASH_MAX 32w4294967295

const bit<16> TYPE_IPV4 = 0x0800;
const bit<16> TYPE_ARP  = 0x0806;
const bit<8>  TYPE_TCP  = 6;

// ARP RELATED CONST VARS
const bit<16> ARP_HTYPE = 0x0001; //Ethernet Hardware type is 1
const bit<16> ARP_PTYPE = TYPE_IPV4; //Protocol used for ARP is IPV4
const bit<8>  ARP_HLEN  = 6; //Ethernet address size is 6 bytes
const bit<8>  ARP_PLEN  = 4; //IP address size is 4 bytes
const bit<16> ARP_REQ = 1; //Operation 1 is request
const bit<16> ARP_REPLY = 2; //Operation 2 is reply


/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header arp_t {
  bit<16>   h_type;
  bit<16>   p_type;
  bit<8>    h_len;
  bit<8>    p_len;
  bit<16>   op_code;
  macAddr_t src_mac;
  ip4Addr_t src_ip;
  macAddr_t dst_mac;
  ip4Addr_t dst_ip;
  }


header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header tcp_t{
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<4>  res;
    bit<1>  cwr;
    bit<1>  ece;
    bit<1>  urg;
    bit<1>  ack;
    bit<1>  psh;
    bit<1>  rst;
    bit<1>  syn;
    bit<1>  fin;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header udp_t {
    bit<16>  srcPort;
    bit<16>  dstPort;
    bit<16>  udplen;
    bit<16>  udpchk;
}

header icmp_t {
    bit<8> type;
    bit<8> code;
    bit<16> checksum;
}

// WARNING: Several TCP options have only a kind byte, with no length
// byte in them at all.  I am writing a hacked up version of this
// program that avoids using P4_16 header_union's, since they are not
// fully supported yet.  I am sacrificing accuracy to the TCP standard
// by doing this, so do not use this code for actual TCP option
// parsing!!!

header Tcp_faked_option_h {
    bit<8> kind;
    bit<8> length;
    varbit<256> variable_stuff;
}

// Defines a stack of 10 tcp options
typedef Tcp_faked_option_h[10] Tcp_option_stack;

header Tcp_option_padding_h {
    varbit<256> padding;
}

error {
    TcpDataOffsetTooSmall,
    TcpOptionTooLongForHeader,
    TcpBadSackOptionLength
}

struct Tcp_option_sack_top
{
    bit<8> kind;
    bit<8> length;
}

// This sub-parser is intended to be apply'd just after the base
// 20-byte TCP header has been extracted.  It should be called with
// the value of the Data Offset field.  It will fill in the @vec
// argument with a stack of TCP options found, perhaps empty.

// Unless some error is detect earlier (causing this sub-parser to
// transition to the reject state), it will advance exactly to the end
// of the TCP header, leaving the packet 'pointer' at the first byte
// of the TCP payload (if any).  If the packet ends before the full
// TCP header can be consumed, this sub-parser will set
// error.PacketTooShort and transition to reject.

parser Tcp_option_parser(packet_in b,
                         in bit<4> tcp_hdr_data_offset,
                         out Tcp_option_stack vec,
                         out Tcp_option_padding_h padding)
{
    bit<7> tcp_hdr_bytes_left;
    
    state start {
        // RFC 793 - the Data Offset field is the length of the TCP
        // header in units of 32-bit words.  It must be at least 5 for
        // the minimum length TCP header, and since it is 4 bits in
        // size, can be at most 15, for a maximum TCP header length of
        // 15*4 = 60 bytes.
        verify(tcp_hdr_data_offset >= 5, error.TcpDataOffsetTooSmall);
        tcp_hdr_bytes_left = 4 * (bit<7>) (tcp_hdr_data_offset - 5);
        // always true here: 0 <= tcp_hdr_bytes_left <= 40
        transition next_option;
    }
    state next_option {
        transition select(tcp_hdr_bytes_left) {
            0 : accept;  // no TCP header bytes left
            default : next_option_part2;
        }
    }
    state next_option_part2 {
        // precondition: tcp_hdr_bytes_left >= 1
        transition select(b.lookahead<bit<8>>()) {
            0: parse_tcp_option_end;
            1: parse_tcp_option_nop;
            2: parse_tcp_option_ss;
            3: parse_tcp_option_s;
            5: parse_tcp_option_sack;
        }
    }
    state parse_tcp_option_end {
        verify(tcp_hdr_bytes_left >= 2, error.TcpOptionTooLongForHeader);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - 2;
        b.extract(vec.next, 0);
        transition consume_remaining_tcp_hdr_and_accept;
    }
    state consume_remaining_tcp_hdr_and_accept {
        // A more picky sub-parser implementation would verify that
        // all of the remaining bytes are 0, as specified in RFC 793,
        // setting an error and rejecting if not.  This one skips past
        // the rest of the TCP header without checking this.

        // tcp_hdr_bytes_left might be as large as 40, so multiplying
        // it by 8 it may be up to 320, which requires 9 bits to avoid
        // losing any information.
        b.extract(padding, (bit<32>) (8 * (bit<9>) tcp_hdr_bytes_left));
        transition accept;
    }
    state parse_tcp_option_nop {
        verify(tcp_hdr_bytes_left >= 2, error.TcpOptionTooLongForHeader);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - 2;
        b.extract(vec.next, 0);
        transition next_option;
    }
    state parse_tcp_option_ss {
        verify(tcp_hdr_bytes_left >= 5, error.TcpOptionTooLongForHeader);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - 5;
        b.extract(vec.next, 3*8);
        transition next_option;
    }
    state parse_tcp_option_s {
        verify(tcp_hdr_bytes_left >= 4, error.TcpOptionTooLongForHeader);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - 4;
        b.extract(vec.next, 2*8);
        transition next_option;
    }
    state parse_tcp_option_sack {
        bit<8> n_sack_bytes = b.lookahead<Tcp_option_sack_top>().length;
        // I do not have global knowledge of all TCP SACK
        // implementations, but from reading the RFC, it appears that
        // the only SACK option lengths that are legal are 2+8*n for
        // n=1, 2, 3, or 4, so set an error if anything else is seen.
        verify(n_sack_bytes == 10 || n_sack_bytes == 18 ||
               n_sack_bytes == 26 || n_sack_bytes == 34,
               error.TcpBadSackOptionLength);
        verify(tcp_hdr_bytes_left >= (bit<7>) n_sack_bytes,
               error.TcpOptionTooLongForHeader);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - (bit<7>) n_sack_bytes;
        b.extract(vec.next, (bit<32>) (8 * n_sack_bytes - 16));
        transition next_option;
    }
}

header payload_t{
    bit<32> crc32;
    bit<STARTING_PAYLOAD_CHUNK_SIZE> payload;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t   ethernet;
    arp_t        arp;
    ipv4_t       ipv4;
    tcp_t            tcp;
    Tcp_option_stack tcp_options_vec;
    Tcp_option_padding_h tcp_options_padding;
    udp_t        udp;
    icmp_t       icmp;
    payload_t    payload;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
          TYPE_ARP: parse_arp;
          TYPE_IPV4: parse_ipv4;
          default: accept;
        }
        
    }

    state parse_arp {
      packet.extract(hdr.arp);
        transition select(hdr.arp.op_code) {
          ARP_REQ: accept;
      }
    }


    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol){
            8w0x01: parse_icmp;
            TYPE_TCP: tcp;
            8w0x11: parse_udp;
            default: accept;
        }
    }

    state parse_icmp {
        packet.extract(hdr.icmp);
        transition accept;
    }

    state tcp {
       packet.extract(hdr.tcp);
       transition parse_tcp_payload;
    }

    state parse_udp {
       packet.extract(hdr.udp);
       transition accept;
    }
    state parse_tcp_payload {
        packet.extract(hdr.payload);
        //Tcp_option_parser.apply(packet, hdr.tcp.dataOffset,
        //            hdr.tcp_options_vec, hdr.tcp_options_padding);
        transition accept;
    }
}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    register<bit<32>>(2) last_saved_crc32;

    action drop() {
        mark_to_drop(standard_metadata);
    }

    action arp_reply(macAddr_t request_mac) {
      //update operation code from request to reply
      hdr.arp.op_code = ARP_REPLY;
      
      //reply's dst_mac is the request's src mac
      hdr.arp.dst_mac = hdr.arp.src_mac;
      
      //reply's dst_ip is the request's src ip
      hdr.arp.src_mac = request_mac;

      //reply's src ip is the request's dst ip
      hdr.arp.src_ip = hdr.arp.dst_ip;

      //update ethernet header
      hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
      hdr.ethernet.srcAddr = request_mac;

      //send it back to the same port
      standard_metadata.egress_spec = standard_metadata.ingress_port;
      
    }
    
    action l2_forward(egressSpec_t port) {
        standard_metadata.egress_spec = port;
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table arp_exact {
        key = {
            hdr.arp.dst_ip: exact;
        }
        actions = {
            arp_reply;
            drop;
        }
        size = 1024;
        default_action = drop;
    }

    table ipv4_exact {
        key = {
            hdr.ipv4.dstAddr: exact;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    apply {
        bit<32> crc;

    /*
        if (hdr.tcp.isValid()) {
            last_saved_crc32.write(0, hdr.payload.crc32);
            hash(crc,     HashAlgorithm.crc32, HASH_BASE, {hdr.payload.payload}, HASH_MAX);
            hdr.payload.crc32 = crc;
            last_saved_crc32.write(1, crc);
        }
    */
        if (hdr.ipv4.isValid()) {
            ipv4_exact.apply();
        } 
        else if (hdr.ethernet.etherType == TYPE_ARP)
        {
          //cannot validate ARP header, dunno why :S
          arp_exact.apply();
        } 
        else
        {
          mark_to_drop(standard_metadata);        
        }
        
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    register<bit<48>>(1000) packet_processing_time_array; //egress timestamp - ingress timestamp
    register<bit<32>>(1000) packet_enqueuing_time_array; //enq_timestamp
    register<bit<19>>(1000) packet_enqueuing_depth_array; //enq_qdepth
    register<bit<32>>(1000) packet_dequeuing_timedelta_array; //deq_timedelta
    register<bit<19>>(1000) packet_dequeuing_depth_array; //deq_qdepth
    
    register<bit<48>>(1) timestamp_last_seen_packet;
    register<bit<32>>(1) last_saved_index;
    bit<48> diff_time;
    bit<48> last_time;
    bit<32> current_index;


    apply {  
        timestamp_last_seen_packet.read(last_time,     0);

        diff_time = standard_metadata.ingress_global_timestamp - last_time;
        if (diff_time > (bit<48>)COLLECTION_TIMEDELTA) { //grab info everytime the window is hit
            //retrieve index
            last_saved_index.read(current_index,     0);
            
            //retrieve packet processing time
            packet_processing_time_array.write(current_index,     
                standard_metadata.egress_global_timestamp-standard_metadata.ingress_global_timestamp);
            
            //retrieve enqueuing timestamp
            packet_enqueuing_time_array.write(current_index,     
                standard_metadata.enq_timestamp);

            //retrieve enqueue depth 
            packet_enqueuing_depth_array.write(current_index,     
                standard_metadata.enq_qdepth);

            //retrieve dequeue timedelta 
            packet_dequeuing_timedelta_array.write(current_index,     
                standard_metadata.deq_timedelta);

            //retrieve dequeuing timestamp
            packet_dequeuing_depth_array.write(current_index,     
                standard_metadata.deq_qdepth);

            //update index
            last_saved_index.write(0,     current_index + 1);
            if(current_index + 1 > 999){
                last_saved_index.write(0,     0);
            }
            
            //reset time window
            timestamp_last_seen_packet.write(0,     standard_metadata.ingress_global_timestamp);  
        }
    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply {
	update_checksum(
	    hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	      hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    update_checksum(
	            hdr.tcp.isValid(),
                {hdr.payload.payload},
                hdr.payload.crc32,
            HashAlgorithm.crc32);
    }
}


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        /* TODO: add deparser logic */
        packet.emit(hdr.ethernet);
        packet.emit(hdr.arp);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.icmp);
        packet.emit(hdr.udp);
        packet.emit(hdr.tcp);
        packet.emit(hdr.payload);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;