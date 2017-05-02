clear;clc;

%参考文献：
%1、《结构设计原理》（第二版）  叶见曙 P194
%2、

%从绶溪公园外侧至内侧3个点依次成桥坐标
%单位:mm
coorx=[20 25 30]*1000;
coorz=[16.868581 20.35 17.869428]*1000;

%T=[150.2 87.6];     %1号塔模型左侧拉力、1号塔模型右侧拉力
T=load('T.txt');    %第1列表示左侧、第2列表示右侧

%某施工阶段下的位移（相对成桥阶段）
%单位:mm
%deltax=[-165.775 -7.402 52.337];
%deltaz=[268.658 -0.188 156.346];
deltax=load('deltax.txt');
deltaz=load('deltaz.txt');

n=size(T,1);    %阶段数

writetoVar=zeros(n,11);


%for k=1:n
    
    %考虑施工阶段下位移的坐标值
    %coorx_mod=coorx+deltax(k,:);
    %coorz_mod=coorz+deltaz(k,:);
    
    %theta：夹角
    %theta=zeros(1,2);
    
    %for i=1:2
    %    for j=2:3
    %        theta(i)=atan(abs(coorz_mod(j)-coorz_mod(j-1))/abs(coorx_mod(j)-coorx_mod(j-1)));
    %    end
    %end
    
    %H=abs((T(k,2)*cos(theta(2))-T(k,1)*cos(theta(1))));
    %N=abs((T(k,2)*sin(theta(2))+T(k,1)*sin(theta(1))));   %水平力和轴力大小，单位均为KN
    
    N=100000;
    H=500;
    
    lup=11.513;ldown=4.827;		%上下塔柱的高度，单位：m
    l_all=lup+ldown;				%塔柱总高度
    
    l=[0 ldown*(1/4) ldown*(2/4) ldown*(3/4) ldown ldown ldown+lup*(1/4) ldown+lup*(2/4) ldown+lup*(3/4)];	%验算截面的长度
    
    nl=size(l,2);	%验算截面的数量
    
    ncri=5;			%定位临界截面，即从第(ncri+1)个截面开始，配筋按上塔柱截面来考虑
    
    Wfk=zeros(1,nl);	%初始化裂缝宽度为0
    
    
    c1=1.0; %钢筋表面形状系数
    c2=1.0; %作用长期效应影响系数
    c3=0.9; %与构件受力性质有关的系数
    d=28;   %纵向受拉钢筋的直径
    Es=2.00*10^5;   %普通钢筋弹性模量
    
    
    
    %依次验算各个截面的裂缝宽度
    for i=1:nl
        if i>ncri	%取上塔柱截面参数
            h=1400;         %单位：mm
            h0=h-55-28;
            b=900;          %单位：mm
            ys=h/2-55-28;
            As=5542*2;
        else	%取下塔柱截面参数
            h=1600;         %单位：mm
            h0=h-55-28;
            b=1300;         %单位：mm
            ys=h/2-55-28;
            As=8005*2;
        end
        
        rou=As*(b*h0)^-1;   %配筋率
        
        %单位换算成m
        h0=h0/1000;
        b=b/1000;
        ys=ys/1000;
        
        
        l0=2*l(i);         %构件计算长度
        
        e0=H*(l_all-l(i))/N;        %偏心距
        
        %计算使用阶段的轴向压力偏心距增大系数
        if l0/h<=14
            ita_s=1.0;
        else
            ita_s=1+(l*(4000*e0*h0^-1))*(l0/h)^2;
        end
        
        gamma_f=0; %γf'=0
        
        %轴向压力作用点至纵向受拉钢筋合力点的距离
        es=ita_s*e0+ys;
        
        %纵向受拉钢筋合力点至截面受压区合力点的距离
        z=(0.87-0.12*(1-gamma_f)*(h0/es)^2)*h0;
        
        %纵向受拉钢筋的应力
        sigma_ss=N*(es-z)/(As*z);
        
        %最大裂缝宽度
        Wfk(i)=c1*c2*c3*sigma_ss*Es^-1*(30+d)*(0.28+10*rou)^-1;		%各个截面的裂缝宽度;
    %        writetoVar(k,:)=[H N Wfk];	%写入的变量
    end
%end



filename = '主塔裂缝宽度.xls';
sheetIndex = 1;		%标签索引
xlRange = 'A2';

writetoVar=[H N Wfk];	%写入的变量

try
    xlswrite(filename,writetoVar,sheetIndex,xlRange);
catch err
    disp('excel 文件写入失败。');
    throw(err);
end





