
classdef Transmitter < handle

    properties
        
        bit_sequence
        num_bits;
        samples_per_bit;
        bit_rate;
        sampling_rate;
        sampling_period;
        amplitude;
        bit_period;
        time;
        center_frequency;    
    end 
    
    methods 
        
        function obj = Transmitter(N,Rb, A, fs)
            
            obj.num_bits = N;
            %obj.samples_per_bit = samples_per_bit;
            obj.bit_rate = Rb;
            obj.amplitude = A;     
            %obj.sampling_rate = obj.samples_per_bit*obj.bit_rate;
            obj.sampling_rate = fs;
            obj.samples_per_bit = obj.sampling_rate/obj.bit_rate;
            
            obj.sampling_period = 1/(obj.sampling_rate);
            obj.bit_period = 1/obj.bit_rate;
               
        end 
             
        function obj = set_signal_amplitude(obj,amplitude)
            obj.amplitude = amplitude;
        end  
        
        function obj = set_bit_rate(obj,bit_rate)
            obj.bit_rate = bit_rate;
        end  
        
        function obj = set_samples_per_bit(obj,samples)
            obj.samples_per_bit = samples;
        end  
        
        function obj = set_num_of_bits(obj,bits)
            obj.num_bits = bits;
        end  
        
        function obj = get_ACF_and_PSD(obj,signal)
            
            [ACF,tau] = xcorr(signal,'biased');
            tau = obj.sampling_period*tau;
            figure;
            plot(tau,ACF);
            %xlim([-20 20]);     
            %ylim([0 25]);
            N = length(ACF);
            fshift = (-N/2+0.5:N/2-0.5)*((obj.sampling_rate)/N);
            df = fshift(2)-fshift(1);
            PSD = obj.sampling_period*abs((fftshift(fft(ACF,N))));
            figure;
            plot(fshift,PSD);
            title('Power Spectral Density');
            xlim([-20 20]);
            P_avg_TD = (sum(abs(signal).^2))*(obj.sampling_period/obj.time(end));
            P_avg_FD = sum(PSD)*df;           
            disp(["The Time Domain Power is",P_avg_TD]);
            disp(["The F-Domain Power is ",P_avg_FD]);
            
        end 
        
        function signal = modulator(obj,signal,fc)
            
            obj.center_frequency = fc;
            signal = signal.*cos(obj.time*2*pi*fc);
            figure;
            plot(obj.time, signal);
            title('Modulated BPSK Signal');
            ylabel('Amplitude');
            xlabel('Time (s)');
            N = length(signal);
            xdft = fftshift(fft(signal));
            %xdft =  xdft(1:N/2+1);
            %psdx = (obj.sampling_period/N) * abs(xdft).^2;
            ft = obj.sampling_period*abs(xdft);
            %psdx(2:end-1) = 2*psdx(2:end-1);
            fshift = (-N/2+0.5:N/2-0.5)*((obj.sampling_rate)/N);     
            figure;
            plot(fshift,ft);
            title('Modulated BPSK Signal Spectrum');     
            ylabel('Amplitude');
            xlabel('Frequency (Hz)');
        end 
               
        function signal = polar_NRZ_encoder(obj, signal)
            
            obj.bit_sequence = signal;
            signal = repelem(signal,obj.samples_per_bit); %duplicate each bit by samples per bit times 
            signal = reshape(signal,obj.samples_per_bit,[]); %rearrange into matrix 
            signal = (2*signal-1).*obj.amplitude; %scaling amplitude
            signal = reshape(signal,1,[]); %reshape into 1xN array
            obj.time = (0:length(signal)-1)./(obj.samples_per_bit*obj.bit_rate); %create time axis
            plot(obj.time,signal);
            title('Polar NRZ Encoded Signal');
            ylabel('Amplitude');
            xlabel('Time (s)');
            axis([0 obj.time(obj.samples_per_bit*obj.num_bits) -obj.amplitude-1 obj.amplitude+1]);
                    
        end      
    end 
end 