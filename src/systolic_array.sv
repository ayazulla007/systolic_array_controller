// ----------------------------------------------------
// Module : systolic_array
// Instantiated in : systolic_array_controller
// Author :         Ayazulla Khan
// ----------------------------------------------------

`include "processing_element.sv"
`timescale 1ns / 1ps

/**
 * Systolic Array Module
 *
 * This module implements a 2×2 systolic array for matrix multiplication.
 * It consists of four processing elements arranged in a grid pattern.
 * Data flows through the array in a synchronized manner.
 *
 * Inputs:
 *   - a1, a2: Matrix A elements entering from left
 *   - b1, b2: Matrix B elements entering from top
 *   - initialize: Signal to initialize internal accumulators
 *
 * Outputs:
 *   - c1, c2, c3, c4: Result matrix elements (c11, c12, c21, c22)
 */
module systolic_array (
    input clk,                // Clock signal
    input rst_n,              // Asynchronous reset active low
    input [3:0] a1,           // Matrix A element (row 1)
    input [3:0] a2,           // Matrix A element (row 2)
    input [3:0] b1,           // Matrix B element (column 1)
    input [3:0] b2,           // Matrix B element (column 2)
    input initialize,         // Signal to initialize internal registers
    output logic [8:0] c1,    // Output c11
    output logic [8:0] c2,    // Output c12
    output logic [8:0] c3,    // Output c21
    output logic [8:0] c4     // Output c22
);

    // Internal connections between processing elements
    logic [3:0] p_pe1;        // Horizontal connection from PE1 to PE2
    logic [3:0] q_pe1;        // Vertical connection from PE1 to PE3
    
/**
 * PE1 - Top-left processing element (1,1)
 * Computes partial result for c11
 */
processing_element i_processing_element_1 (
    .clk  (clk  ),
    .rst_n(rst_n),
    .m    (a1   ),            // Matrix A element from left
    .n    (b1   ),            // Matrix B element from top
    .s_in (initialize ? '0 : c1), // Initialize accumulator or use existing value
    .p    (p_pe1),            // Pass A element to right (PE2)
    .q    (q_pe1),            // Pass B element down (PE3)
    .s_out(c1)                // Output result for c11
);

/**
 * PE2 - Top-right processing element (1,2)
 * Computes partial result for c12
 */
    logic [3:0] q_pe2;         // Vertical connection from PE2 to PE4
processing_element i_processing_element_2 (
    .clk  (clk  ),
    .rst_n(rst_n),
    .m    (p_pe1),            // Matrix A element from PE1 (left)
    .n    (b2   ),            // Matrix B element from top
    .s_in (initialize ? '0 : c2), // Initialize accumulator or use existing value
    .p    (),                 // Not used (end of row)
    .q    (q_pe2),            // Pass B element down (PE4)
    .s_out(c2)                // Output result for c12
);

/**
 * PE3 - Bottom-left processing element (2,1)
 * Computes partial result for c21
 */
    logic [3:0] p_pe3;         // Horizontal connection from PE3 to PE4
processing_element i_processing_element_3 (
    .clk  (clk  ),
    .rst_n(rst_n),
    .m    (a2   ),            // Matrix A element from left
    .n    (q_pe1),            // Matrix B element from PE1 (top)
    .s_in (initialize ? '0 : c3), // Initialize accumulator or use existing value
    .p    (p_pe3),            // Pass A element to right (PE4)
    .q    (),                 // Not used (end of column)
    .s_out(c3)                // Output result for c21
);

/**
 * PE4 - Bottom-right processing element (2,2)
 * Computes partial result for c22
 */
processing_element i_processing_element_4 (
    .clk  (clk  ),
    .rst_n(rst_n),
    .m    (p_pe3),            // Matrix A element from PE3 (left)
    .n    (q_pe2),            // Matrix B element from PE2 (top)
    .s_in (initialize ? '0 : c4), // Initialize accumulator or use existing value
    .p    (),                 // Not used (end of row)
    .q    (),                 // Not used (end of column)
    .s_out(c4)                // Output result for c22
);

endmodule : systolic_array
