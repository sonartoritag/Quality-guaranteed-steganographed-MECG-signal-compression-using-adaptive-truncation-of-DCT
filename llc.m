function []= llc(ori,naam)

%disp(ori) %need for erroe checking
for j=1:1:8                     %sign bit checking
    if ori(j)<0
        sb(j)=1;
    else
        sb(j)=0;
    end
end
sbte=0;
cnt=0;
for j=8:-1:1                    %sign bit generation
    sbte=sbte+(2^cnt)*sb(j);
    cnt=cnt+1;
end   
sbte=fix(sbte);
%rs=0;
%f=fopen('CECG1','a+');
f=fopen(naam,'a+');
%if sbte==10                     %sign byte checking
    %sbte=11;
    %rs=1;
    
%end

fprintf(f,'%c',sbte);           %sign byte printing
%fprintf('%d ',sbte);


for j=1:1:8                     %-ve numbers are made +ve
    %fprintf('%f ',ori(j));
    if ori(j)<0
        ori(j)=(ori(j)*(-1));
    end
    aori(j)=double((ori(j)*1000));
end
%disp(aori)               %need for erroe checking
aori=uint16(aori);        %..............changed from uint8 to uint16
%disp('aori')               %need for erroe checking
%ii=idivide(int32(aori(1)), int32(255), 'floor');
%ii=fix(double(aori(1)/255));
%disp('ii');            %need for erroe checking
%disp(ii);              %need for erroe checking
%jj=uint16(aori(1));    %need for erroe checking
%disp('jj=')            %need for erroe checking
%disp(jj)               %need for erroe checking
%kk=uint16(255);        %need for erroe checking
%disp('kk=')            %need for erroe checking
%disp(kk)               %need for erroe checking
%ll=rem(jj,kk);         %need for erroe checking
%disp('ll=')            %need for erroe checking
%disp(ll)               %need for erroe checking
%aori(1)=rem(aori(1),255);
%whos
%disp('the value of aori(1)');  %need for erroe checking
%disp(aori)                  %need for erroe checking
%rs=fix((rs*100)+ii);                 %rs+ii
%if rs==1                       %need for erroe checking
    %disp('yes rs is 1');
%end
%if rs==10
    %rs=255;
%end
for j=1:1:8                          %10 is changer to 255
    if aori(j)==10
        aori(j)=255;
    end
end
ci=1;                               %compressed array index
fflag=0;                            %whether all numbers are equal or not
flag=0;                             %whether no grouping or not                      
k=zeros([1,7]);                     %no grouping index
msb=zeros([1,8]);
lsb=zeros([1,8]);
ffflag=0;
ex=0;
if aori(1)==aori(2)&& aori(2)== aori(3)&& aori(3)==aori(4)&& aori(4)==aori(5) && aori(5)==aori(6) && aori(6)==aori(7)&& aori(7)==aori(8)
    comecg=fix(aori(1));
    fflag=1;
    if comecg==10
        comecg=255;
    end 
    %disp('yaaaapppppppppppppppppppppppppppppppppppppp')
    fprintf(f,'%c',comecg);
    %fprintf('%d ',comecg);
    %fprintf(f,'%c',rs);
    %fprintf('%d ',rs);
else
        for i=1:2:7
            if aori(i)<10 && aori(i+1)<10
                comecg(ci)=fix(aori(i)*10+aori(i+1));
                if comecg(ci)==10
                    comecg(ci)=255;
                end
                 %disp(comecg(ci))
                ci=ci+1;
                %disp('hi')
            end
            if aori(i)>=10 || aori(i+1)>=10
                comecg(ci)=aori(i);
                if comecg(ci)==10
                    comecg(ci)=255;
                end
                 %disp(comecg(ci))
                k(ci)=1;
                comecg(ci+1)=aori(i+1);
                if comecg(ci+1)==10
                    comecg(ci+1)=255;
                end
                %disp(comecg(ci+1))
                k(ci+1)=1;
                ci=ci+2;
                flag=1;
                %disp('hiiiiiiiiiiiii')
            end
        end
end
if flag==0 && fflag==0
    %if comecg(1)==comecg(2)&& comecg(3)== comecg(4)
        if comecg(1)<=15 && comecg(2)<=15 && comecg(3)<=15 && comecg(4)<=15
            msb(1:4)=fliplr(de2bi(comecg(1),4));
            msb(5:8)=fliplr(de2bi(comecg(2),4));
            mmsb=bi2de(msb,'left-msb');
            lsb(1:4)=fliplr(de2bi(comecg(3),4));
            lsb(5:8)=fliplr(de2bi(comecg(4),4));
            llsb=bi2de(lsb,'left-msb');
            %disp('yessssssssssssssssssssssssssssssssssssssssssssssss')
            fprintf(f,'%c',mmsb);
            %fprintf('%d ',mmsb);
            fprintf(f,'%c',llsb);
            %fprintf('%d ',llsb);
            %,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,fprintf(f,'%c',rs);
            %fprintf('%d ',rs);
            ffflag=1;
        end
    %end
end

[ro co]=size(comecg);
%disp(k)
if ffflag==0 && co>=4
    for i=1:1:co
        if i==8 && (comecg(8)==1 || comecg(8)==2 || comecg(8)==3 || comecg(8)==4)
            ex=1;
        end
        if i==8 && (comecg(8)==63 || comecg(8)==126 || comecg(8)==111 || comecg(8)==123)
            if comecg(8)==63
                comecg(8)=1;
            end
            if comecg(8)==126
                comecg(8)=2;
            end
            if comecg(8)==111
                comecg(8)=3;
            end
            if comecg(8)==123
                comecg(8)=4;
            end
        end

            fprintf(f,'%c',comecg(i));
            %fprintf('%d ',comecg(i));
     end
    if co==5 || co==6 || co==7
        kk=fix(bi2de(k,'left-msb'));
        fprintf(f,'%c',kk);
        %fprintf('%d ',kk);
        %disp('kk');
    end
    if ex==1
        fprintf(f,'%c',ex);
        %fprintf('%d ',ex);
        %disp('ex');
    end
    %fprintf(f,'%c',rs);
    %fprintf('rs=%d ',rs);
end
   %disp(comecg)
fprintf(f,'\n');
%fprintf('\n');
fclose(f);
end
