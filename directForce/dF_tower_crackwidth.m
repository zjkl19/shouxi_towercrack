%程序功能：
%计算绶溪公园单个塔柱在各个工况下，塔柱各个截面的裂缝宽度
%考虑劲性骨架，其中：d,h0近似认为不变（因为劲性骨架面积相对钢筋面积很小）
%与未考虑劲性骨架的方案相比，改变了As和rou的值改变。

%主要输入：
%每个施工阶段，主塔剪力、轴力
%主要输出：
%主塔各个施工阶段裂缝宽度，输出位于对应的excel文件中

%注意事项:若计算的工况数比上一次少，请先运行“清空_主塔裂缝宽度.bat”
%或每次计算前，都运行该批处理

clear;clc;

%参考文献：
%1、《结构设计原理》（第二版）  叶见曙 P194~P195
%2、《公路钢筋混凝土及预应力混凝土桥涵设计规范》（JTGD62-2004） P60

%根据参考文献[2]，在I类和II类环境条件下的钢筋混凝土构件，算得裂缝宽度不应超过0.2mm

%-------------------------------------------
%塔柱计算参数，参考图纸
%参数 已核 林迪南 20170502
lup=11.513;ldown=4.827;		%上下塔柱的高度，单位：m
l_all=lup+ldown;				%塔柱总高度

l=[0 ldown*(1/4) ldown*(2/4) ldown*(3/4) ldown ldown ldown+lup*(1/4) ldown+lup*(2/4) ldown+lup*(3/4)];	%验算截面的长度

nl=size(l,2);	%验算截面的数量

ncri=5;			%定位临界截面，即从第(ncri+1)个截面开始，配筋按上塔柱截面来考虑
%-------------------------------------------

%-------------------------------------------
%excel 写入参数
filename = '主塔裂缝宽度.xls';    %结果写入的excel文件
sheetIndex = 1;		%标签索引
xlRange = 'A2';     %写入点
%-------------------------------------------

%-------------------------------------------
%参考：
%1、《结构设计原理》（第二版）  叶见曙 P194
%2、《公路钢筋混凝土及预应力混凝土桥涵设计规范》（JTGD62-2004） P60

%参数 已核 林迪南 20170502
c1=1.0; %钢筋表面形状系数
c2=1.0; %作用长期效应影响系数
c3=0.9; %与构件受力性质有关的系数
d=28;   %纵向受拉钢筋的直径
Es=2.00*10^5;   %普通钢筋弹性模量

As_stf_sk=2*(4*((30*4)+(26*4)));    %受拉区劲性骨架面积(1792)
%-------------------------------------------


%------------------------------------------
%绶溪公园midas模型单个主塔3个关键点坐标（成桥状态）,其中第2个点是中间点
%单位:mm

%参数 已核 林迪南 20170502
%coorx=[20 25 30]*1000;
%coorz=[16.868581 20.35 17.869428]*1000;
%------------------------------------------


%---------------------------------------------------------
%参数读取

readOption=1;   
%0:从程序中读取
%1:从txt文件读取

if readOption==1
    %塔模型左侧拉力、1号塔模型右侧拉力
    HH=load('H.txt');    %水平力（剪力）数组
    HH=abs(HH);
    NN=load('N.txt');    %轴力数组
    NN=abs(NN);
    %每一行表示每个施工阶段的拉力
else
    T=[150.2 87.6];
    deltax=[-165.775 -7.402 52.337];
    deltaz=[268.658 -0.188 156.346];
end
%---------------------------------------------------------

n=size(HH,1);    %施工阶段数

writetoVar=zeros(n,11);

%循环常量


for k=1:n
    
    fprintf('正在计算第%d个施工阶段,当前进度：%%%-5.2f\n',k,k*100/n);
    
    H=HH(k,1);
    N=NN(k,1);   %水平力和轴力大小，单位均为KN
    
    %N=100000;
    %H=500;
  
    Wfk=zeros(1,nl);	%初始化裂缝宽度为0   
    
    %----------------------------------------------
    %参数 已核 林迪南 20170502
    %依次验算各个截面的裂缝宽度
    for i=1:nl
        if i>ncri	%取上塔柱截面参数
            h=1400;         %高度，单位：mm
            h0=h-55-28;     %计算高度
                            %55指保护层厚度，28指钢筋形心到保护层内缘距离
            b=900;          %宽度，单位：mm
            ys=h/2-55-28;
            As=5542*2+As_stf_sk;      %9根d==28钢筋
        else	%取下塔柱截面参数
            h=1600;         %单位：mm
            h0=h-55-28;
            b=1300;         %单位：mm
            ys=h/2-55-28;
            As=8005*2+As_stf_sk;      %13根d==28钢筋。  615.8*13
        end
     %----------------------------------------------
     
        rou=As*(b*h0)^-1;   %配筋率
        
        %单位换算成m
        h0=h0/1000;
        b=b/1000;
        ys=ys/1000;
        
        
        l0=2*l(i);         %构件计算长度
        
        e0=H*(l_all-l(i))*1000/N;        %偏心距
        
        %---------------------核对开始---------------------
        %已根据《公路钢筋混凝土及预应力混凝土桥涵设计规范》（JTGD62-2004） P60~62核对 林迪南
        
        %计算使用阶段的轴向压力偏心距增大系数
        if l0/h<=14
            ita_s=1.0;
        else
            ita_s=1+(l*(4000*e0*h0^-1))*(l0/h)^2;
        end
        
        gamma_f=0;      %受压翼缘截面面积与腹板有效面积的比值
                        %γf'=0
        
        %轴向压力作用点至纵向受拉钢筋合力点的距离
        es=ita_s*e0+ys;
        
        %纵向受拉钢筋合力点至截面受压区合力点的距离
        z=(0.87-0.12*(1-gamma_f)*(h0/es)^2)*h0;
        
        %纵向受拉钢筋的应力
        sigma_ss=N*(es-z)/(As*z);
        
        %最大裂缝宽度
        Wfk(i)=c1*c2*c3*sigma_ss*Es^-1*(30+d)*(0.28+10*rou)^-1;		%各个截面的裂缝宽度;
        
        %----------------------核对结束--------------------
        
        writetoVar(k,:)=[H N Wfk];	%第k个工况的水平力，轴力和裂缝宽度
    end
end

%writetoVar=[H N Wfk];	%写入的变量

%不可控代码均要使用异常
try
    xlswrite(filename,writetoVar,sheetIndex,xlRange);
catch err
    disp('excel 文件写入失败。');
    throw(err);
end

