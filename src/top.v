`timescale 1ns / 1ps

module basys3_24h_alarm_clock (
    input clk,
    input btnC, btnU, btnD, btnR, btnL,
    input [3:0] sw, // sw[0]: Alarm Arm, sw[1]: Alarm Set, sw[2]: Alarm Play Gate, sw[3]: Clock Set
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp,
    output buzzer,
    output ext_led
);
    // 1-Second and 1-Minute Hardware Timebase Generators
    reg [26:0] clk_div = 0;
    reg [5:0] sec_count = 0;
    wire tick_1s = (clk_div == 27'd99_999_999);
    reg tick_1m = 0;

    always @(posedge clk or posedge btnC) begin
        if (btnC) begin
            clk_div    <= 0;
            sec_count  <= 0;
            tick_1m    <= 0;
        end else begin
            tick_1m <= 0;
            if (tick_1s) begin
                clk_div <= 0;
                if (sec_count == 59) begin
                    sec_count <= 0;
                    tick_1m   <= 1'b1; // Fires clock logic sequence forward
                end else begin
                    sec_count <= sec_count + 1'b1;
                end
            end else begin
                clk_div <= clk_div + 1'b1;
            end
        end
    end

    // Clean edge-triggered button pulses
    wire p_U, p_D, p_R, p_L;
    btn_pulse pulse_U (clk, btnC, btnU, p_U);
    btn_pulse pulse_D (clk, btnC, btnD, p_D);
    btn_pulse pulse_R (clk, btnC, btnR, p_R);
    btn_pulse pulse_L (clk, btnC, btnL, p_L);

    // Active Time Keeping Registers (Instance 1)
    wire [4:0] clock_hour; wire [5:0] clock_min;
    time_reg real_time_inst (
        .clk(clk), .rst(btnC),
        .tick_1m(tick_1m && !sw[3]), // Freeze auto-increment during direct user adjustments
        .set_mode(sw[3]),
        .btnU(p_U), .btnD(p_D), .btnR(p_R), .btnL(p_L),
        .hour(clock_hour), .min(clock_min)
    );

    // Alarm Target Programming Registers (Instance 2)
    wire [4:0] alarm_hour; wire [5:0] alarm_min;
    time_reg alarm_time_inst (
        .clk(clk), .rst(btnC),
        .tick_1m(1'b0), // Alarm registers do not auto-increment
        .set_mode(sw[1] && !sw[3]), // Prevent overlapping programming states
        .btnU(p_U), .btnD(p_D), .btnR(p_R), .btnL(p_L),
        .hour(alarm_hour), .min(alarm_min)
    );

    // Multiplex Display Target Value Mapping
    wire [4:0] disp_hour = sw[1] ? alarm_hour : clock_hour;
    wire [5:0] disp_min  = sw[1] ? alarm_min  : clock_min;

    // Alarm Logic Processing Circuitry
    wire alarm_match = sw[0] && (clock_hour == alarm_hour) && (clock_min == alarm_min) && (sec_count == 0);
    reg alarm_active = 0;

    always @(posedge clk or posedge btnC) begin
        if (btnC)           alarm_active <= 1'b0;
        else if (alarm_match) alarm_active <= 1'b1;
        else if (!sw[0])    alarm_active <= 1'b0;
    end

    // Flash Indicators on Trigger
    reg [22:0] flash_div = 0;
    always @(posedge clk) flash_div <= flash_div + 1'b1;
    wire alert_state = alarm_active && flash_div[22];

    assign led     = sw[1] ? 16'hF0F0 : (sw[3] ? 16'h0F0F : (alert_state ? 16'hFFFF : 16'h0000));
    assign ext_led = alert_state;
    assign dp      = 1'b1;

    // Output Displays
    seven_seg_mux main_display (
        .clk(clk),
        .hour(disp_hour),
        .min(disp_min),
        .blank(alert_state),
        .an(an),
        .seg(seg)
    );

    // Audio Buzzer Driver Integration Channel
    passive_buzzer alert_buzzer (
        .clk(clk),
        .sw0(sw[2] && alarm_active),
        .buzzer(buzzer)
    );

endmodule