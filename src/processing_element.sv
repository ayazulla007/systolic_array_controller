// ----------------------------------------------------
// Module : processing_element
// Instantiated in : systolic_array
// Author :         Ayazulla Khan
// ----------------------------------------------------

`timescale 1ns / 1ps

/**
 * Processing Element (PE) Module
 *
 * This module implements a single processing element for the systolic array.
 * Each PE performs multiplication and accumulation of input values, and
 * passes input values to adjacent PEs.
 * 
 * Inputs:
 *   - m: Input from left (matrix A element)
 *   - n: Input from top (matrix B element)
 *   - s_in: Accumulated sum input
 *
 * Outputs:
 *   - p: Passes m to the right
 *   - q: Passes n downward
 *   - s_out: Result of multiplication and accumulation
 */
module processing_element (
    input clk,                // Clock signal
    input rst_n,              // Asynchronous reset active low
    input [3:0] m,            // Input from left (matrix A element)
    input [3:0] n,            // Input from top (matrix B element)
    input [8:0] s_in,         // Accumulated sum input
    output logic [3:0] p,     // Output to right (pass-through for m)
    output logic [3:0] q,     // Output to bottom (pass-through for n)
    output logic [8:0] s_out  // Output result (accumulated sum)
);

/**
 * Process multiplication and accumulation
 * On each clock cycle:
 * - Multiply input values m and n
 * - Add product to accumulated sum s_in
 * - Pass input values to outputs p and q
 */
always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        {s_out, p, q} <= '0;  // Reset all outputs
    end else begin
        // Calculate the accumulated sum and pass through inputs
        s_out <= s_in + (m * n);  // Multiply and accumulate
        {p,q} <= {m,n};           // Pass inputs to next PEs
    end
end

endmodule : processing_element
