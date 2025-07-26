`timescale 1ns/1ps
module fsm #(
    parameter DECODE_ADDRESS = 3'b000,
    parameter LOAD_FIRST_DATA = 3'b001,
    parameter WAIT_TILL_EMPTY = 3'b010,
    parameter LOAD_DATA = 3'b011,
    parameter FIFO_FULL_STATE = 3'b100,
    parameter LOAD_AFTER_FULL = 3'b101,
    parameter LOAD_PARITY = 3'b110,
    parameter CHECK_PARITY_ERROR = 3'b111
) (clock,resetn,packet_valid,data,fifo_full,fifo_empty,parity_done,low_packet_valid,suspend_data,write_enb_reg,detect_add,ld_state,lp_state,laf_state,lfd_state,full_state,reset_int_reg);
    input clock, resetn, packet_valid, fifo_full, fifo_empty, parity_done, low_packet_valid;
    input [7:0] data;
    output reg suspend_data, write_enb_reg, detect_add, ld_state, lp_state, laf_state, lfd_state, full_state, reset_int_reg;
    reg [2:0] state; //state register
    //state
    always @(posedge clock) begin
        if (!resetn) begin
        {suspend_data, write_enb_reg, detect_add, ld_state, lp_state, laf_state, lfd_state, full_state, reset_int_reg} = 9'b0;
        end
        else begin 
            {suspend_data, write_enb_reg, detect_add, ld_state, lp_state, laf_state, lfd_state, full_state, reset_int_reg} = 9'b0;
            if (state == DECODE_ADDRESS) begin
                if (packet_valid && (data[1:0] != 2'b11) && fifo_empty) begin
                    state <= LOAD_FIRST_DATA;
                    detect_add <= 1;
                end
                else if (packet_valid && (!fifo_empty)) begin
                    state <= WAIT_TILL_EMPTY;
                    detect_add <= 1;
                    suspend_data <= 1;
                    write_enb_reg <= 1;
                end
                else state <= state;
            end

            else if (state == WAIT_TILL_EMPTY) begin
                if (fifo_empty) state <= LOAD_FIRST_DATA;
                else begin
                    //state <= WAIT_TILL_EMPTY;
                    suspend_data <= 1;
                    write_enb_reg <= 0;
                end
            end

            else if (state == LOAD_FIRST_DATA) begin
                state <= LOAD_DATA;
                lfd_state <= 1;
                write_enb_reg <= 1;
                suspend_data <= 1;
            end

            else if (state == LOAD_DATA) begin
                if (!fifo_full) begin
                    if(packet_valid) begin
                        state <= LOAD_DATA;
                        ld_state <= 1;
                        write_enb_reg <= 1;
                        suspend_data <= 0;
                    end
                    else begin
                        state <= LOAD_PARITY;
                        ld_state <= 1;
                        write_enb_reg <= 1;
                        suspend_data <= 0;
                    end
                end
                else begin
                    state <= FIFO_FULL_STATE;
                    suspend_data <= 1;
                    write_enb_reg <= 0;
                    full_state <= 1;
                end
            end

            else if (state == LOAD_PARITY) begin
                if (fifo_full) begin
                    state <= FIFO_FULL_STATE;
                    lp_state <= 1;
                    suspend_data <= 1;
                    write_enb_reg <= 1;
                end
                else begin
                    state <= CHECK_PARITY_ERROR;
                    lp_state <= 1;
                    suspend_data <= 1;
                    write_enb_reg <= 1;
                end
            end

            else if (state == FIFO_FULL_STATE) begin
                if (!fifo_full) begin
                    state <= LOAD_AFTER_FULL;
                    laf_state <= 1;
                    write_enb_reg <= 1;
                end
                else begin
                    suspend_data <= 1;
                    write_enb_reg <= 0;
                    full_state <= 1;
                end
            end

            else if (state == LOAD_AFTER_FULL) begin
                if (parity_done) begin
                    state <= CHECK_PARITY_ERROR;
                    laf_state <= 1;
                    suspend_data <= 1;
                    write_enb_reg <= 1;
                end
                else if (low_packet_valid) begin
                    state <= LOAD_PARITY;
                    laf_state <= 1;
                    suspend_data <= 1;
                    write_enb_reg <= 1;
                end
                else begin
                    state <= LOAD_DATA;
                    laf_state <= 1;
                    suspend_data <= 1;
                    write_enb_reg <= 1;
                end
            end
            else if (state == CHECK_PARITY_ERROR) begin
                state <= DECODE_ADDRESS;
                reset_int_reg <= 1;
            end
            else state <= DECODE_ADDRESS;   
        end
    end
endmodule
