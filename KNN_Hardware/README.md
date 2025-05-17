
**Project Title: k-NN Classifier for Binary Image Classification in Verilog**

**Abstract:** A lightweight k-NN implementation optimized for FPGA with minimal LUT usage.

**Key Features:**
* Uses a binarized distance metric instead of conventional Euclidean or Manhattan distances.
* Processes 16×16 binary images for disease classification.
* Optimized for low LUT utilization on FPGA.

**Performance Metrics:**

*  _Accuracy:_ 92.00% for 16×16 images
*  _LUT Utilization:_ 9.33% (Optimized FPGA Resource Usage)
*  _Classification Speed:_ 44.72 ns per image

**Comparison with CNN & Decision Tree:**

* **CNN:** Higher accuracy (97.67%) but requires more LUTs.
* **Decision Tree:** Highest accuracy (99.33%), but slowest execution (336.62 ns).
* **k-NN: Best balance between accuracy and resource efficiency.**

## Image Pre-processing ##

**Step 1: Convert RGB Image to Binary**

* Input images are originally in RGB format.
* The RGB image is first converted to grayscale.
* A fixed-threshold binarization method is applied to obtain a binary image (0s and 1s).
* Each pixel is set to 1 (white) if its intensity is above a fixed threshold (e.g., 128) and 0 (black) otherwise.
  
**Step 2: Resize to 16×16**

* The binarized image is resized to 16×16 pixels to reduce computational complexity.
* This ensures all images have a fixed dimension before k-NN classification.

**Step 3: Flattening**
* The 16×16 binary image is flattened into a 256-bit single-column vector (SCV). Then feed as input to the classifier

## Working Process ##

**Step 1: Image Pre-Processing**

* Input images undergo grayscale conversion, binarization, and resizing to 16×16 pixels.
* The processed image is flattened into a 256-bit SCV.

**Step 2: Distance Computation**
* The test image's SCV is compared to all N stored images in the ROM-based dataset.
* Instead of using traditional Euclidean or Manhattan distance, the Hamming distance (bitwise XOR + sum) is computed.
* This helps reduce FPGA resource utilization while maintaining classification accuracy.
  
**Step 3: Find Minimum Distance )**
* The ROM index with the minimum number of differing bits (Hamming distance) is selected.
* The index m of the closest match is stored.
  
**Step 4: Classification Decision**
* If m ≤ N/2, the test image is classified as Healthy. 
* If m > N/2, the test image is classified as Diseased.

here are the FSM and the block diagram of my Modular approach:

![k-NN_FSM drawio](https://github.com/user-attachments/assets/e0d74072-4ea3-4d7d-b947-0d901b1bf9ee)
![k-NN_block drawio](https://github.com/user-attachments/assets/8bdc5674-d8a5-49dd-a292-54f3e2f11058)



for reference, read the research article :  [ https://ieeexplore.ieee.org/document/10504831 ]

Here I have created a text file that contains 300 rows, each row has a blood cell's binary matrix's flattened vector which we have taken it as a reference image in verilog module.

_note that the file has 300 images_ 
* 150 uninfected (row 1 to row 150  )
* 150 infected   (row 151 to row 300)
