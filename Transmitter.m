
classdef Transmitter < handle

    properties
        
        bit_stream;
        num_bits;
        samples_per_bit;
        bit_rate;
        sampling_rate;
        sampling_period;
        amplitude;
        bit_period;
        PSD;
        time;

        
    end 
    
    methods 
        
        
        function obj = Transmitter()
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
        
        function obj = get_ACF_and_PSD(obj)
            
            [ACF,tau] = xcorr(obj.bit_stream,'biased');
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
            title('Graph 1');
            xlim([-10 10]);
          
            P_avg_TD = (sum(abs(obj.bit_stream).^2))*(obj.sampling_period/obj.time(end));
            P_avg_FD = sum(PSD)*df;
            
            disp(["The Time Domain Power is",P_avg_TD]);
            disp(["The F-Domain Power is ",P_avg_FD]);
            
        end 
        
        function obj = generate_bit_stream(obj)
            
            obj.set_num_of_bits(1000);
            obj.set_samples_per_bit(1000);
            obj.set_bit_rate(1);
            obj.set_signal_amplitude(5);
            
            obj.sampling_rate = obj.samples_per_bit*obj.bit_rate;
            obj.sampling_period = 1/(obj.samples_per_bit*obj.bit_rate);
            obj.bit_period = 1/obj.bit_rate;
                                    
            rng(1,'twister');
            
            RNG=rand(1,obj.num_bits); %generates a vector of length num_bits of numbers uniformly distributes between 0 and 1.
            obj.bit_stream=floor(RNG+0.5); %RNG+0.5 is a vector of numbers uniformly distributed between 0.5 and 1.5. Floor rounds down, so 50 percent should be 1 and 50 percent 0.
            obj.bit_stream = repelem(obj.bit_stream,obj.samples_per_bit); %duplicate each bit by samples per bit times 
            obj.bit_stream = reshape(obj.bit_stream,obj.samples_per_bit,[]); %rearrange into matrix 
            obj.bit_stream = (2*obj.bit_stream-1).*obj.amplitude; %scaling amplitude
            obj.bit_stream = reshape(obj.bit_stream,1,[]); %reshape into 1xN array
            obj.time = (0:length(obj.bit_stream)-1)./(obj.samples_per_bit*obj.bit_rate); %create time axis
            plot(obj.time,obj.bit_stream)
            axis([0 obj.time(obj.samples_per_bit*obj.num_bits) -obj.amplitude-1 obj.amplitude+1])
           
        end 
        
    end 
    
end 