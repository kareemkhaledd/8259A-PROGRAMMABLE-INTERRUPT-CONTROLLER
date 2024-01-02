module priority_resolver(
    input [2:0] priority_rotate,
    input       special_fully_nested_config,
    input [7:0] highest_level_in_service,


    input [7:0] IRR,
    input [7:0] ISR,

    output reg [7:0] interrupt

);
	
	
	reg [7:0] rotated_IRR;
    reg [7:0] rotated_ISR;
    reg [7:0] rotated_highest_level_in_service;
    reg [7:0] priority_mask;
    reg [7:0] rotated_interrupt;
	
	always@* begin
		rotated_IRR = rotate_right(masked_IRR,priority_rotate);
		rotated_highest_level_in_service = rotate_right(highest_level_in_service,priority_rotate);
		rotated_ISR = rotate_right(ISR,priority_rotate);
	
	end
	
	
	always@* begin
        if      (rotated_ISR[0] == 1'b1) priority_mask = 8'b00000000;
        else if (rotated_ISR[1] == 1'b1) priority_mask = 8'b00000001;
        else if (rotated_ISR[2] == 1'b1) priority_mask = 8'b00000011;
        else if (rotated_ISR[3] == 1'b1) priority_mask = 8'b00000111;
        else if (rotated_ISR[4] == 1'b1) priority_mask = 8'b00001111;
        else if (rotated_ISR[5] == 1'b1) priority_mask = 8'b00011111;
        else if (rotated_ISR[6] == 1'b1) priority_mask = 8'b00111111;
        else if (rotated_ISR[7] == 1'b1) priority_mask = 8'b01111111;
        else                             priority_mask = 8'b11111111;
    end
	
	
	
	always@* begin
		rotated_interrupt = resolv_priority(rotated_IRR) & priority_mask;
		interrupt = rotate_left(rotated_interrupt,priority_rotate);
	end

