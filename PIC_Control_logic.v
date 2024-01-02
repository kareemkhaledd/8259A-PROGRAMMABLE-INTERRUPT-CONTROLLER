`timescale 1ns / 1ps



module Control_logic(
 input write_ICW1,
 input write_ICW2_4,
 input write_OCW1,
 input write_OCW2,
 input write_OCW3,
 input INTA,
 input wire [7:0] data_bus,
 input [7:0] interrupt, //input coming from the priority resolver
 input [7:0] highest_level_in_service,
 input read,
  );
  
  
    //iitialization commands
    parameter Ready=2'b00,ICW2=2'b01,ICW3=2'b10,ICW4=2'b11;
	// the next two registers are uesd for the initialization command words sequence 
    reg [1:0] next_command;
    reg [1:0] current_command;
    reg single_or_cascade_flag; //flag for single or cascade mode
    
	reg icw4_needed_flag; //flag to determine if ICW4 is going to be used or not
	reg call_address_interval_4_or_8_flag; // flag for the used interval (not used in 8086)
	
	reg buffered_mode_config ;
	reg buffered_master_or_slave_config;
	reg is_Slave;//1->Slave    0->Master
	reg slave_enabled;
	reg cascade_output_ack2;
	
	//this is a finite state machine to configure the sequence of Initialization command words
    always@* begin
        if(write_ICW1==1)begin //first check if the coming input is ICW1
        next_command=ICW2; //next initialization command word will be ICW2
        end
		//if the current command word is ICW2,ICW3,ICW4
		//start determining the next command word 
        else if(write_ICW2_4==1) begin 
            case(current_command)
			//after getting ICW2, check if we are using single or cascade mode
			// if using cascade mode then the next command word is ICW3
			//if in single mode then check if ICW4 is needed or not
                ICW2:begin
                    if(single_or_cascade_flag==0)begin
					next_command=ICW3;
					end
					else if(icw4_needed_flag==1)begin
					next_command=ICW4;
					end
					else 
					next_command=Ready;
                end
				//after getting ICW3 check if ICW4 is needed or not
				ICW3:begin
					if(icw4_needed_flag==1)
						next_command=ICW4;
					else
						next_command=Ready;
				end
				//after getting ICW4 set the next_command to be ready
				ICW4: begin
					next_command=Ready;
				end
				//default ready case used to avoid any latches
				default: begin
					next_command=Ready;
				end
            endcase
        end
		else
			next_command=current_command;
    end
	
	//update the current command with every clock cycle
	always@(*) begin
			current_command<=next_command;
	end
	//signals for initilization commands
	wire write_ICW2=(current_command == ICW2) & write_ICW2_4;
	wire write_ICW3=(current_command == ICW3) & write_ICW2_4;
	wire write_ICW4=(current_command == ICW4) & write_ICW2_4;
	
	//signals for operation command words		
	wire write_OCW1_register = (current_command==Ready) & write_OCW1;
	wire write_OCW2_register = (current_command==Ready) & write_OCW2;
	wire write_OCW3_register = (current_command==Ready) & write_OCW3;
	
	 // Service control state
	 
	 reg [1:0] next_control_s;
	 reg [1:0] control_s;
	 parameter Control_Ready=2'b00,ACK1=2'b01,ACK2=2'b10,POLL=2'b11;
	 //Acknowledge edge detection
	 
	 reg prev_INTA;
	 
	always@(INTA,prev_INTA)begin
		prev_INTA<=INTA;
	end
	
	wire negative_edge_INTA= prev_INTA & ~INTA;
	wire positive_edge_INTA=~ prev_INTA& INTA;
	
	
	//Detect read signal edge
	reg prev_read_signal;
	
	always@( read, prev_read_signal) begin
		prev_read_signal<= read;
	end
	
	wire negative_edge_read= prev_read_signal & ~read;
	
	//state machine for operation control words
	always@* begin
		case(control_s)
			Control_Ready:begin
				if((write_OCW3_register==1'b1)&&(data_bus[2]==1'b1))
					next_control_s=POLL;
				else if (write_OCW2_register==1'b1)
					next_control_s=Control_Ready;
				else if(negative_edge_INTA==1'b0)
					next_control_s=Control_Ready;
				else
					next_control_s=ACK1;
			end
			ACK1:begin
				if(positive_edge_INTA==1'b0)
					next_control_s=ACK1;
				else
					next_control_s=ACK2;
			end
			
			ACK2:begin
				if(positive_edge_INTA==1'b0)
					next_control_s=ACK2;
				else
					next_control_s=Control_Ready;
			end
			POLL:begin
				if(negative_edge_read==1'b0)
					next_control_s=POLL;
				else
					next_control_s=Control_Ready;
			end
			
			default:begin
				next_control_s=Control_Ready;
				
			end
		endcase
	end
	
	always @(write_ICW1,next_control_s)begin
		if(write_ICW1==1'b1)
			control_s<=Control_Ready;
		else
			control_s<=next_control_s;
	end
	

	//latch_ISR signal
	always@* begin
		if(write_ICW1==1'b1)
			latch_ISR = 1'b0;
		else if((control_s==Control_Ready)&&(next_control_s==POLL))
			latch_ISR = 1'b1;
		else if(is_Slave==1'b0)
			latch_ISR = (control_s==Control_Ready) & (next_control_s != Control_Ready);
		else 
			latch_ISR = (control_s == ACK2) & (slave_enabled == 1'b1) & (negative_edge_INTA==1'b1);
	end
	
	wire acknowledge_end = (control_s!=POLL)&(control_s!= Control_Ready)&(next_control_s==Control_Ready);
	wire poll_end        = (control_s==POLL)&(control_s != Control_Ready) &(next_control_s==Control_Ready);
	
		
	
	//
    // Initialization command word 1
    // A7-A5
	
	reg [10:0]  interrupt_vector_address;
	always@(write_ICW1)begin
		if(write_ICW1==1)
			interrupt_vector_address[2:0]<= data_bus[7:5];
		else
			interrupt_vector_address[2:0]<= interrupt_vector_address[2:0];
	end
	//IC4 bit
	always@(write_ICW1) begin
		if(write_ICW1==1)
			icw4_needed_flag<=data_bus[0];
		else
			icw4_needed_flag<=icw4_needed_flag;
		end
	//SNGL bit
	always@(write_ICW1) begin
	if(write_ICW1==1)
		single_or_cascade_flag<=data_bus[1];
	else
		single_or_cascade_flag<=single_or_cascade_flag;
	end
	//ADI bit
	always@(write_ICW1) begin
		if(write_ICW1==1)
			call_address_interval_4_or_8_flag<=data_bus[2];
		else
			call_address_interval_4_or_8_flag<=call_address_interval_4_or_8_flag;
	end
	//LTIM bit
	always@(write_ICW1) begin
		if(write_ICW1==1)
			level_or_edge_triggered_flag<=data_bus[3];
		else
			level_or_edge_triggered_flag<=level_or_edge_triggered_flag;
	end
