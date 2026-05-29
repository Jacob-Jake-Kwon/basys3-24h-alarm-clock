`timescale 1ns / 1ps

module seven_seg_mux (
    input clk,
    input [4:0] hour,
    input [5:0] min,
    input blank,
    output reg [3:0] an,
    output reg [6:0] seg
);
    reg [18:0] scan_div = 0;
    always @(posedge clk) scan_div <= scan_div + 1'b1;

    reg [3:0] bcd_out;
    always @(*) begin
        if (blank) begin
            an = 4'b1111;
            bcd_out = 0;
        end else begin
            case (scan_div[18:17])
                2'b00: begin an = 4'b1110; bcd_out = min % 10; end
                2'b01: begin an = 4'b1101; bcd_out = min / 10; end
                2'b10: begin an = 4'b1011; bcd_out = hour % 10; end
                2'b11: begin an = 4'b0111; bcd_out = hour / 10; end
            endcase
        end
    end

    always @(*) begin
        case (bcd_out)
            4'd0: seg = 7'b1000000; 4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100; 4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001; 4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010; 4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000; 4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule