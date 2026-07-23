//GPIO registers
module GPIO_registers(sys_clk,sys_rst,gpio_we,gpio_addr,gpio_dat_i,gpio_dat_o,gpio_inta_o,aux_in,out_pad_o,oen_padoe_o,in_pad_i,gpio_eclk);

	input sys_clk;
	input sys_rst;
	input gpio_we;
	input [31:0]gpio_addr;
	input [31:0]gpio_dat_i;
	output reg [31:0]gpio_dat_o;
	output gpio_inta_o;
	input [31:0]aux_in;
	output [31:0]out_pad_o;
	output [31:0]oen_padoe_o;
	input [31:0]in_pad_i;
	input gpio_eclk;
	
	wire [31:0]sel_clk;
	reg [31:0]RGPIO_IN,RGPIO_OUT,RGPIO_OE,RGPIO_INTE,RGPIO_PTRIG,RGPIO_AUX,RGPIO_INTS,RGPIO_ECLK,RGPIO_NEC;
	reg [1:0]RGPIO_CTRL;

	assign oen_padoe_o = RGPIO_OE;
	assign gpio_inta_o = |RGPIO_INTS;
	genvar i;
	generate
		for(i = 0; i <= 31; i=i+1) begin : multiplexing_out
			assign out_pad_o[i] = RGPIO_AUX[i] ? aux_in[i] : RGPIO_OUT[i];	
		//updating RGPIO_IN
		always@(posedge sys_clk) begin
			if(RGPIO_ECLK[i]) begin : update_at_eclk 
				if(RGPIO_NEC[i] == 1'b1) begin
					if(gpio_eclk == 1'b0)
						RGPIO_IN[i] <= in_pad_i[i];
				end
				else if(RGPIO_NEC[i] == 1'b0) begin
					if(gpio_eclk == 1'b1)
						RGPIO_IN[i] <= in_pad_i[i];
				end
			end
			else begin
				RGPIO_IN[i] <= in_pad_i[i];
			end
		end

		always@(posedge sys_clk) begin
			if(RGPIO_CTRL[0] == 1'b1) begin
				if(RGPIO_INTE[i] == 1'b1) begin
					if(RGPIO_PTRIG[i] == 1'b1) begin
						if(in_pad_i[i]==1'b1 && RGPIO_IN[i]==1'b0)
						RGPIO_INTS[i] <= 1'b1;
					end 
					else if(RGPIO_PTRIG[i] == 1'b0) begin
						if(in_pad_i[i]==1'b0 && RGPIO_IN[i]==1'b1)
						RGPIO_INTS[i] <= 1'b1;
					end
				end	
			end
		end
	end 
	endgenerate

	//Read-Write acess for APB Master
	always@(posedge sys_clk or negedge sys_rst) begin
		if(!sys_rst) begin
			RGPIO_IN <= 32'd0;
			RGPIO_OUT <= 32'd0;
			RGPIO_OE <= 32'd0;
			RGPIO_INTE <= 32'd0;
			RGPIO_PTRIG <= 32'd0;
			RGPIO_AUX <= 32'd0;
			RGPIO_CTRL <= 2'd0;
			RGPIO_INTS <= 32'd0;
			RGPIO_ECLK <= 32'd0;
			RGPIO_NEC <= 32'd0;
		end
		else if(gpio_we)	
			case(gpio_addr)
				32'h4 : RGPIO_OUT <= gpio_dat_i;
				32'h8 : RGPIO_OE <= gpio_dat_i;
				32'hc : RGPIO_INTE <= gpio_dat_i;
				32'h10 : RGPIO_PTRIG <= gpio_dat_i;
				32'h14 : RGPIO_AUX <= gpio_dat_i;
				32'h18 : RGPIO_CTRL <= gpio_dat_i;
				32'h1c : RGPIO_INTS <= gpio_dat_i;
				32'h20 : RGPIO_ECLK <= gpio_dat_i;
				32'h24 : RGPIO_NEC <= gpio_dat_i;
			endcase
		else
			case(gpio_addr)
				32'h0 : gpio_dat_o <= RGPIO_IN;
				32'h4 : gpio_dat_o <= RGPIO_OUT;
				32'h8 :  gpio_dat_o <= RGPIO_OE;
				32'hc : gpio_dat_o <= RGPIO_INTE;
				32'h10 : gpio_dat_o <= RGPIO_PTRIG;
				32'h14 : gpio_dat_o <= RGPIO_AUX;
				32'h18 : gpio_dat_o <= RGPIO_CTRL;
				32'h1c : gpio_dat_o <= RGPIO_INTS;
				32'h20 : gpio_dat_o <= RGPIO_ECLK;
				32'h24 : gpio_dat_o <= RGPIO_NEC;
			endcase	
	end	
endmodule						RGPIO_IN[i] <= in_pad_i[i];
				end
			end
			else begin
				RGPIO_IN[i] <= in_pad_i[i];
			end
		end

		always@(posedge sys_clk) begin
			if(RGPIO_CTRL[0] == 1'b1) begin
				if(RGPIO_INTE[i] == 1'b1)
					if(RGPIO_PTRIG[i] == 1'b1) begin
						if(in_pad_i[i]==1'b1 && RGPIO_IN[i]==1'b0)
							RGPIO_INTS[i] <= 1'b1;
					end
					else if(RGPIO_PTRIG[i] == 1'b0) begin
						if(in_pad_i[i]==1'b0 && RGPIO_IN[i]==1'b1)
							RGPIO_INTS[i] <= 1'b1;
					end	
			end
			else
				RGPIO_INTS[i] <= 1'b0;
		end
	end 
	endgenerate

	//Read-Write acess for APB Master
	always@(posedge sys_clk or negedge sys_rst) begin
		if(!sys_rst) begin
			RGPIO_OUT <= 32'd0;
			RGPIO_OE <= 32'd0;
			RGPIO_INTE <= 32'd0;
			RGPIO_PTRIG <= 32'd0;
			RGPIO_AUX <= 32'd0;
			RGPIO_CTRL <= 2'd0;
			RGPIO_INTS <= 32'd0;
			RGPIO_ECLK <= 32'd0;
			RGPIO_NEC <= 32'd0;
		end
		else if(gpio_we)	
			case(gpio_addr)
				32'h4 : RGPIO_OUT <= gpio_dat_i;
				32'h8 : RGPIO_OE <= gpio_dat_i;
				32'hc : RGPIO_INTE <= gpio_dat_i;
				32'h10 : RGPIO_PTRIG <= gpio_dat_i;
				32'h14 : RGPIO_AUX <= gpio_dat_i;
				32'h18 : RGPIO_CTRL <= gpio_dat_i;
				32'h1c : RGPIO_INTS <= gpio_dat_i;
				32'h20 : RGPIO_ECLK <= gpio_dat_i;
				32'h24 : RGPIO_NEC <= gpio_dat_i;
			endcase
		else
			case(gpio_addr)
				32'h0 : gpio_dat_o <= RGPIO_IN;
				32'h4 : gpio_dat_o <= RGPIO_OUT;
				32'h8 :  gpio_dat_o <= RGPIO_OE;
				32'hc : gpio_dat_o <= RGPIO_INTE;
				32'h10 : gpio_dat_o <= RGPIO_PTRIG;
				32'h14 : gpio_dat_o <= RGPIO_AUX;
				32'h18 : gpio_dat_o <= RGPIO_CTRL;
				32'h1c : gpio_dat_o <= RGPIO_INTS;
				32'h20 : gpio_dat_o <= RGPIO_ECLK;
				32'h24 : gpio_dat_o <= RGPIO_NEC;
			endcase	
	end	
endmodule
