#include "/home/cdodd/p4c/build/../p4include/core.p4"
#include "/home/cdodd/p4c/build/../p4include/v1model.p4"

struct ingress_metadata_t {
    bit<1>  drop;
    bit<8>  egress_port;
    bit<8>  f1;
    bit<16> f2;
    bit<32> f3;
    bit<64> f4;
}

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> ethertype;
}

header vag_t {
    bit<8>  f1;
    bit<16> f2;
    bit<32> f3;
    bit<64> f4;
}

struct metadata {
    @name("ing_metadata") 
    ingress_metadata_t ing_metadata;
}

struct headers {
    @name("ethernet") 
    ethernet_t ethernet;
    @name("vag") 
    vag_t      vag;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("start") state start {
        packet.extract(hdr.ethernet);
        packet.extract(hdr.vag);
        transition accept;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("nop") action nop() {
        bool hasReturned_1 = false;
    }
    @name("e_t1") table e_t1() {
        actions = {
            nop;
            NoAction;
        }
        key = {
            hdr.ethernet.srcAddr: exact;
        }
        default_action = NoAction();
    }

    apply {
        bool hasReturned_0 = false;
        e_t1.apply();
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("nop") action nop() {
        bool hasReturned_3 = false;
    }
    @name("ing_drop") action ing_drop() {
        bool hasReturned_4 = false;
        meta.ing_metadata.drop = 1w1;
    }
    @name("set_egress_port") action set_egress_port(bit<8> egress_port) {
        bool hasReturned_5 = false;
        meta.ing_metadata.egress_port = egress_port;
    }
    @name("set_f1") action set_f1(bit<8> f1) {
        bool hasReturned_6 = false;
        meta.ing_metadata.f1 = f1;
    }
    @name("set_f2") action set_f2(bit<16> f2) {
        bool hasReturned_7 = false;
        meta.ing_metadata.f2 = f2;
    }
    @name("set_f3") action set_f3(bit<32> f3) {
        bool hasReturned_8 = false;
        meta.ing_metadata.f3 = f3;
    }
    @name("set_f4") action set_f4(bit<64> f4) {
        bool hasReturned_9 = false;
        meta.ing_metadata.f4 = f4;
    }
    @name("i_t1") table i_t1() {
        actions = {
            nop;
            ing_drop;
            set_egress_port;
            set_f1;
            NoAction;
        }
        key = {
            hdr.vag.f1: exact;
        }
        size = 1024;
        default_action = NoAction();
    }

    @name("i_t2") table i_t2() {
        actions = {
            nop;
            set_f2;
            NoAction;
        }
        key = {
            hdr.vag.f2: exact;
        }
        size = 1024;
        default_action = NoAction();
    }

    @name("i_t3") table i_t3() {
        actions = {
            nop;
            set_f3;
            NoAction;
        }
        key = {
            hdr.vag.f3: exact;
        }
        size = 1024;
        default_action = NoAction();
    }

    @name("i_t4") table i_t4() {
        actions = {
            nop;
            set_f4;
            NoAction;
        }
        key = {
            hdr.vag.f4: exact;
        }
        size = 1024;
        default_action = NoAction();
    }

    apply {
        bool hasReturned_2 = false;
        i_t1.apply();
        if (meta.ing_metadata.f1 == hdr.vag.f1) {
            i_t2.apply();
            if (meta.ing_metadata.f2 == hdr.vag.f2) 
                i_t3.apply();
        }
        else 
            i_t4.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        bool hasReturned_10 = false;
        packet.emit(hdr.ethernet);
        packet.emit(hdr.vag);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
        bool hasReturned_11 = false;
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
        bool hasReturned_12 = false;
    }
}

V1Switch(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;