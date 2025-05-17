
# Minified CNN Architecture

## Overview

This project implements a lightweight convolutional neural network (CNN) pipeline for classifying small binary images (e.g. 16×16 medical images) entirely in FPGA hardware. The design performs a single 3×3 convolution, followed by zero-padding and 2×2 max-pooling, then flattens the result and classifies it by nearest-prototype distance comparison.  By avoiding a large fully-connected layer and instead comparing the output feature vector against stored class “prototype” vectors, the architecture remains simple and resource-efficient. The entire system is fully synchronous: each module operates on the same clock and handshakes with `start`/`done` signals to create a pipeline that flows deterministically through all stages.

## Modular Breakdown

* **MAC Unit:** A Multiply-Accumulate (MAC) core forms the heart of convolution. It takes a 3×3 window of image pixels and corresponding filter weights, multiplies each pair, and accumulates the sum. Each MAC operation produces one output pixel (a small multi-bit value, e.g. 4 bits) of the feature map.
* **Convolution Module:** This module implements the sliding 3×3 convolution using the MAC unit. It shifts a 3×3 window across the input image and uses the MAC unit to compute the dot-product at each position. The result is a (n–2)×(n–2) feature map (14×14 for a 16×16 input). The module asserts a `done_Conv` signal when it has finished processing all positions.
* **Padding Module:** The padding stage surrounds the 14×14 feature map with a one-pixel border of zeros to restore the original dimension (16×16).  This “zero-padding” preserves spatial size so that details at the borders are not lost. Padding is applied after convolution but before pooling. The module outputs the padded 16×16 map and asserts `pad_done` once complete.
* **Pooling Module:** This module performs 2×2 max-pooling on the padded feature map. It divides the 16×16 map into non-overlapping 2×2 blocks and takes the maximum value in each block. This reduces the size by a factor of 2, yielding an 8×8 pooled feature map. The pooling module outputs the pooled data (flattened to a vector) and asserts `pool_done` when done. Max-pooling is chosen for its simplicity and effectiveness.
* **Classification Module:** Instead of a traditional fully-connected layer, this module compares the flattened pooled output to stored class references. First, the 8×8 pooled map is flattened into a 64×1 single-column vector (SCV). The hardware then computes a distance (e.g. sum of absolute differences) between this test SCV and each stored prototype SCV. In our binary-two-class case, two reference SCVs are kept (e.g. “healthy” and “diseased”). The classification logic accumulates a distance metric (using internal registers, e.g. `reg_H` and `reg_D`) as it reads each entry of the SCV from BRAM. It asserts `Result=0/1` based on which stored vector has the smaller distance, and raises `classify_done` when finished. This approach (1-NN with stored class vectors) simplifies hardware by eliminating a large MAC tree in favor of a single distance comparison.
* **BRAM (Reference Memory):** Two on-chip Block RAM blocks store the pre-computed reference SCVs for each class (e.g. averaged feature vectors of healthy vs diseased images). Each BRAM outputs one element of the class SCV per clock when addressed. These outputs feed into the Classification module. By storing only the final feature vectors (not full images), memory requirements are very low.

## Execution Flow

1. **Convolution Stage:** On asserting `Start=1`, the FSM enables the Convolution module. The MAC unit processes each 3×3 window of the 16×16 input image in turn, multiplying and summing to produce one feature-map pixel at a time. When all positions are done, `done_Conv` goes high.
2. **Padding Stage:** The FSM then asserts `pad_start`, triggering the Padding module. This unit reads the 14×14 feature map and outputs it with a zero border, producing a 16×16 padded feature map. Once padding is complete, `pad_done` is asserted.
3. **Pooling Stage:** Next, the FSM asserts `Start_pool`. The Max-Pooling module reads each 2×2 block of the padded map and outputs the largest of each block. The result is an 8×8 pooled map. The module outputs a flattened 64-element vector (`pool_out`) and raises `pool_done`.
4. **Classification Stage:** Finally, the FSM asserts `classify_start`. The Classification module takes the 64-element `test_SCV` (from `pool_out`) and, over successive clock cycles, compares it with each stored class SCV from BRAM. It accumulates the sum of absolute differences (distance) to the “healthy” SCV and to the “diseased” SCV. After processing the entire vector, it selects the class with minimum distance, outputs the 1-bit `Result`, and asserts `classify_done`. This pipeline stage effectively implements a nearest-prototype classifier.
5. **Completion:** Upon `done_Classify`, the FSM returns to IDLE, ready for a new input. All data transfers between stages use clocked registers so that the design remains fully synchronous and pipelined.

## FSM Flowchart

