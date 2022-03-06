# Wireless_Communication_System_Simulation

## About  

Upon completion, this project will hope to simulate the performance of a wireless communication system as shown below:

<p align="center">
  <img width="460" height="300" src="https://github.com/hesheen-GH/Wireless_Communication_System_Simulation/blob/master/pictures/block_diagram.jpg">
</p>


## Current Features

This system currently features a Monte-Carlo BER Simulation of a BPSK Correlation Receiver in the AWGN Channel. 

A transmitter generates a BPSK signal from a Pseudorandom binary sequence (PRBS) source. Current supported line codes include Polar NRZ. 

<p align="center">
  <img width="460" height="300" src="https://github.com/hesheen-GH/Wireless_Communication_System_Simulation/blob/master/pictures/polar.PNG">
</p>

The transmitter can also compute the Autocorrelation Function using MATLAB's xcorr function. The Power Spectral Density of the Polar NRZ PRBS can be calculated using the Wiener-Khinchin theorem by applying FFT. 

<p align="center">
  <img width="460" height="300" src="https://github.com/hesheen-GH/Wireless_Communication_System_Simulation/blob/master/pictures/ACF.PNG">
</p>

<p align="center">
  <img width="460" height="300" src="https://github.com/hesheen-GH/Wireless_Communication_System_Simulation/blob/master/pictures/psd.PNG">
</p>

The transmitter modulates the Polar NRZ encoded signal to form a BPSK signal. 

<p align="center">
  <img width="460" height="300" src="https://github.com/hesheen-GH/Wireless_Communication_System_Simulation/blob/master/pictures/modulated%20signal.PNG">
</p>

The spectrum of the modulated signal is:

<p align="center">
  <img width="460" height="300" src="https://github.com/hesheen-GH/Wireless_Communication_System_Simulation/blob/master/pictures/spectrum.PNG">
</p>

After passing the signal through an AWGN channel and demodulating, the BPSK correlator output is:

<p align="center">
  <img width="460" height="300" src="https://github.com/hesheen-GH/Wireless_Communication_System_Simulation/blob/master/pictures/correlatoroutput.PNG">
</p>

The constellaiton diagram is as follows:

<p align="center">
  <img width="460" height="300" src="https://github.com/hesheen-GH/Wireless_Communication_System_Simulation/blob/master/pictures/constellation.PNG">
</p>

The BER performance is:

<p align="center">
  <img width="460" height="300" src=https://github.com/hesheen-GH/Wireless_Communication_System_Simulation/blob/master/pictures/ber.PNG>
</p>

