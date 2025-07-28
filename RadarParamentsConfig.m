%% 雷达参数设置，用以解析原始数据 %%
% %fadc = 16(5e6),18(10e6);  

function [RadarParament] = RadarParamentsConfig
        
RadarParament.Numframe     = 64;        
RadarParament.fadc         = 5.5e6;      
RadarParament.NumSample    = 256;      
RadarParament.chirpSlop    = 68e12;         
RadarParament.ChirpT       = 58e-6;    %!!!!! 
RadarParament.Idletime     = 7e-6;      %!!!!!
RadarParament.IsReal       = 0;         %!!!!!
    
RadarParament.NumTx        = 1;         %!!!!!      
RadarParament.NumRx        = 4;
RadarParament.NumLoop_TDM  = 64;    %单帧下每个发射天线发射的chirp数
RadarParament.NumBits      = 16;     %ADC数据的位数
RadarParament.NumIQ        = 2;      %是否为IQ两路采样？

RadarParament.Buse         = RadarParament.NumSample/RadarParament.fadc*RadarParament.chirpSlop;   %ADC采样的总带宽

RadarParament.Tc           = RadarParament.ChirpT + RadarParament.Idletime; %前后发射的两个chirp之间的时长，这个值乘以发射天线数才是速度维度的采样周期。
RadarParament.Frametime    = RadarParament.Tc*RadarParament.NumLoop_TDM*RadarParament.NumTx;    %单帧发射时长。其实TDM和BPM是一样的。

c                          = 3e8;
RadarParament.fc           = 77.94745e9; %Hz
RadarParament.lambda       = c/RadarParament.fc;

RadarParament.Rres         = c/2/RadarParament.Buse;   %雷达理论的距离分辨率

FIf                        = 5e6;   %雷达的中频带宽 2944-15MHz 1642-5MHz
if RadarParament.NumIQ == 2
    Fuse = min(FIf,RadarParament.fadc);
else
    Fuse = min(FIf,RadarParament.fadc/2);
end

RadarParament.Rmax         = c*Fuse/2/RadarParament.chirpSlop;   %从数据处理端而言的最大测量距离

RadarParament.Vres         = RadarParament.lambda/2/RadarParament.Frametime; 

RadarParament.Vmax         = RadarParament.lambda/4/(RadarParament.Tc)/RadarParament.NumTx;

RadarParament.Rangelen     = 0;
RadarParament.dopperlen    = 0;

end













