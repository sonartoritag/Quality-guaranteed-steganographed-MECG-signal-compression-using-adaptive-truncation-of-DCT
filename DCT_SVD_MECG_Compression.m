function []=DCT_SVD_MECG_Compression(sf)
    %clear; close all; fclose all;
    currentCharacterEncoding = slCharacterEncoding('ISO-8859-1');
    load('Noise Free ECG signal')
    b = Noise_Free_ECG_signal;
    orit=b(1:end,1);
    %==============================================================================================Downsampling
    % sf=input('Enter the sampling frequency of the ECG signal= ');
    %sf=1000;
    ds=sf/250;
    if ds<2
        ds=1;
    else
        ds=fix(ds);
    end
    fprintf('\nDownsampling factor=%d\n',ds);
    tic
    l=length(orit);
    sint=ds/sf;
    e1=b(1:end,8); %============================================================Lead v1
    l1 = downsample(e1,ds);
    e2=b(1:end,9); %============================================================Lead v2
    l2 = downsample(e2,ds);
    e3=b(1:end,10); %===========================================================Lead V3
    l3 = downsample(e3,ds);
    e9=b(1:end,11); %===========================================================Lead V4
    l4 = downsample(e9,ds);
    e10=b(1:end,12); %==========================================================Lead V5
    l5 = downsample(e10,ds);
    e11=b(1:end,13); %==========================================================Lead V6
    l6 = downsample(e11,ds);
    e12=b(1:end,2); %===========================================================Lead I
    l7 = downsample(e12,ds);
    e13=b(1:end,3); %===========================================================Lead II
    l8 = downsample(e13,ds);
    originalECG=cat(2,e1,e2,e3,e9,e10,e11,e12,e13);
    [r,c]=size(originalECG);
    OE=(round(reshape(originalECG,[1,r*c]),3))';
    samintval=round(1/sf,3);
    tm = (0:r*c-1)*samintval;
    dlmwrite('Original ECG',OE,'precision','%.3f');
    ecg = cat(2,l1,l2,l3,l4,l5,l6,l7,l8);%======================================2D ECG matrix
    %============================================================================Amplitude normalization factor
    for i=1:8
        mx(i)=max(abs(ecg(:,i)));
        ecg(:,i)=ecg(:,i)./mx(i);
    end
    %===========================================================================DCT
    dctecg=round(dct2(ecg),3);
    %===========================================================================Optimum DCT & SVD
    [rr, c]=size(dctecg);
    dctfactor=0.1;
    flag=0;
    fprintf('\n Wait ');
    VAR=1;
    while (1)
        fprintf('.  ');
        N=1;
        darin=dctecg(1:fix(rr*dctfactor),:);
        [U, S, V] = svd(darin);
        while (1)
            clearvars tmparin;
            clearvars rec;
            SN = zeros(N,N);
            for i=1:N
                SN(i,i)=S(i,i);
            end
            Usmaller = round(U(:,1:N),3);
            Vsmaller = round(V(:,1:N),3);
            tmparin = Usmaller*SN*(Vsmaller');
            regecg=zeros(rr,8);
            regecg(1:fix(rr*dctfactor),:)=tmparin;
            iarin=idct2(regecg);
            [row,col]=size(iarin);
            for i=1:8
                iiarin(1:row,i)=iarin(:,i).*mx(i);
            end
            if ds>1
                iiarin=intrpltn(iiarin,orit,sint);
            end
            for wi=1:8
                OE = originalECG(:,wi);
                test = iiarin(:,wi);
                wedd(wi)=wed(OE,test,sf);
            end
            for wi=1:8
                a=originalECG(:,wi);
                c=iiarin(:,wi);
                prd(wi)=sqrt(sum((a-c).*(a-c))/sum(a.*a))*100;
            end
            [weddmx,posi]=max(wedd);
            [prdmx,posii]=max(prd);
            UDPRD = 9.0;
            UDWEDD = 6.914;
            TEST1(VAR)=min(wedd);
            TEST2(VAR)=min(prd);
            VAR=VAR+1;
            if max(wedd)<=UDWEDD %weddmx<=UDWEDD %prdmx<=UDPRD % weddmx<=UDWEDD &&   %weddmx<=4.517 %if prdmx<=9 %weddmx<=6.914 && prdmx<=9
                flag=1;
                break;
            else
                N=N+1;
            end
            [rro,cco]=size(S);
            if N>cco
                break;
            end
        end
        if flag==1
            break;
        end
        dctfactor=dctfactor+0.1;
    end
    fprintf('\n DCT truncation factor = %0.2f%%',dctfactor*100);
    fprintf('\n Optimum Singular Value = %d',N);
    fprintf('\n Max. WEDD Value and Lead no.= %0.2f %c, %d',weddmx,37,posi);
    fprintf('\n Max. PRD Value and Lead no.= %0.2f %c, %d',prdmx,37,posii);
    fprintf('\n Meam. PRD Value = %0.2f',mean(prd));
    %fprintf('\n PRD = %0.2f',prd);
    %fprintf('\n WEDD = %0.2f',wedd);
    output_file = fopen('Result_Table.xls','a+');
    fprintf(output_file, '%0.3f\t%0.2f\t%d\t%0.2f\t%0.2f\t%d\t%0.2f\t%0.2f\t%d\t', UDWEDD, prdmx, posii, mean(prd), weddmx, posi, mean(wedd), dctfactor*100, N);
    fclose (output_file);

    for i=1:N
        SN(i,i)=S(i,i);
    end
    Usmaller = round(U(:,1:N),3);
    Vsmaller = round(V(:,1:N),3);
    %===========================================================================16-bit quantization of the Vsmaller martix's coefficients
    [ro, co]=size(Vsmaller);
    k=1;
    for i=1:ro
        for j=1:co
            VV(k)=Vsmaller(i,j);
            k=k+1;
        end
    end
    B=16;
    L=2^B;
    D=(max(VV)-min(VV))/L;
    j=1;
    for i=min(VV):D:max(VV)
        ds(j)=round(i,3);
        j=j+1;
    end
    vvv=fopen('VVV','w');
    fprintf(vvv,'%0.3f %0.3f ',max(VV),min(VV));
    k=1;
    for i=1:length(VV)
        n=VV(i);
        flag=0;
        for j=1:length(ds)-1
            if n>=ds(j)&& n<=ds(j+1)
                if n>=ds(j)&& n<=(ds(j)+ds(j+1))/2
                    bin=fliplr(de2bi(j-1,16));
                else
                    bin=fliplr(de2bi(j,16));
                end
                if i==1
                    for l=1:2:15
                        binn(1:2)=bin(l:l+1);
                        temp=bi2de(binn,'left-msb');
                        fprintf(vvv,'%c',temp);
                        des(k)=temp;
                        k=k+1;
                    end
                else
                    msb(1:8)=bin(1:8);
                    lsb(1:8)=bin(9:16);
                    msbb=bi2de(msb,'left-msb');
                    lsbb=bi2de(lsb,'left-msb');
                    des(k)=msbb;
                    des(k+1)=lsbb;
                    fprintf(vvv,'%c%c',msbb,lsbb);
                    k=k+2;
                    flag=1;
                end
                break;
            end
        end
    end
    fclose (vvv);
    %===========================================================================Printing the Singular values
    naam=strcat(num2str(N),'_',num2str(sf));
    f=fopen(naam,'a+');
    fprintf(f,'%d ',length(orit));
    [r,c]=size(Usmaller);
    fprintf(f,'%d ',r);
    for i=1:8
        fprintf(f,'%0.3f ',mx(i));
    end
    for i=1:N
        fprintf(f,'%0.3f ',SN(i,i));
    end
    %===========================================================================LLACE of the Usmaller martix's coefficients
    l=1;
    [r,c]=size(Usmaller);
    Usmaller=round(Usmaller,3);
      = patient_information(N)';
    X = cat(1, Usmaller, PI);
    %X = Usmaller;
    [rr,cc]=size(X);
    onedi=round(reshape(X,[1,rr*N]),3);
    L = length(onedi(2:end));
    rem = mod(L, 8);
    if rem~=0
        Z = zeros(1,8 - rem);
        onedi = cat(2,onedi,Z);
    end
    temp(1)=onedi(1);
    temp(2:length(onedi))=diff(onedi);
    flag=0;
    for i=2:length(temp)
        if temp(i)>0.254
            asci=fopen('ascidiff','a+');
            fprintf(asci,'%d %0.3f ',i,temp(i));
            temp(i)=0.254;
            fclose(asci);
            flag=1;
        end
        if temp(i)<-0.254
            asci=fopen('ascidiff','a+');
            fprintf(asci,'%d %0.3f ',i,temp(i));
            temp(i)=-0.254;
            fclose(asci);
            flag=1;
        end
    end
    if flag==1
        for i=2:length(onedi)
            onedi(i)=onedi(i-1)+temp(i);
        end
    end
    e=onedi';
    [ro co]=size(e);
    d(1)=e(1);         %differentiation
    d(2:ro)=diff(e);   %differentiation
    if d(1)<0
        fs=1;
        d(1)=d(1)*-1;
    else 
        fs=0;
    end
    fn=d(1)*10;
    f1=fix(fn);
    l1=int32((fn-f1)*100);
    fprintf(f,'%c',fs);
    flag=0;
    fflag=0;
    pos=0;
    poss=0;
    if f1==10
        f1=11;
        pos=1;
        flag=1;
    end
    if l1==10
        l1=11;
        poss=1;
        fflag=1;
    end
    fprintf(f,'%c',f1);
    fprintf(f,'%c',l1);
    if flag==1 || fflag==1
        fprintf(f,'%c',pos);
        fprintf(f,'%c',poss);
    end
    fprintf(f,'\n');
    fclose(f);

    [roo coo]=size(d(2:end));
    i=2;
    j=1;
    for i=2:1:ro
        ee(j)=d(i);
        j=j+1;
        if j==9
            j=1;
            llc(ee,naam);
        end
    end
    toc
    fclose all;
    fprintf('\n Compression is done......');
    fprintf('\n ============================================================\n');
    disp(naam)
    DCT_SVD_MECG_Decompression(naam);
end