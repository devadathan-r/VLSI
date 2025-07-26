`timescale 1ns/1ps
module router_reg (clock, resetn, packet_valid, data, fifo_full, detect_add, ld_state, lp_state, laf_state, full_state, lfd_state, reset_int_reg, dout, err, parity_done, low_packet_valid);
    input clock, resetn, packet_valid, fifo_full, detect_add, ld_state, lp_state, laf_state, full_state, lfd_state, reset_int_reg;
    input [7:0] data;
    output reg [7:0] dout;
    output reg err, parity_done, low_packet_valid;
    //internal registers
    reg [7:0] first_byte, received_parity, computed_parity, full_state_byte;
    always @(negedge clock) begin
        //reset
        if(!resetn) begin
            dout <= 0;
            err <= 0;
            parity_done <= 0;
            low_packet_valid <= 0;
            computed_parity <= 0;
            first_byte <= 0;
            received_parity <= 0;
            full_state_byte <= 0;
        end
        else begin
            //decode address
            if(detect_add) begin
                first_byte <= data;
            end
            //load first data
            else if(lfd_state) begin
                dout <= first_byte;
                computed_parity <= first_byte;
            end
            //load data
            else if(ld_state) begin //fsm indicates that payload data is arriving
                if(!packet_valid && !low_packet_valid) low_packet_valid <= 1;
                if(!fifo_full) begin
                    dout <= data;
                    computed_parity <= computed_parity ^ data;
                end
                else full_state_byte <= data;
            end
            //load after full
            else if(laf_state) begin
                dout <= full_state_byte;
                computed_parity <= computed_parity ^ full_state_byte;
            end
            //load parity
            else if(lp_state) begin
                received_parity <= data;
                dout <= data;
                if(data != computed_parity) err <=1;
                parity_done <= 1;
            end
            //check parity error
            else if(reset_int_reg) begin
                parity_done <= 0;
                low_packet_valid <= 0;
                err <= 0;
            end
        end
    end 
endmodule