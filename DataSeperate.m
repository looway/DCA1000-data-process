% 函数：DataSeperate
% 功能：将输入的雷达ADC数据按发射天线(Tx)分割，并整合为虚拟接收通道数据
% 输入：
%   - DataIN: 来自DataParsing的ADC数据，维度为 [numRX, numChirps*numSamplePerChirp]
%   - RadarParament: 雷达参数结构体，包含 NumSample, NumLoop_TDM, NumRx, NumTx, IsReal 等
% 输出：
%   - DataOut_virtual: 虚拟接收通道数据，维度 [numSamplePerChirp, M, numVirtualChannels]
%   - RangeLen: 距离维度长度 (numSamplePerChirp)
%   - DopplerLen: 多普勒维度长度 (M = numLoops / NumTx)
% 注意：
%   - numLoops 必须是 NumTx 的整数倍
%   - 虚拟通道顺序为 (Tx0-Rx0, Tx0-Rx1, ..., Tx0-Rx(NumRx-1), Tx1-Rx0, ..., Tx(NumTx-1)-Rx(NumRx-1))
%   - 输出适配 PrintfPic 函数的输入要求

function [DataOut_virtual, RangeLen, DopplerLen] = DataSeperate(DataIN, RadarParament)
    % 提取参数
    numSamplePerChirp = RadarParament.NumSample;  % 每个 chirp 的采样点数
    numLoops = RadarParament.NumLoop_TDM;        % 总 chirp 数量
    numRX = RadarParament.NumRx;                 % 接收天线数量
    NumTx = RadarParament.NumTx;                 % 发射天线数量
    isReal = RadarParament.IsReal;               % 是否为实数数据

    % 计算每个发射天线的 chirp 数量
    M = numLoops / NumTx;                        % 每个 Tx 的 chirp 数量
    assert(mod(numLoops, NumTx) == 0, 'numLoops 必须是 NumTx 的整数倍');

    % 初始数据重塑
    if isReal == 1
        % 实数数据处理（直接重塑）
        DataOut = reshape(DataIN.', numSamplePerChirp, numLoops, numRX);
    else
        % 复数数据处理（转置后重塑）
        DataOut = reshape(DataIN.', numSamplePerChirp, numLoops, numRX);
    end

    % 获取输出维度
    [RangeLen, ~, ~] = size(DataOut); 

    % 按发射天线分割数据
    % DataOut_tx: cell 数组，包含 NumTx 个元素，每个元素维度为 [numSamplePerChirp, M, numRX]
    DataOut_tx = cell(1, NumTx);
    for k = 0:NumTx-1
        DataOut_tx{k+1} = DataOut(:, k+1:NumTx:numLoops, :);
    end

    % 整合为虚拟接收通道
    % DataOut_virtual: 维度 [numSamplePerChirp, M, numVirtualChannels]
    numVirtualChannels = NumTx * numRX;  % 虚拟通道数量
    DataOut_virtual = zeros(numSamplePerChirp, M, numVirtualChannels);
    for m = 1:M
        for k = 1:NumTx
            start_idx = (k-1) * numRX + 1;  % 当前 Tx 的虚拟通道起始索引
            end_idx = k * numRX;            % 当前 Tx 的虚拟通道结束索引
            DataOut_virtual(:, m, start_idx:end_idx) = DataOut_tx{k}(:, m, :);
        end
    end

    % 更新多普勒维度长度（每个 Tx 的 chirp 数量）
    DopplerLen = M;
end