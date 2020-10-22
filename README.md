# FlexEMG Project: A wearable biosensing system with in-sensor adaptive machine learning for hand gesture recognition
Code and data repository for FlexEMG 2020 Nature Electronics publication. It is publicly available under GNU General Public License v3.

## System requirements
- Data collection:
  - Graphical user interface: Python 3.4
  - Device firmware: Libero SoC v11.7
- Data analysis:
  - Matlab R2019b
  - Python 3.7 (package dependencies can be found in data_analysis/flexemg.yml

## Repo structure
### Offline dataset for model validation
Offline data collected from 5 subjects can be found in the submodule 'offline_data'.

### Data collection code
Data collection code can be found in the subdirectory 'data_collection'. This directory includes the graphical user iterface (developed in PyQt) under the 'gui' subdirectory, as well as the firmware (FPGA design and ARM Cortex M3 code) located in 'FlexEMG_21Class_HDC'.

### Data analysis
Data collected from real-time experiments located in 'data_analysis/realtime_data' directory as .mat files. Offline data encoded using simulation of hardware HD proection algorithm located in 'data_analysis/hw_encode'.

Main analysis files include:
- 'compare_snr.m' and 'compare_spectrum.m' for analysis of sEMG signal quality (Fig. 2)
- 'get_pca_projection.ipynb', 'plot_pca_dim.m', 'plot_pca.m' for analysis of hypervector dimensionality (Fig. 3)
- 'realtime_confusion.m', 'realtime_examples.m', 'realtime_transitions.m' for analysis of real-time experiment data and classification accuracy (Figs. 5, 6)
