`timescale 1ns/1ps
module ff_sync(clock,resetn,data,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,write_enb,fifo_empty,fifo_full,vld_out_0,vld_out_1,vld_out_2);
    input clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg;
    input [1:0] data;
    output reg [0:2] write_enb;
    output reg fifo_empty,fifo_full,vld_out_0,vld_out_1,vld_out_2;
    reg [1:0] mem;
    always @(negedge clock) begin
        if (!resetn) begin
            write_enb <= 3'b000;
            fifo_empty <= 0;
            fifo_full <= 0;
            vld_out_0 <= 0;
            vld_out_1 <= 0;
            vld_out_2 <= 0;
            mem <= 2'b00;
        end
        else begin
            if (detect_add) begin
                mem <= data;
            end
            write_enb <= 3'b000;
            fifo_empty <= 0;
            fifo_full <= 0;
            vld_out_0 <= 0;
            vld_out_1 <= 0;
            vld_out_2 <= 0;
            case(mem)
                2'b00 : begin
                    fifo_empty <= empty_0;
                    fifo_full <= full_0;
                    vld_out_0 <= ~empty_0;
                    if(!full_0 && write_enb_reg) write_enb <= 3'b100;
                end
                2'b01 : begin
                    fifo_empty <= empty_1;
                    fifo_full <= full_1;
                    vld_out_1 <= ~empty_1;
                    if(!full_1 && write_enb_reg) write_enb <= 3'b010;
                end
                2'b10 : begin
                    fifo_empty <= empty_2;
                    fifo_full <= full_2;
                    vld_out_2 <= ~empty_2;
                    if(!full_2 && write_enb_reg) write_enb <= 3'b001;
                end
                default : begin
                    fifo_empty <= 0;
                    fifo_full  <= 1;
                    write_enb  <= 3'b000;
                    vld_out_0  <= 0;
                    vld_out_1  <= 0;
                    vld_out_2  <= 0;
                end
            endcase
        end
    end 
endmodule