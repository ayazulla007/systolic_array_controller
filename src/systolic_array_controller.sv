// ----------------------------------------------------
// Module : systolic_array_controller
// DESIGN_TOP 
// Instantiated in : systolic_array_controller_tb 
// Author :         Ayazulla Khan
// ----------------------------------------------------

`include "systolic_array.sv"
`include "fifo.sv"
`timescale 1ns / 1ps


/**
 * Systolic Array Controller
 *
 * This module implements the top-level controller for a 2×2 systolic array
 * matrix multiplication system. It manages the data flow, timing, and operation
 * of the systolic array, including input buffering using a FIFO.
 *
 * The controller features a finite state machine (FSM) that sequences data
 * through the array in the correct order to perform matrix multiplication.
 */


module systolic_array_controller (
	input clk,    						// Clock
	input rst_n,  						// Active low reset
	//input A matrix, assuming each element is 4 bit
	input [3:0] a11, 					// Matrix A element (row 1, col 1)
	input [3:0] a12, 					// Matrix A element (row 1, col 2)
	input [3:0] a21, 					// Matrix A element (row 2, col 1)
	input [3:0] a22, 					// Matrix A element (row 2, col 2)
	//input B matrix, assuming each element is 4 bit	
  	input [3:0] b11, 					// Matrix B element (row 1, col 1)
	input [3:0] b12, 					// Matrix B element (row 1, col 2)
	input [3:0] b21, 					// Matrix B element (row 2, col 1)
	input [3:0] b22, 					// Matrix B element (row 2, col 2)
  	//If high, indicates A matrix and B matrix input are valid. If Low they can be ignored
  	input in_valid, 					// Input validation signal
 
  	//output C matrix, assuming each element is 4+4+1=9 bit
  	output logic [8:0] c11, 	  		// Result matrix C element (row 1, col 1)
  	output logic [8:0] c12, 			// Result matrix C element (row 1, col 2)
  	output logic [8:0] c21, 			// Result matrix C element (row 2, col 1)
  	output logic [8:0] c22, 			// Result matrix C element (row 2, col 2)
  	//Describes whether the output is valid. Only make out_valid high when all 4 elements in the C matrix are valid
  	output logic out_valid				// Output validation signal
);
	// Internal signals for systolic array inputs
	logic [3:0] a1;						// Input to systolic array (a11 or a12)
	logic [3:0] a2;						// Input to systolic array (a21 or a22)
	logic [3:0] b1;						// Input to systolic array (b11 or b21)
	logic [3:0] b2;						// Input to systolic array (b12 or b22)
	logic initialize_s;					// Next state value for initialize
	logic initialize_reg;				// Register to hold initialize signal

/**
 * Systolic Array Instance
 * Core computation unit that performs the matrix multiplication
 */
systolic_array i_systolic_array (
	.clk  (clk     ),
	.rst_n(rst_n   ),
	.a1   (a1      ),					// Matrix A input row 1
	.a2   (a2      ),					// Matrix A input row 2
	.b1   (b1      ),					// Matrix B input column 1
	.b2   (b2      ),					// Matrix B input column 2
	.initialize (initialize_reg),		// Signal to initialize accumulators
	.c1   (c11     ),					// Output element c11
	.c2   (c12     ),					// Output element c12
	.c3   (c21     ),					// Output element c21
	.c4   (c22     )					// Output element c22
);
	
	// Registers for storing input matrix elements
	logic [3:0] a11_reg, a12_reg, a21_reg, a22_reg, b11_reg, b12_reg, b21_reg, b22_reg;
	logic out_valid_s;					// Next state value for out_valid
	logic [1:0] state;     				// Current state register (2 bits for 4 states)
	logic [1:0] next;					// Next state
	logic [1:0] cycle_count;  			// Counter for tracking computation cycles

	// FSM states definition
	parameter [1:0] IDLE   = 2'b00,		// Waiting for input
					LOAD   = 2'b01,		// Loading initial values
					COMPUTE = 2'b10,	// Computing matrix multiplication
					OUTPUT = 2'b11;		// Outputting results

/**
 * Sequential Logic
 * Handles state transitions, initialization signal, and output validation
 */
always_ff @(posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		{state, initialize_reg, out_valid}  	<= '0;  // Reset all registers
		cycle_count                             <= '0;  // Reset cycle counter
	end else begin
		{state, initialize_reg, out_valid}  		<= {next, initialize_s, out_valid_s};  // Update state registers
		
		// Cycle counter management
		if (state == COMPUTE) begin
			cycle_count <= cycle_count + 1'b1;  // Increment cycle counter during computation
		end else begin
			cycle_count <= '0;  // Reset cycle counter in other states
		end
	end
end

/**
 * FIFO Buffer Instance
 * Stores input matrix elements for processing
 * Data width = 32 bits (8 elements × 4 bits per element)
 * Depth = 2 entries
 */
	logic rd_en;				// Read enable signal for FIFO
	logic full;					// FIFO full indicator
	logic empty;				// FIFO empty indicator
fifo #(.DW(32), .N(2)) i_fifo (
	.clk    (clk    ),
	.rst_n  (rst_n  ),
	.wr_en  (in_valid),						// Write when input is valid
	.rd_en  (rd_en  ),						// Read controlled by FSM
	.wr_data({a11, a12, a21, a22, b11, b12, b21, b22}),  // Store all matrix elements
	.rd_data({a11_reg, a12_reg, a21_reg, a22_reg, b11_reg, b12_reg, b21_reg, b22_reg}),  // Read all matrix elements
	.full   (full   ),						// FIFO full signal
	.empty  (empty  )						// FIFO empty signal
);

/**
 * Combinational Logic
 * Implements the FSM that controls the systolic array operation
 */
always_comb begin
	// Default assignments
	next 					= state;				// Default: stay in current state
	{a1,a2,b1,b2}  			= '0;					// Default: no input to systolic array
	out_valid_s 			= '0;					// Default: output not valid
	initialize_s 			= '0;					// Default: don't initialize
	rd_en 					= '0;					// Default: don't read from FIFO
	
	case (state)
		// IDLE state: Wait for data in FIFO
		IDLE: begin
			if (!empty) begin						// If FIFO has data
				next 			= LOAD;				// Move to LOAD state
				initialize_s 	= 1'b1;				// Set initialize signal
				rd_en			= 1'b1;				// Enable FIFO read
			end
		end
		
		// LOAD state: Begin computation with first elements
		LOAD: begin
			next 			= COMPUTE;				// Move to COMPUTE state
			{a1,a2,b1,b2} 	= {a11_reg, 4'b0, b11_reg, 4'b0};  // Load first elements
		end
		
		// COMPUTE state: Run the systolic array for multiple cycles
		COMPUTE: begin
			case (cycle_count)
				2'b00: begin
					// Second cycle: All middle elements enter the array
					{a1,a2,b1,b2} 	= {a12_reg, a21_reg, b21_reg, b12_reg};
				end
				
				2'b01: begin
					// Third cycle: Final elements enter the array
					{a1,a2,b1,b2} 	= {4'b0, a22_reg, 4'b0, b22_reg};
					next 			= OUTPUT;			// Move to OUTPUT state
				end
				
				default: {a1,a2,b1,b2} = '0;			// Default case
			endcase
		end
		
		// OUTPUT state: Set output valid and return to IDLE
		OUTPUT: begin
			out_valid_s 	= 1'b1;					// Set output valid signal
			next 			= IDLE;					// Return to IDLE state
		end
		
		// Default case: return to IDLE
		default: begin
			next 			= IDLE;
			{a1,a2,b1,b2}  	= '0;
			out_valid_s 	= '0;
			initialize_s 	= '0;
			rd_en 			= '0;
		end
	endcase
end

endmodule : systolic_array_controller
