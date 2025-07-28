%% 该函数实现TDM下的数据分离的操作 %%
%% 生成数据为DataOut[Samples][ChirpNums][RX]

function   [DataOut, RangeLen, DopplerLen] = DataSeperate(DataIN, RadarParament)

numSamplePerChirp = RadarParament.NumSample;
numLoops          = RadarParament.NumLoop_TDM;
numRX             = RadarParament.NumRx;
% if isReal == 1
% 
% else
    DataIN = DataIN.';
    DataOut = reshape(DataIN, numSamplePerChirp, numLoops, numRX);
    [RangeLen, DopplerLen, ~] = size(DataOut);
% end


end

%{
    [ADCdata] = DataParsing(binfilePath,RadarParament,1); 
    ADCdata = ADCdata.';
    ADCdata_TDM = reshape(ADCdata, RadarParament.NumSample, RadarParament.NumLoop_TDM, RadarParament.NumRx);
    [Rangelen,dopperlen_DDM,~] = size(ADCdata_TDM);
    %选其中一个通道的其中一个chirp的回波 看看时域数据
    figure(1);
    plot(1:Rangelen,real(ADCdata_TDM(:,1,1))); xlabel('采样点');ylabel('幅值');title('TDM发射模式下的时域数据');
    figure(2);
    plot(1:Rangelen,real(retVal(1,1:256))); xlabel('采样点');ylabel('幅值');title('TDM发射模式下的时域数据');
%}
