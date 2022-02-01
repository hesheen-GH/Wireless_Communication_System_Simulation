clear all;
close all;
clc;

tx = Transmitter();
tx.generate_bit_stream();
tx.get_ACF_and_PSD();


