classdef Receiver < handle
    
    properties 
        
        signal;
        Tx;
    end
    methods 
        
        
        function obj = Receiver(tx)
            
            obj.Tx = tx; 
        end 
        
        function [BER,SER] = BERT(obj,signal1,signal2)
            
            Ts = obj.Tx.bit_period*2;
            bit_sequence = [];                   
                               
            for x=1:size(signal1,1)
                
                for y=1:size(signal1,2)
                    
                    distance_00 = sqrt((-obj.Tx.amplitude*sqrt(Ts/2)-signal1(x,y))^2+(-obj.Tx.amplitude*sqrt(Ts/2)-signal2(x,y))^2);
                    distance_01 = sqrt((-obj.Tx.amplitude*sqrt(Ts/2)-signal1(x,y))^2+(obj.Tx.amplitude*sqrt(Ts/2)-signal2(x,y))^2);
                    distance_10 = sqrt((obj.Tx.amplitude*sqrt(Ts/2)-signal1(x,y))^2+(-obj.Tx.amplitude*sqrt(Ts/2)-signal2(x,y))^2);
                    distance_11 = sqrt((obj.Tx.amplitude*sqrt(Ts/2)-signal1(x,y))^2+(obj.Tx.amplitude*sqrt(Ts/2)-signal2(x,y))^2);
                    
                    distance = [distance_00, distance_01, distance_10, distance_11];
                    [distance,index] = min(distance);
                    
                    switch index
                        case 1
                            bit_sequence = [bit_sequence,0,0];
                        case 2
                            bit_sequence = [bit_sequence,0,1];
                        case 3
                            bit_sequence = [bit_sequence,1,0];
                        case 4
                            bit_sequence = [bit_sequence,1,1];
                    end 
                    
                end 
                
                BER(x) = sum(xor(obj.Tx.bit_sequence,bit_sequence))/length(obj.Tx.bit_sequence);
                ser = xor(obj.Tx.bit_sequence,bit_sequence);
                SER(x) = sum(or(ser(1:2:end),ser(2:2:end)))/(length(obj.Tx.bit_sequence)/2);
                bit_sequence = [];
                 
            end 

        end 
        
        function [output1,output2] = sampler(obj,signal1,signal2,SNR)
            
            output1 = signal1(:,obj.Tx.samples_per_bit:obj.Tx.samples_per_bit:end);
            output2 = signal2(:,obj.Tx.samples_per_bit:obj.Tx.samples_per_bit:end);
            
            figure;
            stem(output1(1,:));
            title('Sampled Correlator I - Output');
            hold on;
            stem(output1(end,:));       
            ylabel('Amplitude');
            xlabel('n*Ts');
            legend('SNR = ' + string(SNR(1)) + ' dB', 'SNR = ' + string(SNR(end)) + ' dB');
            hold off;
            
            figure;
            stem(output2(1,:));
            title('Sampled Correlator Q - Output');
            hold on;
            stem(output2(end,:));       
            ylabel('Amplitude');
            xlabel('n*Ts');
            legend('SNR = ' + string(SNR(1)) + ' dB', 'SNR = ' + string(SNR(end)) + ' dB');
            hold off;

        end 
        
        
        function [] = constellation(obj,signal1,signal2,SNR)
            
            figure;
            scatter(signal1(1,:),signal2(1,:),'filled');
            title('QPSK Constellation Diagram');
            grid on;
            hold on;
            scatter(signal1(end,:),signal2(end,:),'filled');
            hold on;
            Ts = obj.Tx.bit_period*2;
            scatter(obj.Tx.amplitude*sqrt(Ts/2),obj.Tx.amplitude*sqrt(Ts/2),60,'green', 'filled');
            hold on;
            scatter(-obj.Tx.amplitude*sqrt(Ts/2),obj.Tx.amplitude*sqrt(Ts/2),60,'green', 'filled');
            hold on;
            scatter(obj.Tx.amplitude*sqrt(Ts/2),-obj.Tx.amplitude*sqrt(Ts/2),60,'green', 'filled');
            hold on;
            scatter(-obj.Tx.amplitude*sqrt(Ts/2),-obj.Tx.amplitude*sqrt(Ts/2),60,'green', 'filled');
            hold on;
            xlabel('Ψ0(t)');
            ylabel('Ψ1(t)');
            yline(0);
            xline(0);
            legend('SNR = ' + string(SNR(1)) + ' dB', 'SNR = ' + string(SNR(end)) + ' dB','(±A*sqrt(Ts/2),±A*sqrt(Ts/2))');
            hold off;
           
        end 
        
        
        function [output1,output2] = correlator(obj,signal,SNR)            
            
            Ts = 2*obj.Tx.bit_period;
            t = obj.Tx.IQ_time;
            g_T = sqrt(2/Ts)*ones(1,length(t));
            basis1 = g_T.*cos(2*pi*obj.Tx.center_frequency.*t);
            basis2 = g_T.*sin(2*pi*obj.Tx.center_frequency.*t);
                
            w = 0; 
            nTs = obj.Tx.IQ_sampling_rate/(obj.Tx.bit_rate/2); %samples per bit for QPSK 
            %nTs = obj.Tx.samples_per_bit;
            output1 = zeros(obj.Tx.num_bits/2,length(SNR),nTs);
            output2 = zeros(obj.Tx.num_bits/2,length(SNR),nTs);
            
            for j = 1:obj.Tx.num_bits/2
                
                y1 = cumtrapz(t((1+w):(nTs+w)),signal(:,(1+w):(nTs+w)).*basis1((1+w):(nTs+w)),2);
                y2 = cumtrapz(t((1+w):(nTs+w)),signal(:,(1+w):(nTs+w)).*basis2((1+w):(nTs+w)),2);
                output1(j,:,:) = y1;
                output2(j,:,:) = y2;
                
                w = j*nTs;   
            end 
            
            output1 = permute(output1,[2 3 1]);
            output2 = permute(output2,[2 3 1]);
                       
            output1= reshape(output1,[size(output1,1), size(output1,2)*size(output1,3)]);
            output2= reshape(output2,[size(output2,1), size(output2,2)*size(output2,3)]);
            
            figure;
            plot(obj.Tx.IQ_time,output1(1,:));
            title('QPSK Correlator I-Output');
            hold on;
            plot(obj.Tx.IQ_time,output1(end,:));
            ylabel('Amplitude');
            xlabel('Time (s)');
            legend('SNR = ' + string(SNR(1)) + ' dB', 'SNR = ' + string(SNR(end)) + ' dB');
            hold off;
            
            figure;
            plot(obj.Tx.IQ_time,output2(1,:));
            title('QPSK Correlator Q-Output');
            hold on;
            plot(obj.Tx.IQ_time,output2(end,:));
            ylabel('Amplitude');
            xlabel('Time (s)');
            legend('SNR = ' + string(SNR(1)) + ' dB', 'SNR = ' + string(SNR(end)) + ' dB');
            hold off;
        end  
        
    end 
    
end