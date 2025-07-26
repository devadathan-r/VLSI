`timescale 1ns / 1ps
module router(clock,data,packet_valid,resetn,suspend_data,err,data_out_0,vld_out_0,read_enb_0,data_out_1,vld_out_1,read_enb_1,data_out_2,vld_out_2,read_enb_2);
    input clock,packet_valid,resetn,read_enb_0,read_enb_1,read_enb_2;
    input [7:0] data;
    output suspend_data,err,vld_out_0,vld_out_1,vld_out_2;
    output [7:0] data_out_0,data_out_1,data_out_2;
    //register
    wire [7:0] dout;
    //fsm wires
    //output
    wire reset_int_reg,lfd_state,full_state,laf_state,lp_state,ld_state,detect_add,write_enb_reg;
    //input
    wire fifo_full, fifo_empty, parity_done,low_packet_valid;
    //fifo
    wire full_0,full_1,full_2;
    wire empty_0,empty_1,empty_2;
    wire [0:2] write_enb;
    //instantiation
    //FSM Block
    fsm FSM(clock,resetn,packet_valid,data,fifo_full,fifo_empty,parity_done,low_packet_valid,suspend_data,write_enb_reg,detect_add,ld_state,lp_state,laf_state,lfd_state,full_state,reset_int_reg);
    //Register Block
    router_reg register(clock,resetn,packet_valid,data,fifo_full,detect_add,ld_state,lp_state,laf_state,full_state,lfd_state,reset_int_reg,dout,err,parity_done,low_packet_valid);
    //Synchronizer Block
    ff_sync synchronizer(clock,resetn,data[1:0],detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,write_enb,fifo_empty,fifo_full,vld_out_0,vld_out_1,vld_out_2);
    //FIFO Block
    fifo fifo_0(clock,resetn,write_enb[0],read_enb_0,dout,full_0,empty_0,data_out_0);
    fifo fifo_1(clock,resetn,write_enb[1],read_enb_1,dout,full_1,empty_1,data_out_1);
    fifo fifo_2(clock,resetn,write_enb[2],read_enb_2,dout,full_2,empty_2,data_out_2);   
endmodule
