`timescale 1ns / 1ps

module btn_pulse (
    input clk, rst,
    input btn_in,
    output btn_push
);
    reg s0, s1, prev;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {s0, s1, prev} <= 3'b0;
        end else begin
            s0   <= btn_in;
            s1   <= s0;
            prev <= s1;
        end
    end
    assign btn_push = s1 && !prev;
endmodule