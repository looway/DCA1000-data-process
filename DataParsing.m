%% 数据解析代码，完成从bin文件到ADC 3D数据矩阵(.mat)的转换，并做基本的测距以验证解析的准确性 %%
%% 生成数据为adcDataComplex = 4 *[256(samples) * 128(chirpNums)]
function [adcDataComplex] = DataParsing(fileFullPath, RadarParament, frameIdx)
numSamplePerChirp = RadarParament.NumSample;

numLoops          = RadarParament.NumLoop_TDM;
numRX             = RadarParament.NumRx;
numBits           = RadarParament.NumBits;
isReal            = RadarParament.IsReal;


% 计算一帧的预期样本数（uint16 单位）
if isReal == 1
    Expected_Num_SamplesPerFrame = numSamplePerChirp * numLoops * numRX; % 实数数据
else
    Expected_Num_SamplesPerFrame = numSamplePerChirp * numLoops * numRX * 2; % 复数数据（实部+虚部）
end

% 打开文件
fp = fopen(fileFullPath, 'r');
if fp == -1
    error('无法打开文件：%s', fileFullPath);
end

% 定位到指定帧的起始字节
    fseek(fp, (frameIdx-1) * Expected_Num_SamplesPerFrame * 2, 'bof'); % 每个 uint16 占 2 字节
% 读取数据
DataTmp = fread(fp, Expected_Num_SamplesPerFrame, 'uint16');
if length(DataTmp) ~= Expected_Num_SamplesPerFrame
    fclose(fp);
    error('读取数据量 %d 不等于预期 %d，请检查文件或参数', length(DataTmp), Expected_Num_SamplesPerFrame);
end

% 关闭文件
fclose(fp);

%格式解析
neg                = logical(bitget(DataTmp, numBits));             %最高位为符号位
DataTmp(neg)       = DataTmp(neg) - 2^(numBits);                    %首位为1表示为负数，此时需要减去2^16;


fileSize = size(DataTmp, 1);                            %计算数据量大小

if isReal == 1
    numChirps = fileSize/numSamplePerChirp/numRX;
    datatmp2 = zeros(1, fileSize); 
    datatmp2 = reshape(DataTmp, numSamplePerChirp*numRX, numChirps);
    datatmp2 = datatmp2.';

else
    numChirps = round(fileSize/numSamplePerChirp/numRX/2);  %计算chirp数量
    assert(numChirps == numLoops, 'numChirps (%d) 不等于 numLoops (%d)，请检查数据或参数设置', numChirps, numLoops);
    %1642数据格式为非交织
    datatmp2 = zeros(1, (fileSize/2)); 
    counter = 1;
    for i=1:4:fileSize-1
        datatmp2(1,counter) = DataTmp(i)+sqrt(-1)*DataTmp(i+2);
        datatmp2(1,counter+1) = DataTmp(i+1)+sqrt(-1)*DataTmp(i+3);
        counter = counter + 2;
    end
    datatmp2 = reshape(datatmp2, numSamplePerChirp*numRX, numChirps);
    datatmp2 = datatmp2.';
end
adcData = zeros(numRX,numChirps*numSamplePerChirp);

for row = 1:numRX
    for i = 1:numChirps
        adcData(row, (i-1)*numSamplePerChirp+1:i*numSamplePerChirp) = datatmp2(i, (row-1)*numSamplePerChirp+1:row*numSamplePerChirp);
    end
end

adcDataComplex = adcData;

end




























