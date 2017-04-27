clear;clc;
H=1020;N=1000;   %水平力和轴力大小，单位均为KN

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
end

filename = '主塔裂缝宽度.xls';
sheetIndex = 1;		%标签索引
xlRange = 'A2';
writetoVar=[H N Wfk];	%写入的变量
xlswrite(filename,writetoVar,sheetIndex,xlRange);	




