
classdef Transmitter < handle

    properties
        
        bit_sequence;
        num_bits;
        samples_per_bit;
        bit_rate;
        sampling_rate;
        sampling_period;
        IQ_sampling_period;
        IQ_sampling_rate;
        amplitude;
        bit_period;
        time;
        IQ_time;
        center_frequency; 
    end 
    
    methods 
        
        function obj = Transmitter(N,Rb, A, fs)
            
            obj.num_bits = N;
            obj.bit_rate = Rb;
            obj.amplitude = A;     
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
            signal = signal(1,:).*cos(obj.IQ_time*2*pi*fc)+signal(2,:).*sin(obj.IQ_time*2*pi*fc);
          
            figure;
            plot(obj.IQ_time, signal);
            title('QPSK Signal');
            ylabel('Amplitude');
            xlabel('Time (s)');
            N = length(signal);
            xdft = fftshift(fft(signal));
            obj.IQ_sampling_period = obj.IQ_time(2)-obj.IQ_time(1);
            obj.IQ_sampling_rate = 1/obj.IQ_sampling_period;
            ft = obj.IQ_sampling_period*abs(xdft);
            fshift = (-N/2+0.5:N/2-0.5)*((obj.IQ_sampling_rate)/N);     
            figure;
            plot(fshift,ft);
            title('QPSK Signal Spectrum');     
            ylabel('Amplitude');
            xlabel('Frequency (Hz)');
        end 
                       
        function signal = polar_NRZ_encoder(obj, signal)
            
            obj.bit_sequence = signal;
            
            signal = repelem(signal,obj.samples_per_bit);
            signal = (2*signal-1).*obj.amplitude; %scaling amplitude
            obj.time = (0:size(signal,2)-1)./(obj.samples_per_bit*obj.bit_rate);
            figure;
            plot(obj.time,signal);
            title('Polar NRZ Encoded Signal');
            ylabel('Amplitude');
            xlabel('Time (s)');
            axis([0 obj.time(obj.samples_per_bit*obj.num_bits) -obj.amplitude-1 obj.amplitude+1]);

            
            
            signal = obj.serial_to_parallel_coverter(signal);
            obj.IQ_time = (0:size(signal,2)-1)./(obj.samples_per_bit*obj.bit_rate/2);

            
            figure;
            plot(obj.IQ_time,signal(1,:));
            title('Polar NRZ Encoded Signal I-bit stream');
            ylabel('Amplitude');
            xlabel('Time (s)');
            axis([0 obj.IQ_time(obj.samples_per_bit*obj.num_bits/2) -obj.amplitude-1 obj.amplitude+1]);
            figure;
            plot(obj.IQ_time,signal(2,:));
            title('Polar NRZ Encoded Signal Q-bit stream');
            ylabel('Amplitude');
            xlabel('Time (s)');
            axis([0 obj.IQ_time(obj.samples_per_bit*obj.num_bits/2) -obj.amplitude-1 obj.amplitude+1]);
                    
        end     
        
        function output = serial_to_parallel_coverter(obj,signal) 
          
            output_I = [];
            output_Q = [];
            
            x = 0;
            y = 1;
            
            for n = 1:obj.num_bits/2

                I = signal(1+x*obj.samples_per_bit:(x+1)*obj.samples_per_bit);
                Q = signal(1+y*obj.samples_per_bit:(y+1)*obj.samples_per_bit);
                
                output_I = [output_I,I];
                output_Q = [output_Q,Q];
                
                x = x+2;
                y = y+2;
                
            end 
            
            output = [output_I;output_Q];

        end 
    end 
end 