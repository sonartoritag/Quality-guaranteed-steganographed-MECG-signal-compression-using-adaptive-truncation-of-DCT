clc; clear; close all; fclose all;
[file1]=uigetfile('*.mat', 'MultiSelect','on');
output_file = fopen('Result_Table.xls','a+');
fprintf(output_file, 'File Name\tNo_sample\tUDWEDD\tEstim_Max_PRD\tLead_No\tEstim_Avg_PRD\tEstim_Max_WEDD\tLead_No\tEstim_Avg_WEDD\tDCT_factor\tSingular_values\tActual_Max_PRD\tLead_No\tActual_Avg_PRD\tActual_Max_WEDD\tLead_No\tActual_Avg_WEDD\tCR\n');
for ii=1:length(file1)
    try
        close all;
        fprintf(file1{ii});
        fprintf('\t\t\t%d/%d',length(file1), ii);
        fprintf('\n');
        %b=dlmread([file1]);
        load(file1{ii});
        output_file = fopen('Result_Table.xls','a+');
        fprintf(output_file, '%s\t%d\t', file1{ii},size(val,2));
        fclose (output_file);
        fs = 1000;
        val = val';
        %val(4001:end,:)=[];
        %fs=input('\nEnter the Sampling frequency of the ECG signal in Hertz = ');
        
        fprintf('Wait.. ');
        for kk=1:1:12
            %voltage = b(kk, 1:end);
            %time = b(1:end,1);
            voltage = val(:,kk);
            [B,A] =butter(2, 2*100/fs, 'low');
            v = filtfilt(B,A,voltage);
            [B,A] =butter(2, 2*0.9/fs, 'high');
            v = filtfilt(B,A,v);
%             w = 'bior6.8';
%             n = 10;
%             [C,L] = wavedec(voltage,n,w);
%               for i = 1:n
%                   A(i,:) = wrcoef('a',C,L,w,i);
%                   D(i,:) = wrcoef('d',C,L,w,i);
%               end
%                 bs=A(10,:)';
%                 v=voltage-bs;
%                 hf=D(2,:)+D(1,:);
%                 hf=hf';
%                 v=v-hf;
            rec(:,kk+1)=v;
            fprintf('%d  ',kk);
        end
        [r,c] = size(val);
        time = (0:r-1)*(1/fs);
        rec(:,1)=time;%(1:50000);
        dlmwrite('Noise Free ECG signal',rec,'delimiter','\t','precision','%.3f');
        fprintf('\n Filtering is done...');
        fprintf('\n=============================================================\n');
        DCT_SVD_MECG_Compression(fs);
        %fclose all;
        %delete('Original ECG', 'Noise Free ECG signal');
        clearvars -except ii file1;
    catch
        fclose all;
        delete('Original ECG', 'Noise Free ECG signal', 'DECG', 'DECGG', 'VVV', 'ascidiff');
        d = dir;
        filenames = {d.name};
        for i = 1:length(filenames)
            fn = filenames{i};
            if length(fn)>4 && fn(end-3)=='1'&& fn(end-2)=='0' && fn(end-1)=='0' && fn(end)=='0'
                delete(fn);
            end
        end
        %continue
    end        
end