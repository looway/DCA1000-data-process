function [retVal] = readDCA1000(fileName, RadarParament, frame)

numADCSamples = RadarParament.NumSample; 
numChirp = RadarParament.NumLoop_TDM;
numADCBits = RadarParament.NumBits; 
numRX = RadarParament.NumRx; 
isReal = RadarParament.IsReal; 

Expected_Num_SamplesPerFrame = numADCSamples*numChirp*numRX;

fid = fopen(fileName,'r');
fseek(fid,(frame-1)*Expected_Num_SamplesPerFrame, 'bof');   
adcData = fread(fid, 'int16');

if numADCBits ~= 16
    l_max = 2^(numADCBits-1)-1;
    adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
end
fclose(fid);
fileSize = size(adcData, 1);

if isReal
    numChirps = fileSize/numADCSamples/numRX;
    LVDS = zeros(1, fileSize);
    LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
    LVDS = LVDS.';
else
    numChirps = fileSize/2/numADCSamples/numRX;
    LVDS = zeros(1, fileSize/2);
    
    counter = 1;
    for i=1:4:fileSize-1
        LVDS(1,counter) = adcData(i) + sqrt(-1)*adcData(i+2); 
        LVDS(1,counter+1) = adcData(i+1)+sqrt(-1)*adcData(i+3); 
        counter = counter + 2;
    end
    
    LVDS = reshape(LVDS, numADCSamples*numRX, numChirps);
    
    LVDS = LVDS.';
end

adcData = zeros(numRX,numChirps*numADCSamples);
for row = 1:numRX
    for i = 1: numChirps
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end

retVal = adcData;
