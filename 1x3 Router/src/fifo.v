`timescale 1ns/1ps
module fifo(clock, resetn, write_en, read_en, data_in, full, empty, data_out); 
    input clock, resetn, write_en, read_en;
    input [7:0] data_in;
    output full, empty;
    output reg [7:0] data_out;
    reg [4:0] wrt_ptr;
    reg [4:0] rd_ptr;
    reg [7:0] mem [0:15];
    always @(posedge clock) begin
        if(!resetn)begin
            wrt_ptr <= 0;
            rd_ptr <= 0;          
            data_out <= 8'b0;
        end 
        else begin
            //WRITE Operation
            if(write_en && !full) begin
                mem[wrt_ptr] <= data_in;
                wrt_ptr <= wrt_ptr + 1;
            end
            //READ operation
            if(read_en && !empty) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1; 
            end
        end
    end
    assign full = (rd_ptr == {~wrt_ptr[4],wrt_ptr[3:0]});
    assign empty = (wrt_ptr[3:0] == rd_ptr[3:0]);
endmodule
