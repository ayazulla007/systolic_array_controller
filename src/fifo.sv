// ----------------------------------------------------
// Module : fifo
// Instantiated in : systolic_array_controller
// Author :         Ayazulla Khan
// ----------------------------------------------------

/**
 * Parameterized FIFO Buffer Module
 * 
 * This module implements a synchronous FIFO with configurable width and depth.
 * It manages read and write pointers and provides status signals for full/empty conditions.
 * 
 * Parameters:
 *   - DW: Data width (default: 32)
 *   - N: FIFO depth (default: 8)
 */
module fifo #(DW = 32, N=8) (
	input clk,                      // Clock signal
	input rst_n,                    // Active-low asynchronous reset
	input wr_en,                    // Write enable
	input rd_en,                    // Read enable
	input logic [DW-1:0] wr_data,   // Input data to be written
	output logic [DW-1:0] rd_data,  // Output data read from FIFO
	output logic full,              // Full status flag
	output logic empty              // Empty status flag
);
parameter LN = $clog2(N);           // Compute bit width needed for pointers

// Pointers to track read and write positions
logic [LN-1:0] wptr;                // Write pointer
logic [LN-1:0] rptr;                // Read pointer
logic [LN:0] fifo_count;            // Counter to track number of elements in FIFO

/**
 * Read/Write pointer management
 * Increments pointers when read/write operations are performed and FIFO is not empty/full
 */
always_ff @(posedge clk or negedge rst_n) begin 
 	if(~rst_n) begin
 		 wptr<= '0; rptr <='0;      // Reset pointers
 	end else begin
 		if (wr_en && !full) 		wptr <= wptr + 1'b1;  // Increment write pointer when writing and not full
		if (rd_en && !empty) 		rptr <= rptr + 1'b1;  // Increment read pointer when reading and not empty
 	end
 end 

/**
 * FIFO memory storage
 * Array of depth N and width DW to store the data
 */
logic [DW-1:0] mem [N-1:0];

/**
 * Memory write operation
 * Stores data into memory when write is enabled and FIFO is not full
 */
always_ff @(posedge clk or negedge rst_n) begin : proc_mem
 	if(~rst_n) begin
 		for (int i = 0; i < N; i++) begin
 			mem[i] <= '0;           // Initialize all memory locations to zero
 		end
 	end else begin
 		if (wr_en & !full) mem[wptr] <= wr_data;  // Write data to memory at write pointer position
 	end
 end 

/**
 * Memory read operation
 * Reads data from memory when read is enabled and FIFO is not empty
 */
always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		rd_data <= '0;              // Reset read data
	end else begin
		if (rd_en && !empty) rd_data <= mem[rptr];  // Output data from read pointer position
	end
end

// Status flags
assign empty 	= (fifo_count == '0);         // FIFO is empty when count is zero
assign full 	= (fifo_count == N[LN:0]);    // FIFO is full when count equals capacity

/**
 * FIFO count management
 * Tracks the number of elements in the FIFO
 */
always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fifo_count <= '0;           // Reset counter
	end else begin
		if ((wr_en && !full) && (rd_en && !empty))   	fifo_count <= fifo_count;      // Simultaneous read+write: count unchanged
		else if (wr_en && !full) 						fifo_count <= fifo_count + 1'b1; // Write only: increment count
		else if (rd_en && !empty) 						fifo_count <= fifo_count - 1'b1; // Read only: decrement count
	end
end

endmodule : fifo
