`timescale 1ns / 1ps

module passive_buzzer (
    input clk,            // 100 MHz Basys 3 Clock
    input sw0,            // Switch 0 playback gate control
    output reg buzzer     // Connect to Pmod pin J1
);

    // --- Audio Tone Divider Logic ---
    reg [17:0] target_pitch = 18'd0;
    reg [17:0] pitch_count = 18'd0;

    always @(posedge clk) begin
        if (!sw0 || target_pitch == 18'd0) begin
            pitch_count <= 18'd0;
            buzzer <= 1'b0;
        end else begin
            if (pitch_count >= target_pitch) begin
                pitch_count <= 18'd0;
                buzzer <= ~buzzer; // Toggle pin to produce square wave
            end else begin
                pitch_count <= pitch_count + 1'b1;
            end
        end
    end

    // --- Sequencer State Machine Configuration ---
    reg [7:0]  note_index = 8'd0;
    reg [27:0] duration_count = 27'd0;
    
    reg [17:0] current_pitch_limit;
    reg [4:0]  current_duration_val; // Contains the note divisor value directly

    // --- Timing Engine Mathematics ---
    // Standard whole note baseline matched to the new rhythm sequence
    localparam [27:0] WHOLENOTE_CYCLES = 27'd400_000_000;

    // Base division: Note length = WHOLENOTE_CYCLES / divisor
    wire [27:0] active_cycles = (current_duration_val != 0) ? 
                                 (WHOLENOTE_CYCLES / current_duration_val) : 27'd0;

    // 30% structural pause between notes as defined in the Arduino blueprint (pauseBetweenNotes = noteDuration * 1.30)
    wire [27:0] total_cycles = active_cycles + ((active_cycles * 3) / 10);


    // --- Complete Look-Up Melody Array ---
    always @(*) begin
        case(note_index)
            // =================================================================
            // PART 1: MARIO MAIN OVERWORLD THEME
            // =================================================================
            8'd0:  begin current_pitch_limit = 18'd37922;  current_duration_val = 5'd12; end // NOTE_E7
            8'd1:  begin current_pitch_limit = 18'd37922;  current_duration_val = 5'd12; end // NOTE_E7
            8'd2:  begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd3:  begin current_pitch_limit = 18'd37922;  current_duration_val = 5'd12; end // NOTE_E7
            8'd4:  begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd5:  begin current_pitch_limit = 18'd47779;  current_duration_val = 5'd12; end // NOTE_C7
            8'd6:  begin current_pitch_limit = 18'd37922;  current_duration_val = 5'd12; end // NOTE_E7
            8'd7:  begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd8:  begin current_pitch_limit = 18'd31888;  current_duration_val = 5'd12; end // NOTE_G7
            8'd9:  begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd10: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd11: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd12: begin current_pitch_limit = 18'd63776;  current_duration_val = 5'd12; end // NOTE_G6
            8'd13: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd14: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd15: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)

            8'd16: begin current_pitch_limit = 18'd47779;  current_duration_val = 5'd12; end // NOTE_C7
            8'd17: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd18: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd19: begin current_pitch_limit = 18'd63776;  current_duration_val = 5'd12; end // NOTE_G6
            8'd20: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd21: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd22: begin current_pitch_limit = 18'd75815;  current_duration_val = 5'd12; end // NOTE_E6
            8'd23: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd24: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd25: begin current_pitch_limit = 18'd56818;  current_duration_val = 5'd12; end // NOTE_A6
            8'd26: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd27: begin current_pitch_limit = 18'd50607;  current_duration_val = 5'd12; end // NOTE_B6
            8'd28: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd29: begin current_pitch_limit = 18'd53619;  current_duration_val = 5'd12; end // NOTE_AS6
            8'd30: begin current_pitch_limit = 18'd56818;  current_duration_val = 5'd12; end // NOTE_A6
            8'd31: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)

            8'd32: begin current_pitch_limit = 18'd63776;  current_duration_val = 5'd9;  end // NOTE_G6
            8'd33: begin current_pitch_limit = 18'd37922;  current_duration_val = 5'd9;  end // NOTE_E7
            8'd34: begin current_pitch_limit = 18'd31888;  current_duration_val = 5'd9;  end // NOTE_G7
            8'd35: begin current_pitch_limit = 18'd28409;  current_duration_val = 5'd12; end // NOTE_A7
            8'd36: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd37: begin current_pitch_limit = 18'd35791;  current_duration_val = 5'd12; end // NOTE_F7
            8'd38: begin current_pitch_limit = 18'd31888;  current_duration_val = 5'd12; end // NOTE_G7
            8'd39: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd40: begin current_pitch_limit = 18'd37922;  current_duration_val = 5'd12; end // NOTE_E7
            8'd41: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd42: begin current_pitch_limit = 18'd47779;  current_duration_val = 5'd12; end // NOTE_C7
            8'd43: begin current_pitch_limit = 18'd42571;  current_duration_val = 5'd12; end // NOTE_D7
            8'd44: begin current_pitch_limit = 18'd50607;  current_duration_val = 5'd12; end // NOTE_B6
            8'd45: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd46: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)

            // Repeat of the Overworld melody chunk
            8'd47: begin current_pitch_limit = 18'd47779;  current_duration_val = 5'd12; end // NOTE_C7
            8'd48: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd49: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd50: begin current_pitch_limit = 18'd63776;  current_duration_val = 5'd12; end // NOTE_G6
            8'd51: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd52: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd53: begin current_pitch_limit = 18'd75815;  current_duration_val = 5'd12; end // NOTE_E6
            8'd54: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd55: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd56: begin current_pitch_limit = 18'd56818;  current_duration_val = 5'd12; end // NOTE_A6
            8'd57: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd58: begin current_pitch_limit = 18'd50607;  current_duration_val = 5'd12; end // NOTE_B6
            8'd59: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd60: begin current_pitch_limit = 18'd53619;  current_duration_val = 5'd12; end // NOTE_AS6
            8'd61: begin current_pitch_limit = 18'd56818;  current_duration_val = 5'd12; end // NOTE_A6
            8'd62: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)

            8'd63: begin current_pitch_limit = 18'd63776;  current_duration_val = 5'd9;  end // NOTE_G6
            8'd64: begin current_pitch_limit = 18'd37922;  current_duration_val = 5'd9;  end // NOTE_E7
            8'd65: begin current_pitch_limit = 18'd31888;  current_duration_val = 5'd9;  end // NOTE_G7
            8'd66: begin current_pitch_limit = 18'd28409;  current_duration_val = 5'd12; end // NOTE_A7
            8'd67: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd68: begin current_pitch_limit = 18'd35791;  current_duration_val = 5'd12; end // NOTE_F7
            8'd69: begin current_pitch_limit = 18'd31888;  current_duration_val = 5'd12; end // NOTE_G7
            8'd70: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd71: begin current_pitch_limit = 18'd37922;  current_duration_val = 5'd12; end // NOTE_E7
            8'd72: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd73: begin current_pitch_limit = 18'd47779;  current_duration_val = 5'd12; end // NOTE_C7
            8'd74: begin current_pitch_limit = 18'd42571;  current_duration_val = 5'd12; end // NOTE_D7
            8'd75: begin current_pitch_limit = 18'd50607;  current_duration_val = 5'd12; end // NOTE_B6
            8'd76: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)
            8'd77: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd12; end // 0 (Rest)

            // =================================================================
            // PART 2: MARIO UNDERWORLD THEME
            // =================================================================
            8'd78: begin current_pitch_limit = 18'd190839; current_duration_val = 5'd12; end // NOTE_C4
            8'd79: begin current_pitch_limit = 18'd95602;  current_duration_val = 5'd12; end // NOTE_C5
            8'd80: begin current_pitch_limit = 18'd227272; current_duration_val = 5'd12; end // NOTE_A3
            8'd81: begin current_pitch_limit = 18'd113636; current_duration_val = 5'd12; end // NOTE_A4
            8'd82: begin current_pitch_limit = 18'd214592; current_duration_val = 5'd12; end // NOTE_AS3
            8'd83: begin current_pitch_limit = 18'd107296; current_duration_val = 5'd12; end // NOTE_AS4
            8'd84: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd6;  end // 0 (Rest)
            8'd85: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd3;  end // 0 (Rest)

            8'd86: begin current_pitch_limit = 18'd190839; current_duration_val = 5'd12; end // NOTE_C4
            8'd87: begin current_pitch_limit = 18'd95602;  current_duration_val = 5'd12; end // NOTE_C5
            8'd88: begin current_pitch_limit = 18'd227272; current_duration_val = 5'd12; end // NOTE_A3
            8'd89: begin current_pitch_limit = 18'd113636; current_duration_val = 5'd12; end // NOTE_A4
            9'd90: begin current_pitch_limit = 18'd214592; current_duration_val = 5'd12; end // NOTE_AS3
            8'd91: begin current_pitch_limit = 18'd107296; current_duration_val = 5'd12; end // NOTE_AS4
            8'd92: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd6;  end // 0 (Rest)
            8'd93: begin current_pitch_limit = 18'd0;      current_duration_val = 5'd3;  end // 0 (Rest)

            8'd94: begin current_pitch_limit = 18'd285714; current_duration_val = 5'd12; end // NOTE_F3
            8'd95: begin current_pitch_limit = 18'd143266; current_duration_val = 5'd12; end // NOTE_F4
            8'd96: begin current_pitch_limit = 18'd340136; current_duration_val = 5'd12; end // NOTE_D3
            8'd97: begin current_pitch_limit = 18'd170068; current_duration_val = 5'd12; end // NOTE_D4
            8'd98: begin current_pitch_limit = 18'd321543; current_duration_val = 5'd12; end // NOTE_DS3
            8'd99: begin current_pitch_limit = 18'd160771; current_duration_val = 5'd12; end // NOTE_DS4
            8'd100:begin current_pitch_limit = 18'd0;      current_duration_val = 5'd6;  end // 0 (Rest)
            8'd101:begin current_pitch_limit = 18'd0;      current_duration_val = 5'd3;  end // 0 (Rest)

            8'd102:begin current_pitch_limit = 18'd285714; current_duration_val = 5'd12; end // NOTE_F3
            8'd103:begin current_pitch_limit = 18'd143266; current_duration_val = 5'd12; end // NOTE_F4
            8'd104:begin current_pitch_limit = 18'd340136; current_duration_val = 5'd12; end // NOTE_D3
            8'd105:begin current_pitch_limit = 18'd170068; current_duration_val = 5'd12; end // NOTE_D4
            8'd106:begin current_pitch_limit = 18'd321543; current_duration_val = 5'd12; end // NOTE_DS3
            8'd107:begin current_pitch_limit = 18'd160771; current_duration_val = 5'd12; end // NOTE_DS4
            8'd108:begin current_pitch_limit = 18'd0;      current_duration_val = 5'd6;  end // 0 (Rest)
            
            8'd109:begin current_pitch_limit = 18'd160771; current_duration_val = 5'd6;  end // NOTE_DS4
            8'd110:begin current_pitch_limit = 18'd180505; current_duration_val = 5'd18; end // NOTE_CS4
            8'd111:begin current_pitch_limit = 18'd170068; current_duration_val = 5'd18; end // NOTE_D4
            8'd112:begin current_pitch_limit = 18'd180505; current_duration_val = 5'd18; end // NOTE_CS4
            8'd113:begin current_pitch_limit = 18'd160771; current_duration_val = 5'd6;  end // NOTE_DS4
            8'd114:begin current_pitch_limit = 18'd160771; current_duration_val = 5'd6;  end // NOTE_DS4
            8'd115:begin current_pitch_limit = 18'd240384; current_duration_val = 5'd6;  end // NOTE_GS3
            8'd116:begin current_pitch_limit = 18'd255102; current_duration_val = 5'd6;  end // NOTE_G3
            8'd117:begin current_pitch_limit = 18'd180505; current_duration_val = 5'd6;  end // NOTE_CS4

            8'd118:begin current_pitch_limit = 18'd190839; current_duration_val = 5'd18; end // NOTE_C4
            8'd119:begin current_pitch_limit = 18'd135135; current_duration_val = 5'd18; end // NOTE_FS4
            8'd120:begin current_pitch_limit = 18'd143266; current_duration_val = 5'd18; end // NOTE_F4
            8'd121:begin current_pitch_limit = 18'd303030; current_duration_val = 5'd18; end // NOTE_E3
            8'd122:begin current_pitch_limit = 18'd107296; current_duration_val = 5'd18; end // NOTE_AS4
            8'd123:begin current_pitch_limit = 18'd113636; current_duration_val = 5'd18; end // NOTE_A4
            
            8'd124:begin current_pitch_limit = 18'd120481; current_duration_val = 5'd10; end // NOTE_GS4
            8'd125:begin current_pitch_limit = 18'd160771; current_duration_val = 5'd10; end // NOTE_DS4
            8'd126:begin current_pitch_limit = 18'd202429; current_duration_val = 5'd10; end // NOTE_B3
            8'd127:begin current_pitch_limit = 18'd214592; current_duration_val = 5'd10; end // NOTE_AS3
            8'd128:begin current_pitch_limit = 18'd227272; current_duration_val = 5'd10; end // NOTE_A3
            8'd129:begin current_pitch_limit = 18'd240384; current_duration_val = 5'd10; end // NOTE_GS3
            
            8'd130:begin current_pitch_limit = 18'd0;      current_duration_val = 5'd3;  end // 0 (Rest)
            8'd131:begin current_pitch_limit = 18'd0;      current_duration_val = 5'd3;  end // 0 (Rest)
            8'd132:begin current_pitch_limit = 18'd0;      current_duration_val = 5'd3;  end // 0 (Rest)

            default: begin current_pitch_limit = 18'd0;    current_duration_val = 5'd12; end
        endcase
    end

    // --- Sequential Cycle Tracking Machine ---
    always @(posedge clk) begin
        if (!sw0) begin
            note_index     <= 8'd0;
            duration_count <= 27'd0;
            target_pitch   <= 18'd0;
        end else begin
            if (duration_count >= total_cycles) begin
                duration_count <= 27'd0;
                if (note_index >= 8'd132) begin
                    note_index <= 8'd0; // Loop full medley track sequence
                end else begin
                    note_index <= note_index + 1'b1;
                end
            end else begin
                duration_count <= duration_count + 1'b1;
                
                // Active tone gate window tracker
                if (duration_count < active_cycles) begin
                    target_pitch <= current_pitch_limit;
                end else begin
                    target_pitch <= 18'd0; // Structural clean envelope separator spacing
                end
            end
        end
    end

endmodule