# Computer Security Paper

Final result paper: [Computer Security Paper.pdf](./Computer%20Security%20Paper.pdf)

This repository contains a MATLAB-based simulation study of GNSS/GPS spoofing detection and mitigation using a phased-array receiver. The work models satellite signals, compares normal reception against spoofing conditions, and evaluates filtering and detection strategies based on MVDR beamforming and feature-based classification.

## Project overview

The project studies how a 4-element uniform linear array (ULA) responds to authentic satellite signals and malicious spoofers. It demonstrates:

- array geometry setup and visualization
- authentic satellite signal behavior
- baseline MVDR beamforming against a single spoofer
- coordinated multi-source spoofing attacks
- feature extraction for attack detection
- threshold-based and SVM-based classification

The project is organized as a step-by-step research workflow, with each MATLAB script corresponding to a stage of the study.

## Repository structure

- `Computer Security Paper.pdf` — final paper/report in PDF format
- `step1_Array_Setup.m` — CRPA/ULA geometry setup and display
- `Step2_Satellite_Signal_Visualization.m` — satellite directions and array response visualization
- `Step3_Baseline_MVDR_Single_Spoofer__Numeric_Null_Depth.m` — MVDR beamforming in the presence of a single spoofer
- `Step4_Coordinated_Multi_Source_Attack.m` — coordinated multi-source spoofing simulation
- `Step5/step5_feature_extraction.m` — feature comparison between baseline and attack conditions
- `Step5/extractFeatures.m` — helper function for feature extraction
- `step6/Step_6A.m` — threshold and SVM classification workflow
- `step6/Figure_6b.m` — simplified threshold-based detector visualization
- `output_ss/` — generated result plots from the early stages
- `step6/` — output figures and detection dataset for the final analysis

## Technical focus

The simulations use GPS L1 frequency (1575.42 MHz), a 4-element array with half-wavelength spacing, and complex baseband signals with Gaussian noise. The analysis focuses on three key signal-quality indicators:

- phase correlation
- eigenvalue spread
- Doppler/timing residual proxy

These features are used to distinguish normal operation from coordinated spoofing attacks. The final stage compares a simple threshold detector with an SVM classifier.

## Requirements

To run the scripts, you need:

- MATLAB (recommended: recent release such as R2020b or newer)
- Phased Array System Toolbox
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox (for SVM-based detection)

## How to run

1. Open MATLAB.
2. Set the repository as the working directory.
3. Run the scripts in order:
   - `step1_Array_Setup.m`
   - `Step2_Satellite_Signal_Visualization.m`
   - `Step3_Baseline_MVDR_Single_Spoofer__Numeric_Null_Depth.m`
   - `Step4_Coordinated_Multi_Source_Attack.m`
   - `Step5/step5_feature_extraction.m`
   - `step6/Step_6A.m` or `step6/Figure_6b.m`
4. Review the console output and generated figures.

## Notes

- This project is primarily a research and simulation repository rather than a production software package.
- The scripts are designed for analysis and demonstration, and many outputs are already included as PNG files in the project folders.
- The results are most useful when read alongside the PDF report in this repository.

## License

This repository does not currently specify a formal license file. Please check the repository state and project requirements before reusing the materials in a publication or external project.
