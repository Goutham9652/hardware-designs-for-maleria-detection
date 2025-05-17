
These thresholds were trained offline using histogram features from a malaria cell dataset.

---

## 🧩 Modular Architecture

The system is composed of six core modules:

![Decisionn_tree_block drawio](https://github.com/user-attachments/assets/09ecc528-ca5e-41b8-a740-0f2be7ddfce1)


| Module | Description |
|--------|-------------|
| **Input Interface** | Receives `clk`, `rst`, `start`, and image data. |
| **Quantizer** | Converts 8-bit RGB pixels to 6-bit grayscale using: `Q = R×(16/85) + G×(4/85) + B×(1/85)` |
| **Quantizer Memory** | Dual-port RAM to store quantized pixel values for histogramming. |
| **Counter** | Sequentially addresses pixels for histogram computation. |
| **Histogram Builder** | Constructs 64-bin histogram, only 4 bins used for classification (Bin_0, Bin_34, Bin_38, Bin_39). |
| **Classification Unit** | Implements nested conditional checks to produce the final `class_out`. |

---

## 🔁 FSM Flow

All modules are orchestrated via an FSM controller that ensures sequential operation and synchronization.

![Decision_tree_flow drawio](https://github.com/user-attachments/assets/7518f199-a930-4697-bc3b-b609d8fbb715)


**FSM States:**

- `IDLE` → Await start signal
- `QUANTIZING` → Begin quantizing pixels and writing to BRAM
- `HISTOGRAMMING` → Read quantized pixels and update bins
- `CLASSIFYING` → Perform decision-tree-based classification
- `DONE` → Output is ready (`process_done = 1`)

---

## 📥 Input/Output Format

| Stage | Input | Output |
|-------|-------|--------|
| Quantizer | 64x64x8-bit RGB image | 64x64x6-bit quantized pixels |
| Histogram | Quantized memory data | 64-bin histogram |
| Classifier | 4 bin values | `class_out` (2-bit label) |

* 4 Bin values to compare and classify whether the input is healthy or diseased

- IF bin_38 > 16 → Diseased
- ELSE IF bin_39 ≤ 10.5
- IF bin_0 ≤ 1638.5 → Healthy
-   ELSE → Diseased
-    ELSE IF bin_34 ≤ 4.5 → Healthy
-    ELSE → Diseased

---

## 🛠️ Simulation & Synthesis Results (Vivado)

| Metric         | Value (64×64)   |
|----------------|----------------|
| **Accuracy**   | 99%            |
| **Power**      | 0.118 W        |
| **Delay**      | 9.338 ns       |
| **LUT Usage**  | 28.84%         |
| **Clock**      | 100 MHz        |


---

## 🧪 Verification Strategy

- Modular testbenches for all blocks (`quantizer`, `histogram`, `classifier`)
- Functional waveform analysis using ModelSim
- Corner case testing on RGB inputs
- FSM sequencing validated through display probes and simulation logs

---

## 📂 File Structure


