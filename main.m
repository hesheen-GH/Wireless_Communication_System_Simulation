%% Monte-Carlo BER Simulation of BPSK Correlation Receiver in AWGN Channel
%% Author: Yaseen Naas, yaseen.naas@gmail.com

clear all;
close all;
clc;

%% Pseudorandom binary sequence (PRBS)
N = 10000; %number of bits 
%generates a vector of length num_bits of numbers uniformly distributes between 0 and 1.
rng(1,'twister');
signal=floor(rand(1,N)+0.5); %RNG+0.5 is a vector of numbers uniformly distributed between 0.5 and 1.5. Floor rounds down, so 50 percent should be 1 and 50 percent 0.

%% User Defined Bit Sequence
%signal = [1 0 1 0 1 1];

%% main.m
Rb = 1; %bit rate
fc = 80*Rb; %carrier frequency
fs = 4*(fc+Rb); %Nyquist Sampling Rate
A = 5; %amplitude

tx = Transmitter(N,Rb,A,fs);
signal = tx.polar_NRZ_encoder(signal);
signal = tx.modulator(signal,fc);

SNR = 0:0.1:15; %in dB

Eb = (tx.amplitude^2)*tx.samples_per_bit/2; %Energy per bit for BPSK
channel = Channel(signal,tx);
channel.noise_power = (Eb./(2*10.^(SNR/10)))';
signal = channel.AWGN(SNR);

rx = Receiver(tx);
signal = rx.bpsk_correlator(signal,SNR);
signal = rx.sampler(signal,SNR);
rx.constellation(signal,SNR);
BER = rx.BERT(signal);
figure;
BER = reshape(BER(1,1,:),[],1);
semilogy(SNR,BER');
hold on;
grid on;
semilogy(SNR,qfunc(sqrt(2*10.^(SNR/10))));
title('BER Performance of BPSK in AWGN Channel');
ylabel('Probability');
xlabel('Eb/No (dB)');
legend('Experimental BPSK','Theoretical BPSK');
ylim([10^-6 0.1]);
