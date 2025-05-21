

# 1 Systolic Array Matrix Multiplication

This directory contains a Verilog implementation of a 2×2 systolic array for matrix multiplication. It has source code: design and testbench files; verilog simulation files: log and waveform.

## 1.1 High-Level Architecture

The architecture consists of the following key components:

1. **Processing Element (PE)**: The fundamental building block that multiplies input values and accumulates results.
2. **Systolic Array**: A 2×2 grid of interconnected PEs that perform matrix multiplication in a parallel, pipelined manner.
3. **FIFO Buffer**: Parameterized buffer that stores input matrices for processing, allowing consecutive matrix multiplication operations.
4. **Controller**: Finite State Machine (FSM) that coordinates data flow through the systolic array.

### 1.1.1 System Diagram

```
                +------------------------------------------------+
                |                                                |
                |    +----------------+                          |
                |    | FIFO Buffer    |<---- Input Matrix A, B   |
                |    |                |                          |
                |    +-------+--------+                          |
                |            |                                   |
                |            v                                   |
                |    +-------+--------+                          |
                |    |                |                          |
                |    | Controller FSM |<----> Control Signals    |
                |    |                |                          |
                |    +-------+--------+                          |
                |            |                                   |
                |            v                                   |
                |    +-------+--------+                          |
                |    |                |                          |
                |    | Systolic Array |-------> Output Matrix C  |
                |    |                |                          |
                |    +----------------+                          |
                |                                                |
                +------------------------------------------------+
```

### 1.1.2 Module hierarchy

Design:
```
systolic_array_controller
  + i_systolic_array            (systolic_array)
    + i_processing_element_1    (processing_element)
    + i_processing_element_2    (processing_element)
    + i_processing_element_3    (processing_element)
    + i_processing_element_4    (processing_element)
  + i_fifo                      (fifo)

```

Design + Testbench :

```
systolic_array_controller_tb
  + i_systolic_array_controller     (systolic_array_controller)
    + i_systolic_array              (systolic_array)
      + i_processing_element_1      (processing_element)
      + i_processing_element_2      (processing_element)
      + i_processing_element_3      (processing_element)
      + i_processing_element_4      (processing_element)
  + i_fifo                          (fifo)
```


## 1.2 Microarchitecture Details

### 1.2.1 . Processing Element (PE)

Each processing element is designed to:
- Receive and multiply input values from matrices A and B
- Accumulate the product with its internal sum
- Pass input values to adjacent PEs
- Output final accumulated value

```

      n (from top)
       |
       v
  +--------+
m ->|        |-> p (to right)
  | |   PE   |
  | |        |
  | +--------+
  |    |
  v    v
q (to bottom) 

--------   s_in (partial sum) and s_out (accumulated result) --------

```

### 1.2.2 . Systolic Array (2×2)

Four processing elements arranged in a grid pattern:

```
PE(1,1) ----> PE(1,2)
   |            |
   v            v
PE(2,1) ----> PE(2,2)
```

Data flow:
- Matrix A elements flow from left to right
- Matrix B elements flow from top to bottom
- Each PE computes one element of the result matrix

### 1.2.3 . FIFO Buffer

A parameterized FIFO that:
- Stores input matrices
- Manages read/write pointers
- Provides full/empty status signals
- Supports configurable data width and depth

### 1.2.4 . Controller

The controller implements a 4-state FSM:
- **IDLE**: Waits for input data in FIFO 
- **LOAD**: Initializes systolic array and loads first elements
- **COMPUTE**: Processes matrix elements through multiple cycles, while middle and final elements load
- **OUTPUT**: Results propagate and accumulate, which (final results) will be available at outputs in next cycle

Data flow timing:
1. Cycle 0: a11*b11 enters PE(1,1)
2. Cycle 1: a12*b21 enters PE(1,1), a11*b12 enters PE(1,2), a21*b11 enters PE(2,1)
3. Cycle 2: a22*b21 enters PE(2,1), a21*b12 enters PE(2,2)
4. Cycle 3: Results propagate and accumulate
5. Cycle 4: Final results available at each PE

## 1.3 Matrix Multiplication Process

For a 2×2 matrix multiplication:

```
A = [a11 a12]    B = [b11 b12]    C = [c11 c12]
    [a21 a22]        [b21 b22]        [c21 c22]
```

Where:
- c11 = a11*b11 + a12*b21
- c12 = a11*b12 + a12*b22
- c21 = a21*b11 + a22*b21
- c22 = a21*b12 + a22*b22

## 1.4 Implementation Notes

- The design supports consecutive matrix multiplications by storing inputs in a FIFO
- The controller uses minimal state logic to efficiently process matrix operands
- Processing elements operate in parallel, maximizing throughput
- Reset logic ensures consistent initialization across all components

## 1.5 How to Use

1. Apply matrices A and B to the inputs
2. Assert in_valid for one clock cycle
3. Wait for out_valid signal
4. Read the result matrix from outputs c11, c12, c21, c22
5. For consecutive multiplications, apply new matrices while system is processing

## 1.6 Verification

### 1.6.1 Testcases
```
 Matrix multiplication example 1:
        A = [1 2]    B = [5 6]
            [3 4]        [7 8]
         Expected result  = [19 22]
                            [43 50]
```

```
Matrix multiplication example 2: 
        A = [6 7]    B = [13 12]
            [8 14]       [11 10]
        Expected result = [155 142]
                          [258 236]

```


```
Example 3: Two consecutive matrix multiplication
        Step 1: First set elements enter and set input in_valid
        A = [6 7]    B = [13 12]
            [8 14]       [11 10]
        Expected result = [155 142]
                          [258  236]
```

### 1.6.2 Waveforms

![waveform](waveform.png)
## 1.7 File structure

Code files:
- [systolic_array_controller_tb](systolic_array_controller_tb.sv)
- [systolic_array_controller](systolic_array_controller.sv)
- [systolic_array](systolic_array.sv)
- [processing_element](processing_element.sv)
- [fifo](fifo.sv)

Simulations results:
- [log](log)
- [waveform](waveform.png)