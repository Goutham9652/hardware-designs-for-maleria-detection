# Hardware Designs for Malaria Detection

## Overview

This repository presents hardware implementations of lightweight binary classification algorithms using Verilog HDL for malaria detection from small-sized medical images. The project focuses on optimizing the following classifiers:

* **K-Nearest Neighbors (K-NN)**
* **Convolutional Neural Networks (CNN)**
* **Decision Trees (DT)**

These designs are tailored for deployment on low-cost FPGAs to facilitate real-time diagnostics in resource-constrained environments.

## Repository Structure

```
├── CNN on FPGA/
│   └── Verilog modules for CNN: convolution, padding, pooling, classification
├── Decision_Tree_on FPGA/
│   └── Verilog code for DT classifier with histogram-based logic
├── KNN_Hardware/
│   └── Verilog design for XOR-based KNN classifier
├── testbenches/
│   └── Testbenches for all modules

```

## Features

* Fully modular and RTL-based Verilog design
* Preprocessing: grayscale conversion, binarization, histogram quantization
* Optimized for FPGA synthesis with FSM-based control
* Resource-efficient: reduced LUT and power usage

## Getting Started

### Prerequisites

* Xilinx Vivado Design Suite
* ModelSim (or any Verilog simulator)
* Python (for dataset preprocessing if needed)

### Steps to Run

1. **Clone the Repository**

```bash
git clone https://github.com/Goutham9652/hardware-designs-for-maleria-detection.git
cd hardware-designs-for-maleria-detection
```

2. **Choose Classifier Directory**

```bash
cd "CNN on FPGA"  # or "KNN_Hardware" or "Decision_Tree_on FPGA"
```

3. **Simulate Modules**

* Use provided testbenches in `testbenches/`
* Simulate with ModelSim or Vivado Simulator

4. **Synthesize Design**

* Open Vivado
* Create a project and add design files
* Run synthesis and implementation

## Performance Summary

| Classifier | Accuracy | LUT Reduction | Delay (ns) | Power (W)   | Best Input Size |
| ---------- | -------- | ------------- | ---------- | ----------- | --------------- |
| K-NN       | 96-98%   | 73.9%         | \~10-14    | 0.111-0.842 | 64x64           |
| CNN        | 92-98%   | 57%           | \~3.4-6    | 0.091-0.389 | 64x64           |
| DT         | 99%      | N/A           | 9.338      | 0.123       | 64x64           |

## Comparative Highlights

* **CNN** offers the best trade-off between accuracy and resource usage.
* **DT** is the fastest with highest classification accuracy.
* **K-NN** is extremely simple and lightweight for quick implementations.

## Future Work

* Expand to multi-class classification
* Real-time camera/image sensor integration
* ASIC porting for ultra-low power devices
* Explore hybrid classifier architectures

## License

MIT License. See the [LICENSE](LICENSE) file for more information.

## Acknowledgments
* Dataset: [NIH Malaria Dataset](https://lhncbc.nlm.nih.gov/publication/pub9932)
