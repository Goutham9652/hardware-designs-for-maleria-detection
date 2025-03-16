# CNN Hardware Accelerator - Verilog Implementation

## Overview
This project implements a Convolutional Neural Network (CNN) inference pipeline using Verilog. The design processes a **16×16 binary image**, extracts features via convolution and pooling, and classifies the result using a preloaded dataset stored in BRAM.

## Algorithm Overview
### Steps in the Algorithm
1. **Feature Extraction (Convolution)**
  - Applies a **3×3 filter** (binary weights `0 or 1`) to the convolved image.
  - Uses a **Multiply-Accumulate (MAC) unit** to compute the output feature map.

2. **padding**
   - Converts a **14×14 feature map** into a **16×16 matrix** by padding borders.
   - Uses `4'b1` as padding values.

3. **Dimensionality Reduction (Max Pooling)**
   - Converts the **14×14 feature map** into an **8×8 matrix**.
   - Extracts the **maximum value from each 2×2 region**.

4. **Classification using Stored Data (SCV Matching)**
   - The **8×8 matrix (256-bit vector)** is compared with preloaded BRAM data.
   - A **minimum distance classifier** determines the class (Healthy/Diseased).

---
## Module Breakdown
### **(A) MAC Unit (`MAC_UNIT.v`)**
#### Function:
- Performs **Multiply-Accumulate (MAC) operations** on a **3×3 matrix**.
- Uses **binary weights (1 or 0)** for convolution.

#### Operations:
1. Computes **partial multiplications** using element-wise AND.
2. Accumulates the results using adders.
3. Outputs the **4-bit convolution result**.

---
### **(B) Convolution Layer (`Conv.v`)**
#### Function:
- Applies a **3×3 filter** on the **16×16 padded matrix**.
- Uses the **MAC unit** to process sliding windows.
- Outputs a **14×14 feature map**.

#### Operations:
1. Extracts **3×3 windows** dynamically.
2. Calls `MAC_UNIT` to compute feature values.
3. Stores results in `feature_map`.

---
### **(C) Padding Layer (`padding.v`)**
#### Function:
- Converts **14×14 feature maps** into a **16×16 matrix** with padding.

#### Operations:
1. If the pixel is on the **border**, assign `4'b1`.
2. Otherwise, **copy the corresponding value**.

---
### **(D) Pooling Layer (`pooling.v`)**
#### Function:
- Performs **Max Pooling (2×2)** to reduce the feature map from **14×14 → 8×8**.

#### Operations:
1. Extracts **2×2 blocks**.
2. Computes the **maximum** of the four values.
3. Stores the result in `output_matrix`.

---
### **(E) Classification Layer (`classification.v`)**
#### Function:
- Compares the **final 8×8 matrix** with stored vectors from BRAM.
- Uses a **minimum distance classifier**.

#### Operations:
1. Reads **preloaded healthy (`bram_h`) and diseased (`bram_d`) data**.
2. Computes **absolute differences**.
3. Accumulates distances.
4. **Smaller distance → Class label** (Healthy/Diseased).

---
### **(F) BRAM Storage (`bram_h.v` & `bram_d.v`)**
#### Function:
- Stores **pretrained feature vectors**.
- Outputs stored values **without clock synchronization**.

#### Operations:
1. Reads **preloaded data** from `h_scv.txt` and `d_scv.txt`.
2. Outputs stored values **asynchronously**.

---
## CNN Pipeline Execution Flow
1. **Padding:** Expands `14×14` to `16×16` for convolution.
2. **Convolution:** Uses a `3×3` kernel to extract local features.
3. **Pooling:** Reduces feature map size to `8×8`.
4. **Classification:** Compares with stored vectors and assigns a label.

---
## Optimization Without Clock Synchronization
- The **BRAM access is modified** to be purely combinational.
- Eliminates `clk` dependency in `bram_h.v` and `bram_d.v`.
- Ensures **instant memory access** for fast classification.

---
## Conclusion
This **hardware CNN accelerator** efficiently classifies binary images using convolution, pooling, and distance-based classification. The design ensures high-speed inference with optimized memory access.

### note that i have fed the inputs and taken outputs as flattened vectors:
* for convolution :
  -  input   = 16x16x1-bit  == 256-bits
  -  output  = 14x14x4-bits == 784-bits

* for padding :
  -  input   = 14x14x4-bits  == 784-bits
  -  output  = 16x16x4-bits  == 1024-bits

* for pooling :
  -  input   = 16x16x4-bits  == 1024-bits
  -  output  = 8x8x4-bits    == 256-bits

