
`define TB_CYCLE        20
`define TB_FINISH_COUNT 429496729
`timescale 1ns / 10ps
module priority_resolver_TB;

   


    //
    // Generate clock
    //
    reg   clock;
    initial clock = 1'b1;
    always #(`TB_CYCLE / 2) clock = ~clock;



    //
    // Module under test
    //
    //
    reg   [2:0]   priority_rotate;
    reg   [7:0]   interrupt_mask;
    reg   [7:0]   interrupt_special_mask;
    reg           special_fully_nest_config;
    reg   [7:0]   highest_level_in_service;

    reg   [7:0]   interrupt_request_register;
    reg   [7:0]   in_service_register;

    wire   [7:0]   interrupt;

	priority_resolver u_KF8259_Priority_Resolver(
		.priority_rotate                 (priority_rotate),
		.interrupt_mask                  (interrupt_mask),
		.special_fully_nested_config     (special_fully_nest_config),
		.highest_level_in_service        (highest_level_in_service),
		.IRR                             (interrupt_request_register),
		.ISR                             (in_service_register),
		.interrupt                       (interrupt)
										
	);

    //
    // Task : Initialization
    //
    task TASK_INIT;
    begin
        #(`TB_CYCLE * 0);
        priority_rotate            = 3'b111;
        interrupt_mask             = 8'b11111111;
        interrupt_special_mask     = 8'b00000000;
        special_fully_nest_config  = 1'b0;
        highest_level_in_service   = 8'b00000000;
        interrupt_request_register = 8'b00000000;
        in_service_register        = 8'b00000000;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Scan
    //
    task TASK_SCAN_INTERRUPT_REQUEST;
    begin
        #(`TB_CYCLE * 0);
        interrupt_request_register = 8'b10000000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11000000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11100000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11110000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11111000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11111100;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11111110;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11111111;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000000;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : INTERRUPT MASK TEST
    //
    task TASK_INTERRUPT_MASK_TEST;
    begin
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : IN-SERVICE INTERRUPT TEST
    //
    task TASK_IN_SERVICE_INTERRUPT_TEST;
    begin
        interrupt_mask = 8'b00000000;
        #(`TB_CYCLE * 1);

        in_service_register = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00000000;
        #(`TB_CYCLE * 1);
    end
    endtask
