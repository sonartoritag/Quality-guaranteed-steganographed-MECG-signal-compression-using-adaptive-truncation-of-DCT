function[]=firstderiModification()

dec=fopen('DECG','r');
fi_deri=fscanf(dec,'%f');
fclose(dec);

if exist('ascidiff')
    asci=fopen('ascidiff','r');
    diffasci=fscanf(asci,'%f');
    fclose (asci);
    for i=1:2:length(diffasci)
        fi_deri(diffasci(i))=diffasci(i+1);
    end
end


decgg(1)=fi_deri(1);
for i=2:length(fi_deri)
    decgg(i)=fi_deri(i)+decgg(i-1);
end
decgg=decgg';
dlmwrite('DECGG',decgg,'precision','%.3f');
% one=fopen('onedi','r');
% numb=fscanf(dec,'%f');
% 
% plot(decgg,'r:o');
% hold on
% plot(numb,'b:o');
end
