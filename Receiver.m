classdef Receiver < handle
    
    properties 
        
        signal;
        Tx;
    end
    methods 
        
        
        function obj = Receiver(tx)
            
            obj.Tx = tx; 
        end 
        
        function BER = BERT(obj,signal)
            
            constellation_points = [obj.Tx.amplitude*sqrt(obj.Tx.bit_period/2); -obj.Tx.amplitude*sqrt(obj.Tx.bit_period/2)];
            signal = reshape(signal.',[1,size(signal.')]);
            distance = abs(bsxfun(@minus, constellation_points, signal));
            distance = permute(distance, [2 1 3]);          
            [min_distance, index] = min(distance,[],2);
            index = permute(index, [2 1 3]);
            index(index>=2)=0;
            BER = sum(xor(obj.Tx.bit_sequence,index))/length(obj.Tx.bit_sequence);
        end 
        
        function output = sampler(obj,signal,SNR)
            output = signal(:,obj.Tx.samples_per_bit:obj.Tx.samples_per_bit:end);
            figure;
            stem(output(1,:));
            title('Sampled Correlator Output');
            hold on;
            stem(output(end,:));       
            ylabel('Amplitude');
            xlabel('n*Tb');
            legend('SNR = ' + string(SNR(1)) + ' dB', 'SNR = ' + string(SNR(end)) + ' dB');

        end 
        
        
        function [] = constellation(obj,signal,SNR)
            
            figure;
            scatter(signal(1,:),zeros(size(signal,2),1));
            title('BPSK Constellation Diagram');
            grid on;
            hold on;
            scatter(signal(end,:),zeros(size(signal,2),1));
            hold on;
            scatter([obj.Tx.amplitude*sqrt(obj.Tx.bit_period/2); -obj.Tx.amplitude*sqrt(obj.Tx.bit_period/2)] ,zeros(2,1),60,'green', 'filled');
            xlabel('Ψ1(t)');
            yline(0);
            xline(0);
            legend('SNR = ' + string(SNR(1)) + ' dB', 'SNR = ' + string(SNR(end)) + ' dB','A*sqrt(Tb/2)','x=0','y=0');


        end 
        
        
        function output = bpsk_correlator(obj,signal,SNR)
            
            %t = 0:obj.Tx.sampling_period:obj.Tx.bit_period-obj.Tx.sampling_period;
            
            t = obj.Tx.time;
            g_T = sqrt(2/obj.Tx.bit_period)*ones(1,length(t));
            basis = g_T.*cos(2*pi*obj.Tx.center_frequency.*t);
                
            w = 0; 
            Tb = obj.Tx.samples_per_bit;
            output = zeros(obj.Tx.num_bits,length(SNR),obj.Tx.samples_per_bit);
            
            %figure;
            %plot(obj.Tx.time,signal(1,:).*basis);
            
            for j = 1:obj.Tx.num_bits
                
                y = cumtrapz(t((1+w):(Tb+w)),signal(:,(1+w):(Tb+w)).*basis((1+w):(Tb+w)),2);
                
                output(j,:,:) = y;
                
                w = j*obj.Tx.samples_per_bit;
                %t = t + obj.Tx.bit_period;
                
            end 
            
            output = permute(output,[2 3 1]);
            
%             g_T = sqrt(2/obj.Tx.bit_period)*ones(1,length(obj.Tx.time));
%             basis = g_T.*cos(2*pi*obj.Tx.center_frequency.*obj.Tx.time);
%             figure;
%             plot(obj.Tx.time,obj.signal.*basis);
%             title('test');
%           
                    
%             for j = 1:obj.Tx.num_bits
%                 for i = 1:(l_t)            
%                     y(j,i)=sum(obj.signal((1+w):(i+w)).*basis((1:i)));
%                     y(j,i)=trapz(t,obj.signal((1+w):(l_t+w)).*basis);
%                 end 
%                 w = j*obj.Tx.samples_per_bit;
%                 t = t + obj.Tx.bit_period;
%             end 
%             
            
            output= reshape(output,[size(output,1), size(output,2)*size(output,3)]);
            figure;
            plot(obj.Tx.time,output(1,:));
            title('BPSK Correlator Output');
            hold on;
            plot(obj.Tx.time,output(end,:));
            ylabel('Amplitude');
            xlabel('Time (s)');
            legend('SNR = ' + string(SNR(1)) + ' dB', 'SNR = ' + string(SNR(end)) + ' dB');
            
        end  
        
    end 
    
end