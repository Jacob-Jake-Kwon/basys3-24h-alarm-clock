`timescale 1ns / 1ps

module time_reg (
    input clk, rst,
    input tick_1m,
    input set_mode,
    input btnU, btnD, btnR, btnL,
    output reg [4:0] hour,
    output reg [5:0] min
);
    localparam INIT_HOUR = 5'd12;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hour <= INIT_HOUR;
            min  <= 6'd0;
        end else if (set_mode) begin
            if (btnU) hour <= (hour == 23) ? 5'd0 : hour + 1'b1;
            if (btnD) hour <= (hour == 0)  ? 5'd23 : hour - 1'b1;
            if (btnR) min  <= (min == 59)  ? 6'd0 : min + 1'b1;
            if (btnL) min  <= (min == 0)   ? 6'd55 : min - 1'b1; // Jumps by 5m or 1m depending on layout preference
        end else if (tick_1m) begin
            if (min == 59) begin
                min  <= 6'd0;
                hour <= (hour == 23) ? 5'd0 : hour + 1'b1;
            end else begin
                min  <= min + 1'b1;
            end
        end
    end
endmodule