![CNN_flow drawio](https://github.com/user-attachments/assets/85d3b8af-c18c-4ca2-856e-2002b86c67c5)


*Figure: FSM flowchart of the control logic. The machine starts in IDLE, then on `Start=1` sequentially enables Convolution, Padding, Pooling, and Classification stages. Each stage sets a “done” flag when finished; the FSM waits for that flag before moving on. After classification completes, the FSM returns to IDLE.*

The FSM ensures strict ordering. In **IDLE**, it waits for the `Start` command. It then enters **Convolution Stage**; when `done_Conv` is high it transitions to **Padding Stage**; when `done_Pad` is high it transitions to **Pooling Stage**; when `done_Pool` is high it transitions to **Classification Stage**; when `done_Classify` is high it returns to **IDLE**. Each transition is driven by a single clock edge in sync with the `clk` signal. This state machine guarantees that no two modules run simultaneously and that data only flows forward when each stage signals completion.

## Block Diagram

![CNN_block](https://github.com/user-attachments/assets/0b4f76ca-6c9b-4fb1-8a17-b4d7b0c9308b)


*Figure: Block diagram of the top-level CNN implementation (`CNN_top`). Global signals (`clk`, `reset`, `Start`) feed all submodules. Data flows from left to right through Convolution, Padding, Pooling, then Classification, with intermediate “done” signals controlling the handshakes. Two BRAM blocks store the reference vectors for the classes.*

In the block diagram, the input 16×16 image is presented as a flattened vector (`Test_image[n*n-1:0]`). On `Start`, the Convolution module (with its MAC unit) processes this image and outputs the feature map (`featuremap[(n-2)^2-1:0]`) along with `done_Conv`. Once `done_Conv` is high, the Padding module is triggered (`pad_start`) and reads the 14×14 featuremap to produce a zero-padded 16×16 output. When padding finishes, `pad_done` goes high and the pooled module starts.

The Max\_Pooling module takes the padded 16×16 input (`pool_in`) and, on each cycle, compares each 2×2 block to output the maximum value, forming an 8×8 result. It outputs this as a 64-element vector (`pool_out[(n/2)^2-1:0]`) and asserts `pool_done` when complete. At that point, the pooled output is treated as the test single-column vector (`test_SCV`) for classification.

In parallel, two BRAMs (`Diseased_SCV` and `Healthy_SCV`) provide the stored prototype vectors. The Classification module cycles through these memories (via an `addr` bus) and accumulates a distance in registers (`reg_H` for healthy, `reg_D` for diseased). Once all 64 elements are compared, the module outputs the final **Result** bit indicating the closer class, and asserts `classify_done`. All inter-module signals (`done_*`, `Start_*`, data buses) are synchronized to the single clock, yielding a fully clocked pipeline.

## Input/Output Interface

* **Input Format:** The test image is presented as a flat binary vector of length *n*² bits. For *n*=16, this is a 256-bit input bus (`Test_image[255:0]`). Each bit represents one pixel.
* **Convolution Output:** The convolution stage produces a (n–2)×(n–2) feature map. For n=16, this is 14×14=196 values. These are output as a flat vector (`featuremap[195:0]`), where each element is the 4-bit MAC sum.
* **Padded Output:** The padding stage outputs a (n×n) map (16×16=256 values) by adding zeros around the 14×14 input. This is a 256-bit (or wider) vector (`padded_out[255:0]`).
* **Pooling Output:** The 2×2 max-pooling yields (n/2)×(n/2) values. For n=16, that is 8×8=64 outputs. These are provided as a 64-element vector (`pool_out[63:0]`), each element 4 bits.
* **Flattening to SCV:** The 8×8 pooled matrix is converted to a single-column vector (SCV) of length 64.  In hardware, this is effectively just interpreting the `pool_out` bus as a column. This flattening step matches the description in the literature.
* **Classification I/O:** The `test_SCV` (64×4 bits) enters the Classification block. Two reference SCVs of the same size are stored in BRAM. The Classification module outputs a 1-bit **Result** (class label) and a **classify\_done** flag.
* **Synchronization:** All inter-module buses are registered on the shared clock. For example, the featuremap output registers into the Padding module on `done_Conv`, then the padded output registers into the Pooling module, and so on. This fully synchronous interface prevents combinational conflicts and ensures reliable pipelining.

## Citation

* S. Saglam and S. Bayar, *Hardware Design of Lightweight Binary Classification Algorithms for Small-Size Images on FPGA*, IEEE Access, 2024. This work describes a similar “minified” CNN architecture using 3×3 convolution, padding, pooling, and SCV-based classification. It provides the theoretical basis and motivations for our design choices.
