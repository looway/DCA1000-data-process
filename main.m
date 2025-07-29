clear; close all; clc;
%% 天线数量为1时有问题
%---------雷达参数配置--------%
[RadarParament] = RadarParamentsConfig;
%---------绘图参数配置--------%
[PrintfParament] = PrintfParamentsConfig;

%---------数据文件路径--------%
datafolder  = 'E:\project\data';
binfileName = '002.bin';
binfilePath = strcat(datafolder,'\',binfileName);

% frameIdx = 510;
ChirpIdx = 1;

%-------一帧一帧处理--------%
for frameIdx = 1:RadarParament.Numframe
     % for ChirpIdx = 1 : RadarParament.NumLoop_TDM
        [ADCdata] = DataParsing(binfilePath, RadarParament, frameIdx); 
        % [ADCdata] = readDCA1000(binfilePath, RadarParament, frameIdx);
        
        [ADCdata_TDM, RadarParament.Rangelen, RadarParament.dopperlen] = DataSeperate(ADCdata, RadarParament);

        [RangeFFTout_TDM, DopplerFFTout_TDM, AngleFFTout_TDM] = PrintfPic(ADCdata_TDM, RadarParament, PrintfParamentsConfig, frameIdx, ChirpIdx);

     % end
end

