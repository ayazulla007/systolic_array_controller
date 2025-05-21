// ----------------------------------------------------
// Module : systolic_array_controller_tb 
// TB_TOP
// Author :         Ayazulla Khan
// ----------------------------------------------------
/**
 * Systolic Array Controller Testbench
 *
 * This testbench verifies the functionality of the systolic array controller
 * by simulating multiple matrix multiplication scenarios.
 */
`timescale 1ns / 1ps

module systolic_array_controller_tb ();

 parameter CLOCK_PERIOD = 10;  // 10 ns (100 MHz)


    // Testbench signals
    logic clk;                 // Clock signal
    logic rst_n;               // Active low reset
    // Matrix A inputs
    logic [3:0] a11;
    logic [3:0] a12;
    logic [3:0] a21;
    logic [3:0] a22;
    // Matrix B inputs
    logic [3:0] b11;
    logic [3:0] b12;
    logic [3:0] b21;
    logic [3:0] b22;
    logic in_valid;            // Input valid signal
    // Result matrix outputs
    logic [8:0] c11;
    logic [8:0] c12;
    logic [8:0] c21;
    logic [8:0] c22;
    logic out_valid;           // Output valid signal

/**
 * Device Under Test (DUT)
 * Instantiate the systolic array controller
 */
systolic_array_controller i_systolic_array_controller (
    .clk      (clk      ),
    .rst_n    (rst_n    ),
    .a11      (a11      ),
    .a12      (a12      ),
    .a21      (a21      ),
    .a22      (a22      ),
    .b11      (b11      ),
    .b12      (b12      ),
    .b21      (b21      ),
    .b22      (b22      ),
    .in_valid (in_valid ),
    .c11      (c11      ),
    .c12      (c12      ),
    .c21      (c21      ),
    .c22      (c22      ),
    .out_valid(out_valid)
);

    /**
     * Clock Generation
     * Generates a clock with the specified period
     */
    always begin
        #(CLOCK_PERIOD/2) clk = ~clk;
    end

    /**
     * Test Procedure
     * Executes test cases for matrix multiplication
     */
    initial begin
        // Initialize signals
        clk = '0;
        rst_n = 1'b0;
        a11 = '0;
        a12 = '0;
        a21 = '0;
        a22 = '0;
        b11 = '0;
        b12 = '0;
        b21 = '0;
        b22 = '0;
        in_valid = '0;
        
        // Release reset
        #(CLOCK_PERIOD*2) rst_n = 1'b1;


        //////////////////////////////////////// Matrix multiplication example 1: ////////////////////////////////
        // A = [1 2]    B = [5 6]
        //     [3 4]        [7 8]
        // Expected result = [19 22]
        //                   [43 50]
        
        // Step 1: First elements enter and set input in_valid
        #(CLOCK_PERIOD*2);
        a11 = 4'd1;
        a12 = 4'd2;
        a21 = 4'd3;
        a22 = 4'd4;
        b11 = 4'd5;
        b12 = 4'd6;
        b21 = 4'd7;
        b22 = 4'd8;
        in_valid = 1'b1;

        // Step 2: Release in_valid
        #(CLOCK_PERIOD) in_valid = '0;
        
        // Step 3: Wait for computation to complete
        #(CLOCK_PERIOD*5);
        
        // Display results
        $display("Matrix Multiplication Results for example 1:");
        $display("Result c11 = %d (Expected: 19)", c11);
        $display("Result c12 = %d (Expected: 22)", c12);
        $display("Result c21 = %d (Expected: 43)", c21);
        $display("Result c22 = %d (Expected: 50)", c22);
        
        // Run a bit longer to see stable results
        #(CLOCK_PERIOD*5);


        //////////////////////////////////////// Matrix multiplication example 2: ////////////////////////////////
        // A = [6 7]    B = [13 12]
        //     [8 14]        [11 10]
        // Expected result = [155 142]
        //                   [258  236]
        
        // Step 1: First elements enter and set input in_valid
        #(CLOCK_PERIOD*2);
        a11 = 4'd6;
        a12 = 4'd7;
        a21 = 4'd8;
        a22 = 4'd14;
        b11 = 4'd13;
        b12 = 4'd12;
        b21 = 4'd11;
        b22 = 4'd10;
        in_valid = 1'b1;

        // Step 2: Release in_valid
        #(CLOCK_PERIOD) in_valid = '0;
        
        // Step 3: Wait for computation to complete
        #(CLOCK_PERIOD*5);
        
        // Display results
        $display("Matrix Multiplication Results for example 2:");
        $display("Result c11 = %d (Expected: 155)", c11);
        $display("Result c12 = %d (Expected: 142)", c12);
        $display("Result c21 = %d (Expected: 258)", c21);
        $display("Result c22 = %d (Expected: 236)", c22);
        
        // Run a bit longer to see stable results
        #(CLOCK_PERIOD*5);



        //////////////////////////////////////// Example 3: Two consecutive matrix multiplication////////////////////////////////
        // Step 1: First set elements enter and set input in_valid
        // A = [6 7]    B = [13 12]
        //     [8 14]        [11 10]
        // Expected result = [155 142]
        //                   [258  236]
        #(CLOCK_PERIOD*2);
        a11 = 4'd1;
        a12 = 4'd2;
        a21 = 4'd3;
        a22 = 4'd4;
        b11 = 4'd5;
        b12 = 4'd6;
        b21 = 4'd7;
        b22 = 4'd8;
        in_valid = 1'b1;

        // Step 2: Second set elements enter and set input in_valid 
        // A = [1 2]    B = [5 6]
        //     [3 4]        [7 8]
        // Expected result = [19 22]
        //                   [43 50]
        #(CLOCK_PERIOD) 
        a11 = 4'd6;
        a12 = 4'd7;
        a21 = 4'd8;
        a22 = 4'd14;
        b11 = 4'd13;
        b12 = 4'd12;
        b21 = 4'd11;
        b22 = 4'd10;
        in_valid = 1'b1;

        // Release in_valid
        #(CLOCK_PERIOD) in_valid = '0;
        
        // Step 3: Wait for computation to complete
        #(CLOCK_PERIOD*4);
        
        // Display results
        $display("Matrix Multiplication Results for example 3 (1st set):");
        $display("Result c11 = %d (Expected: 19)", c11);
        $display("Result c12 = %d (Expected: 22)", c12);
        $display("Result c21 = %d (Expected: 43)", c21);
        $display("Result c22 = %d (Expected: 50)", c22);
        

        // Step 4: Wait for computation to complete
        #(CLOCK_PERIOD*5);
        
        // Display results
        $display("Matrix Multiplication Results for example 3 (2nd set):");
        $display("Result c11 = %d (Expected: 155)", c11);
        $display("Result c12 = %d (Expected: 142)", c12);
        $display("Result c21 = %d (Expected: 258)", c21);
        $display("Result c22 = %d (Expected: 236)", c22);


        // Run a bit longer to see stable results
        #(CLOCK_PERIOD*5);

        // End simulation
        $finish;
    end
  
    // Generate waveform dump for analysis
    initial begin
        $dumpfile("dump.vcd"); $dumpvars;
    end

endmodule : systolic_array_controller_tb
