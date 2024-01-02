
`define TB_CYCLE        20
`timescale 1ns / 10ps

module Data_bus_buffer_tb;
    reg           chip_select_n;
    reg           read_enable_n;
    reg           write_enable_n;
    reg           address;
    reg   [7:0]   data_bus_in;

    wire   [7:0]   internal_data_bus;
    wire           write_initial_command_word_1;
    wire          write_initial_command_word_2_4;
    wire          write_operation_control_word_1;
    wire          write_operation_control_word_2;
    wire           write_operation_control_word_3;
    wire           read;




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


    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b1;
        read_enable_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Write data
    //
    task TASK_WRITE_DATA(input [1:0] addr, input [7:0] data);
    begin
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = addr;
        data_bus_in     = data;
        #(`TB_CYCLE * 1);
        write_enable_n  = 1'b1;
        chip_select_n   = 1'b1;
        #(`TB_CYCLE * 1);
    end
    endtask


    //
    // Test pattern
    //
    initial begin
        TASK_INIT();

        TASK_WRITE_DATA(1'b0, 8'b00010000);
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        TASK_WRITE_DATA(1'b0, 8'b00000000);
        TASK_WRITE_DATA(1'b0, 8'b00001000);
        #(`TB_CYCLE * 1);
        read_enable_n   = 1'b0;
        chip_select_n   = 1'b0;
        #(`TB_CYCLE * 1);
        read_enable_n   = 1'b1;
        chip_select_n   = 1'b1;
        #(`TB_CYCLE * 1);
        read_enable_n   = 1'b0;
        chip_select_n   = 1'b0;
        #(`TB_CYCLE * 1);
        read_enable_n   = 1'b1;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        #(`TB_CYCLE * 1);
    end
    Data_bus_buffer_Read_write_Logic u_KF8259_Bus_Control_Logic(
    .data_bus_input (data_bus_in),
    .chip_select (chip_select_n),
    .read_enable (read_enable_n),
    .write_enable (write_enable_n),
    .A0           (address),
    .internal_data_bus (internal_data_bus),
    .write_ICW1 (write_initial_command_word_1),
    .write_ICW2_4 (write_initial_command_word_2_4),
    .write_OCW1 (write_operation_control_word_1),
    .write_OCW2 (write_operation_control_word_2),
    .write_OCW3 (write_operation_control_word_3),
    .read  (read)
    );

endmodule




