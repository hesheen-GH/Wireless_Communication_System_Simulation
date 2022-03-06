classdef Channel < handle

    properties
      
      signal;
      noise_power; %default, 0 dB
      Tx;
        
    end 
    
    methods 
        
        
        function obj = Channel(signal,tx)
            obj.signal = signal;
            obj.Tx = tx;
        end 
        
        function output = AWGN(obj,SNR)
            output = obj.signal + sqrt(obj.noise_power).*randn(1,length(obj.signal));
            figure;
            plot(obj.Tx.time,output(1,:));
            title('Modulated Signal + AWGN');
            hold on;
            plot(obj.Tx.time,output(end,:));
            ylabel('Amplitude');
            xlabel('Time (s)');
            legend('SNR = ' + string(SNR(1)) + ' dB', 'SNR = ' + string(SNR(end)) + ' dB');
        end  
        
    end 
    
end