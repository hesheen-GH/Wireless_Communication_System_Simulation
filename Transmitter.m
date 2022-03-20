
classdef Transmitter < handle

    properties
        
        %modulation_scheme;
        M
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
        gray_vector;
        row_all_zeros;
    end 
    
    methods 
        
        function obj = Transmitter(N,Rb, A, fs, M_ary)
            
            obj.num_bits = N;
            %obj.samples_per_bit = samples_per_bit;
            obj.bit_rate = Rb;
            obj.amplitude = A;     
            %obj.sampling_rate = obj.samples_per_bit*obj.bit_rate;
            obj.sampling_rate = fs;
            obj.samples_per_bit = obj.sampling_rate/obj.bit_rate;
            
            obj.sampling_period = 1/(obj.sampling_rate);
            obj.bit_period = 1/obj.bit_rate;
            %obj.modulation_scheme = modulation;
            obj.M = M_ary;
               
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
            
%             for x = 0:obj.M-1
%                 
%                 modulation_matrix(x+1,:) = cos(2*pi*obj.center_frequency.*obj.time ...
%                     + ((2*pi*x)/obj.M));
%                 
%             end 
%             
%             Tb = obj.samples_per_bit;
%             w = 0;
%             output = [];
%             
%             for x = 1:length(obj.row_all_zeros)
%                 
%                 y = abs(signal(1+w:(log2(obj.M)*Tb+w))).*modulation_matrix(obj.row_all_zeros(x),(1):((log2(obj.M)*Tb)));
%                 w = x*log2(obj.M)*obj.samples_per_bit;
%                 output = [output y];
%                 
%             end 
%             
%             signal = output;
            
            
            signal = signal(1,:).*cos(obj.IQ_time*2*pi*fc)+signal(2,:).*sin(obj.IQ_time*2*pi*fc);
            
            %signal = signal(2,:) + signal(1,:);
            
            figure;
            plot(obj.IQ_time, signal);
            title('QPSK Signal');
            ylabel('Amplitude');
            xlabel('Time (s)');
            N = length(signal);
            xdft = fftshift(fft(signal));
            %xdft =  xdft(1:N/2+1);
            %psdx = (obj.sampling_period/N) * abs(xdft).^2;
            obj.IQ_sampling_period = obj.IQ_time(2)-obj.IQ_time(1);
            obj.IQ_sampling_rate = 1/obj.IQ_sampling_period;
            ft = obj.IQ_sampling_period*abs(xdft);
            %psdx(2:end-1) = 2*psdx(2:end-1);
            fshift = (-N/2+0.5:N/2-0.5)*((obj.IQ_sampling_rate)/N);     
            figure;
            plot(fshift,ft);
            title('QPSK Signal Spectrum');     
            ylabel('Amplitude');
            xlabel('Frequency (Hz)');
        end 
        
        function result = gray_code_generator(obj,bits)
            
            if (bits<1)
                disp('Sorry, number of bits should be positive');
            elseif (mod(bits,1)~=0)
                disp('Sorry, number of bits can only be positive integers');
            else
                initial_container = [0;1];
                if bits == 1
                    result = initial_container;
                else
                    previous_container = initial_container;
                    for i=2:bits
                        new_gray_container = zeros(2^i,i);
                        new_gray_container(1:(2^i)/2,1) = 0;
                        new_gray_container(((2^i)/2)+1:end,1) = 1;

                        for j = 1:(2^i)/2
                            new_gray_container(j,2:end) = previous_container(j,:);
                        end

                        for j = ((2^i)/2)+1:2^i
                            new_gray_container(j,2:end) = previous_container((2^i)+1-j,:);
                        end

                        previous_container = new_gray_container;
                    end
                    result = previous_container;
                end
                fprintf('Gray code of %d bits',bits);
                disp(' ');
                disp(result);
            end 
            
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
            %gray_vector = obj.gray_code_generator(log2(obj.M));
            
            
%             for x = 1:size(signal,1)
%             
%                 distance = abs(bsxfun(@minus, gray_vector, signal(x,:)));
%                 obj.row_all_zeros(x) = find(all(distance == 0,2));
%                    
%             end 
            
            
%             I = repelem(signal(1,:),obj.samples_per_bit);
%             Q = repelem(signal(2,:),obj.samples_per_bit);
%             
%             signal = [I;Q];
                 
            
            %signal = repelem(signal,obj.samples_per_bit); %duplicate each bit by samples per bit times 
            %signal = reshape(signal,obj.samples_per_bit,[]); %rearrange into matrix 
            %signal = reshape(signal,1,[]); %reshape into 1xN array
             %create time axis
            
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
%           
            output_I = [];
            output_Q = [];
            
            x = 0;
            y = 1;
%             
            for n = 1:obj.num_bits/2

                I = signal(1+x*obj.samples_per_bit:(x+1)*obj.samples_per_bit);
                Q = signal(1+y*obj.samples_per_bit:(y+1)*obj.samples_per_bit);
                
                output_I = [output_I,I];
                output_Q = [output_Q,Q];
                
                x = x+2;
                y = y+2;
                
            end 
            
            output = [output_I;output_Q];

% %             w = 0;    
% %             
% %             for x = 1:(length(signal)/log2(obj.M)) 
% %             
% %                 %output(x,:) = signal(x:log2(obj.M):end);
% %                 
% %                 output(x,:) = signal(1+w:1:log2(obj.M)+w);
% %                 w = w+log2(obj.M);
% %             
% %             end     
%             
%             %output = output';
        end 
    end 
end 