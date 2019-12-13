module PID_Helicopter(
 input wire CLK,             // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire RST_BTN,         // reset button
    output wire VGA_HS_O,       // horizontal sync output
    output wire VGA_VS_O,       // vertical sync output
    output wire [3:0] VGA_R,    // 4-bit VGA red output
    output wire [3:0] VGA_G,    // 4-bit VGA green output
    output wire [3:0] VGA_B,     // 4-bit VGA blue output
	 input up,
	 input down,
	 input heliGo,
	 input gravity,
	 output wire [6:0] seg1,
	 output wire [6:0] seg2,
	 output wire [6:0] seg3
    );

    wire rst = ~RST_BTN;  

    reg [15:0] cnt;
	 reg flagUp;
	 reg flagDown;
    reg pix_stb;
	 reg signed[14:0] line1Y = 15'd240;
	 reg signed[14:0] dy = 15'd450;
	 reg [8:0] dx = 9'd220;
	 reg [8:0] u_prev;
	 reg signed [8:0] e_prev[1:2];
	 trireg signed [14:0] u_out;
	 reg signed [14:0] e_in;
	 reg [26:0] counter = 27'd0;
	 reg th;
	 wire [3:0] height[2:0];
	 
	 parameter p = 8,
				  i = 27,
				  d = 3,
				  k1 = (p * -1) + i + d,
				  k2 = (1 * p) - (2 * d),
	           k3 = d;
	

	 assign u_out = (((k1 *(e_in))/16) - ((k2 * e_prev[1])/16) + ((k3 * e_prev[2])/16));
	 assign height[2] = ((450 - dy) / 100);
	 assign height[1] = (((450 - dy) % 100) / 10);
	 assign height[0] = (((450 - dy) % 10));
	 Seven_Segment hundreds(height[2][3], height[2][2], height[2][1], height[2][0], seg1[0], seg1[1], seg1[2], seg1[3], seg1[4], seg1[5], seg1[6]);
	 Seven_Segment tens(height[1][3], height[1][2], height[1][1], height[1][0], seg2[0], seg2[1], seg2[2], seg2[3], seg2[4], seg2[5], seg2[6]);
	 Seven_Segment ones(height[0][3], height[0][2], height[0][1], height[0][0], seg3[0], seg3[1], seg3[2], seg3[3], seg3[4], seg3[5], seg3[6]);
    always @(posedge CLK)
        {pix_stb, cnt} <= cnt + 16'h8000;  // divide by 4: (2^16)/4 = 0x4000

	 
	 always @(posedge CLK or negedge RST_BTN)
	 begin
		//up
		if (RST_BTN == 1'b0)
		begin
			dy <= 15'd450;
			line1Y <= 15'd240;
			u_prev <= 0;
			e_prev[1] <= 0;
			e_prev[2] <= 0;
			counter <= 27'd0;
			th <= 1'b0;
		end
		
		else
		begin
			
			e_in <= (line1Y - dy - 15'd10);
			u_prev <= dy;
			
			if(th == 1'b1)
			begin
				if (heliGo == 1'b1)
				begin
						e_prev[2] <= e_prev[1];
						e_prev[1] <= e_in;
						if (gravity == 1'b1)
							if ((dy + u_out + 15'd3) > 15'd450)
								dy <= 15'd450;
							else if ((dy + u_out + 15'd3) < 15'd10)
								dy <= 15'd5;
							else
								dy <= dy + u_out + 15'd3;
						else 
							if ((dy + u_out) > 15'd450 && (dy + u_out) < 15'd900)
								dy <= 15'd450;
							else if ((dy + u_out) > 15'd900)
								dy <= 15'd1;
							else
								dy <= dy + u_out;
				end
				else
				begin
					if (gravity == 1'b1)
						if ((dy + 15'd3) < 15'd450)
							dy <= dy + 15'd3;
						else
							dy <= 15'd450;
				end
			end
			if (counter >= 27'd10000000)
			begin
				th <= 1'b1;
				counter <= 27'd0;
			end
			else
			begin	
				counter <= counter + 1;
				th <= 1'b0;
			end
			
			if(up == 1'b0 && flagUp == 1'b0)
			begin
				if(line1Y < 10'd4)
					line1Y <= 10'd1;
				else
					line1Y <= line1Y - 3;
				flagUp <= 1'b1;
			end
			else if (up == 1'b1)
				flagUp <= 1'b0;
				
			if(down == 1'b0 && flagDown == 1'b0)
			begin
				if(line1Y > 10'd443)
					line1Y <= 10'd446;
				else
					line1Y <= line1Y + 3;
				flagDown <= 1'b1;
			end
			else if (down == 1'b1)
				flagDown <= 1'b0;
		end
	 end

    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511

    vga640x480 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .i_rst(rst),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y)
    );

	 wire heliA,heliB,heliC,heliD,heliE,heliF,heliG,heliH,heliI,heliJ,heliK,heli1,heli2,heli3,heli4, heli5,topThreshold, grass;

	assign heliA = ((x > dx) & (y > 19+dy) & (x < 22 + dx) & (y < 22+dy)) ? 1 : 0;
	assign heliB = ((x > 6 + dx) & (y > 15+dy) & (x < 8 + dx) & (y < 21+dy)) ? 1 : 0;
	assign heliC = ((x > 14 + dx) & (y > 15+dy) & (x < 16 + dx) & (y < 21+dy)) ? 1 : 0;
	assign heliD = ((x > 6 + dx) & (y > 6+dy) & (x < 20 + dx) & (y < 17+dy)) ? 1 : 0;
	assign heliE = ((x > 12 + dx) & (y > 9+dy) & (x < 14 + dx) & (y < 12+dy)) ? 1 : 0;
	assign heliF = ((x > dx) & (y > 8+dy) & (x < 8 + dx) & (y < 14+dy)) ? 1 : 0;
	assign heliG = ((x > 3 + dx) & (y > 4+dy) & (x < 8 + dx) & (y < 12+dy)) ? 1 : 0;
	assign heliH = ((x > 3 + dx) & (y > 4+dy) & (x < 30 + dx) & (y< 8+dy)) ? 1 : 0;
	assign heliI = ((x > 11 + dx) & (y > dy) & (x < 15 + dx) & (y < 6+dy)) ? 1 : 0;
	assign heliJ = ((x > 2 + dx) & (y > dy) & (x < 25 + dx) & (y < 2+dy)) ? 1 : 0;
	assign heliK = ((x > dx) & (y > 13+dy) & (x < 8 + dx) & (y < 17+dy)) ? 1 : 0;
	assign heli1 = ((x > 24 + dx) & (y  > 7+dy) & (x < 26 + dx) & (y < 9+dy)) ? 1 : 0;
	assign heli2 = ((x > 26 + dx) & (y > 5+dy) & (x < 28 + dx) & (y < 7+dy)) ? 1 : 0;
	assign heli3 = ((x > 28 + dx) & (y > 3+dy) & (x < 30 + dx) & (y < 5+dy)) ? 1 : 0;
	assign heli4 = ((x > 30 + dx) & (y > 1 +dy) & (x < 32 + dx) & (y < 3+dy)) ? 1 : 0;
	assign heli5 = ((x > 22 + dx) & (y > 9+dy) & (x < 24 + dx) & (y < 11+dy)) ? 1 : 0;
    assign topThreshold = ((x > 0) & (y >  line1Y) & (x < 640) & (y < line1Y + 2)) ? 1 : 0;
	 assign grass = ((x > 0) & (y > 472) & (x < 640) & (y < 480)) ? 1 : 0;

	 
	 assign VGA_R[0] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE| heliA| heliB | heliC | heliD | heliH | heliI | heliK;
	 assign VGA_R[1] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE| heliA| heliB | heliC | heliD | heliH | heliI | heliK;
	 assign VGA_R[2] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE| heliA| heliB | heliC | heliD | heliH | heliI | heliK;
	 assign VGA_R[3] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE| heliA| heliB | heliC | heliD | heliH | heliI | heliK;
	 
	 assign VGA_G[0] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE | grass;
	 assign VGA_G[1] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heli4 | heli5 | heliF | heliG | heliJ | heliE | grass;
	 assign VGA_G[2] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE | grass;
	 assign VGA_G[3] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE | grass;
	 
	 assign VGA_B[0] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE;
	 assign VGA_B[1] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE;
	 assign VGA_B[2] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE;
	 assign VGA_B[3] = topThreshold | heli1 | heli2 | heli3 | heli4 | heli5 | heliF | heliG | heliJ | heliE;
	 

endmodule
