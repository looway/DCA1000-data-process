%% 数据解析代码，完成从bin文件到ADC 3D数据矩阵(.mat)的转换，并做基本的测距以验证解析的准确性 %%
%% 生成数据为adcDataComplex = 4 *[256(samples) * 128(chirpNums)]
function [adcDataComplex] = DataParsing(fileFullPath, RadarParament, frameIdx)
numSamplePerChirp = RadarParament.NumSample;

numLoops          = RadarParament.NumLoop_TDM;
numRX             = RadarParament.NumRx;
numBits           = RadarParament.NumBits;
isReal            = RadarParament.IsReal;

%一帧数量:128(chirps) * 4(Rx) * 2(adc) * 256(samples) * 2(complex)
Expected_Num_SamplesPerFrame = numSamplePerChirp*numLoops*numRX * 2;  %理论上的全部的个数
fp       = fopen(fileFullPath, 'r');

if isReal == 1
    fseek(fp,(frameIdx-1)*Expected_Num_SamplesPerFrame*2, 'bof');       %ADC位数为16位，所以两个u8
elseif isReal == 0
    fseek(fp,(frameIdx-1)*Expected_Num_SamplesPerFrame*2*2, 'bof');     %ADC位数为16位，且为复数，需要两个2*2个u8
end
DataTmp  = fread(fp,Expected_Num_SamplesPerFrame,'uint16');         %拿出这么多数据来

%格式解析
neg                = logical(bitget(DataTmp, numBits));             %最高位为符号位
DataTmp(neg)       = DataTmp(neg) - 2^(numBits);                    %首位为1表示为负数，此时需要减去2^16;

fclose(fp);

fileSize = size(DataTmp, 1);                            %计算数据量大小

if isReal == 1
    numChirps = fileSize/numSamplePerChirp/numRX;
    datatmp2 = zeros(1, fileSize); 
    datatmp2 = reshape(DataTmp, numSamplePerChirp*numRX, numChirps);
    datatmp2 = datatmp2.';

else
    numChirps = round(fileSize/numSamplePerChirp/numRX/2);  %计算chirp数量
    fprintf("numChirps = %d\n", numChirps);
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





























