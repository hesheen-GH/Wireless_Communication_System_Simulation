%% Time-Dependent Monte-Carlo BER/SER Simulation of QPSK Correlation Receiver in AWGN Channel
%% Author: Yaseen Naas, yaseen.naas@gmail.com

clear all;
close all;
clc;

%% Pseudorandom binary sequence (PRBS)
N = 10; %number of bits, must be even
%generates a vector of length num_bits of numbers uniformly distributes between 0 and 1.
rng(1,'twister');
signal=floor(rand(1,N)+0.5); %RNG+0.5 is a vector of numbers uniformly distributed between 0.5 and 1.5. Floor rounds down, so 50 percent should be 1 and 50 percent 0.

%% User Defined Bit Sequence
%signal = [1 0 1 0];

%% main.m
Rb = 1; %bit rate
fc = 45*Rb; %carrier frequency
fs = 8*(fc+Rb); %Nyquist Sampling Rate
A = 5; %amplitude
M = 4; %M-ary

tx = Transmitter(N,Rb,A,fs,M);
signal = tx.polar_NRZ_encoder(signal);
signal = tx.modulator(signal,fc);

SNR = 0:0.1:15; %in dB

Eb = (tx.amplitude^2)*tx.samples_per_bit/2; %Energy per bit for QPSK
channel = Channel(signal,tx);
channel.noise_power = (Eb./(2*10.^(SNR/10)))';
signal = channel.AWGN(SNR);

rx = Receiver(tx);
[output1, output2] = rx.correlator(signal,SNR);
[output1, output2] = rx.sampler(output1,output2,SNR);
rx.constellation(output1,output2,SNR);
[BER,SER] = rx.BERT(output1,output2);
figure;
%BER = reshape(BER(1,1,:),[],1);
semilogy(SNR,BER);
hold on;
semilogy(SNR,SER);
hold on;
grid on;
semilogy(SNR,qfunc(sqrt(2*10.^(SNR/10))));
hold on;
semilogy(SNR,erfc(sqrt(10.^(SNR/10)))-(1/4)*(erfc(sqrt(10.^(SNR/10)))).^2);
title('BER/SER Performance of QPSK in AWGN Channel');
ylabel('Probability');
xlabel('Eb/No (dB)');
legend('Experimental BER QPSK','Experimental SER QPSK','Theoretical BER QPSK','Theoretical SER QPSK');
ylim([10^-6 0.1]);
hold off;
