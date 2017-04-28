clear;clc;

T=[151.9 87.6];     %1������������

%���Ϫ��԰������ڲ�3������������
%��λ:mm
coorx=[20 25 30]*1000;
coorz=[16.868581 20.35 17.869428]*1000;

%ĳʩ���׶��µ�λ�ƣ���Գ��Ž׶Σ�
%��λ:mm
deltax=[-165.775 -7.402 52.337];
deltaz=[268.658 -0.188 156.346];

%theta���н�
theta=zeros(1,2);
for i=1:2
    for j=2:3
        theta(i)=atan(abs(coorz(j)-coorz(j-1))/abs(coorx(j)-coorx(j-1)));
    end
end

H=abs((T(2)*cos(theta(2))-T(1)*cos(theta(1))));
N=abs((T(2)*sin(theta(2))+T(1)*sin(theta(1))));   %ˮƽ����������С����λ��ΪKN

lup=11.513;ldown=4.827;		%���������ĸ߶ȣ���λ��m
l_all=lup+ldown;				%�����ܸ߶�

l=[0 ldown*(1/4) ldown*(2/4) ldown*(3/4) ldown ldown ldown+lup*(1/4) ldown+lup*(2/4) ldown+lup*(3/4)];	%�������ĳ���

nl=size(l,2);	%������������

ncri=5;			%��λ�ٽ���棬���ӵ�(ncri+1)�����濪ʼ��������������������

Wfk=zeros(1,nl);	%��ʼ���ѷ���Ϊ0


c1=1.0; %�ֽ������״ϵ��
c2=1.0; %���ó���ЧӦӰ��ϵ��
c3=0.9; %�빹�����������йص�ϵ��
d=28;   %���������ֽ��ֱ��
Es=2.00*10^5;   %��ͨ�ֽ��ģ��



%�����������������ѷ���
for i=1:nl
    if i>ncri	%ȡ�������������
        h=1400;         %��λ��mm
        h0=h-55-28;
        b=900;          %��λ��mm
        ys=h/2-55-28;
        As=5542*2;
    else	%ȡ�������������
        h=1600;         %��λ��mm
        h0=h-55-28;
        b=1300;         %��λ��mm
        ys=h/2-55-28;
        As=8005*2;
    end
    
    rou=As*(b*h0)^-1;   %�����
    
    %��λ�����m
    h0=h0/1000;
    b=b/1000;
    ys=ys/1000;
    
    
    l0=2*l(i);         %�������㳤��
    
    e0=H*(l_all-l(i))/N;        %ƫ�ľ�
    
    %����ʹ�ý׶ε�����ѹ��ƫ�ľ�����ϵ��
    if l0/h<=14
        ita_s=1.0;
    else
        ita_s=1+(l*(4000*e0*h0^-1))*(l0/h)^2;
    end
    
    gamma_f=0; %��f'=0
    
    %����ѹ�����õ������������ֽ������ľ���
    es=ita_s*e0+ys;
    
    %���������ֽ��������������ѹ��������ľ���
    z=(0.87-0.12*(1-gamma_f)*(h0/es)^2)*h0;
    
    %���������ֽ��Ӧ��
    sigma_ss=N*(es-z)/(As*z);
    
    %����ѷ���
    Wfk(i)=c1*c2*c3*sigma_ss*Es^-1*(30+d)*(0.28+10*rou)^-1;		%����������ѷ���;
end

filename = '�����ѷ���.xls';
sheetIndex = 1;		%��ǩ����
xlRange = 'A2';
writetoVar=[H N Wfk];	%д��ı���

try
     xlswrite(filename,writetoVar,sheetIndex,xlRange);
catch err
     disp('excel �ļ�д��ʧ�ܡ�');
     throw(err);    
end





