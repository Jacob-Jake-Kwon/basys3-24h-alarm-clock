`timescale 1ns / 1ps

module basys3_24h_alarm_clock (
    input clk,
    input btnC, btnU, btnD, btnR, btnL,
    input [2:0] sw,
    output reg [15:0] led,
    output reg [6:0] seg,
    output reg [3:0] an,
    output dp,
    output buzzer,
    output reg ext_led
);

    // Time constants and internal clock division registers
    localparam INIT_HOUR = 5'd12, INIT_MIN = 6'd00;
    reg [26:0] clk_div = 0;
    reg [5:0] sec_count = 0, min_count = INIT_MIN;
    reg [4:0] hour_count = INIT_HOUR;
    wire tick_1s = (clk_div == 27'd99_999_999);

    // Alarm register definitions
    reg [5:0] alarm_min = 0; reg [4:0] alarm_hour = 0;

    // Synchronizers and input push filters
    reg btnU_s0, btnU_s1, btnD_s0, btnD_s1, btnR_s0, btnR_s1, btnL_s0, btnL_s1;
    reg btnU_prev, btnD_prev, btnR_prev, btnL_prev;
    wire btnU_push = btnU_s1 && !btnU_prev;
    wire btnD_push = btnD_s1 && !btnD_prev;
    wire btnR_push = btnR_s1 && !btnR_prev;
    wire btnL_push = btnL_s1 && !btnL_prev;

    always @(posedge clk or posedge btnC) begin
        if (btnC) begin
            {btnU_s0, btnU_s1, btnD_s0, btnD_s1, btnR_s0, btnR_s1, btnL_s0, btnL_s1} <= 8'b0;
            {btnU_prev, btnD_prev, btnR_prev, btnL_prev} <= 4'b0;
        end else begin
            btnU_s0 <= btnU; btnU_s1 <= btnU_s0; btnU_prev <= btnU_s1;
            btnD_s0 <= btnD; btnD_s1 <= btnD_s0; btnD_prev <= btnD_s1;
            btnR_s0 <= btnR; btnR_s1 <= btnR_s0; btnR_prev <= btnR_s1;
            btnL_s0 <= btnL; btnL_s1 <= btnL_s0; btnL_prev <= btnL_s1;
        end
    end

    // Clock Counter logic
    always @(posedge clk or posedge btnC) begin
        if (btnC) begin clk_div <= 0; sec_count <= 0; min_count <= INIT_MIN; hour_count <= INIT_HOUR; end
        else if (tick_1s) begin
            clk_div <= 0;
            if (sec_count == 59) begin
                sec_count <= 0;
                if (min_count == 59) begin
                    min_count <= 0;
                    hour_count <= (hour_count == 23) ? 0 : hour_count + 1;
                end else min_count <= min_count + 1;
            end else sec_count <= sec_count + 1;
        end else clk_div <= clk_div + 1;
    end

    // Programming state routine
    always @(posedge clk or posedge btnC) begin
        if (btnC) begin alarm_hour <= 0; alarm_min <= 0; end
        else if (sw[1]) begin
            if (btnU_push) alarm_hour <= (alarm_hour == 23) ? 0 : alarm_hour + 1;
            if (btnD_push) alarm_hour <= (alarm_hour == 0) ? 23 : alarm_hour - 1;
            if (btnR_push) alarm_min  <= (alarm_min == 59) ? 0 : alarm_min + 1;
            if (btnL_push) alarm_min  <= (alarm_min == 0) ? 59 : alarm_min - 1;
        end
    end

    // Alarm detection and sequence flags
    wire alarm_match = sw[2] && (hour_count == alarm_hour) && (min_count == alarm_min) && (sec_count == 0);
    reg alarm_active = 0;

    always @(posedge clk or posedge btnC) begin
        if (btnC) alarm_active <= 0;
        else if (alarm_match) alarm_active <= 1;
        else if (!sw[0]) alarm_active <= 0; // Turn off immediately when SW0 is turned off
    end

    // Flash/Beep generation timing logic (0.25 second interval for faster alert)
    reg [24:0] alert_div = 0;
    reg alert_state = 0;
    always @(posedge clk) begin
        if (alert_div >= 25'd24_999_999) begin
            alert_div <= 0;
            alert_state <= ~alert_state;
        end else alert_div <= alert_div + 1;
    end

    // Unified dynamic output drivers
    wire state_flash = alarm_active && sw[0] && alert_state;
    
    always @(*) begin
        led = state_flash ? 16'hFFFF : 16'h0000;
        ext_led = state_flash;
    end

    // Dynamic 7-Segment Mapping Multiplexer
    wire [4:0] display_h = sw[1] ? alarm_hour : hour_count;
    wire [5:0] display_m = sw[1] ? alarm_min : min_count;
    reg [18:0] scan_div = 0;
    always @(posedge clk) scan_div <= scan_div + 1;

    reg [3:0] bcd_out;
    always @(*) begin
        if (alarm_active && sw[0] && alert_state) begin
            an = 4'b1111; bcd_out = 0;
        end else begin
            case (scan_div[18:17])
                2'b00: begin an = 4'b1110; bcd_out = display_m % 10; end
                2'b01: begin an = 4'b1101; bcd_out = display_m / 10; end
                2'b10: begin an = 4'b1011; bcd_out = display_h % 10; end
                2'b11: begin an = 4'b0111; bcd_out = display_h / 10; end
            endcase
        end
    end

    always @(*) begin
        case (bcd_out)
            4'd0: seg = 7'b1000000; 4'd1: seg = 7'b1111001; 4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000; 4'd4: seg = 7'b0011001; 4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010; 4'd7: seg = 7'b1111000; 4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000; default: seg = 7'b1111111;
        endcase
    end

    assign dp = 1'b1;

    // Safe instance bridging inside your design tree
    passive_buzzer u_buzzer (
        .clk(clk),
        .sw0(alarm_active && sw[0]), // Plays tone continuously while active and enabled by SW0
        .buzzer(buzzer)
    );

endmodule