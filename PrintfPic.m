function [RangeFFTout, DopplerFFTout, AngleFFTout] = PrintfPic(DataIn, RadarParament, PrintfParament, FrameIdx, ChirpIdx)
    isReal = RadarParament.IsReal;
    PrintfParament.ChirpIdx = ChirpIdx;

    %----------距离FFT----------%
    RangeFFTout = fft(DataIn, [], 1); % 没有加窗

    %----------速度FFT----------%
    DopplerFFTout = fftshift(fft(RangeFFTout, [], 2), 2); % 没有加窗

    %----------角度FFT----------%
    AngleFFTout = fftshift( fft(RangeFFTout, RadarParament.AngleFFTNum, 3), 3 ); % 对虚拟通道维度进行 FFT 并 fftshift

    %----------chirp波形----------%
    if PrintfParament.ChirpMapEn == 1
        figure(1);
        hold off;
        plot((0:RadarParament.Rangelen-1) ./ (RadarParament.fadc), real(DataIn(:, PrintfParament.ChirpIdx, PrintfParament.AntennaIdx)));
        xlabel('Time(s)'); ylabel('Amplitude'); hold on; grid on;
        plot((0:RadarParament.Rangelen-1) ./ (RadarParament.fadc), imag(DataIn(:, PrintfParament.ChirpIdx, PrintfParament.AntennaIdx)));
        legend('\it real', '\it complex');
        title(sprintf("%dth Frame %dth Chirp", FrameIdx, PrintfParament.ChirpIdx));
    end

    %----------距离谱波形----------%
    if PrintfParament.RangeMapEn == 1
        figure(2);
        if isReal == 1
            plot((1:(RadarParament.Rangelen/2)).*RadarParament.Rres, abs(RangeFFTout(1:(RadarParament.Rangelen/2), PrintfParament.ChirpIdx, PrintfParament.AntennaIdx)));
            xlabel('Range(m)'); ylabel('Amplitude(dB)');
        else
            plot((1:(RadarParament.Rangelen)).*RadarParament.Rres, abs(RangeFFTout(:, PrintfParament.ChirpIdx, PrintfParament.AntennaIdx)));
            xlabel('Range(m)'); ylabel('Amplitude');
        end
        title(sprintf("%dth Frame %dth Chirp TDM-FFT", FrameIdx, PrintfParament.ChirpIdx));
    end

    %----------距离-速度图----------%
    if PrintfParament.RDMapEn == 1
        figure(3);
        if isReal == 1
            mesh((-RadarParament.dopperlen/2:RadarParament.dopperlen/2-1).*RadarParament.Vres, ...
                 (1:RadarParament.Rangelen/2).*RadarParament.Rres, ...
                 db(abs(DopplerFFTout(1:(RadarParament.Rangelen/2), :, PrintfParament.AntennaIdx))));
            title(sprintf("%dth R-D", FrameIdx));
            ylabel('Range(m)');
            xlabel('Velocity(m/s)');
            zlabel('Amplitude (dB)');
            colorbar;
        else
            mesh((-RadarParament.dopperlen/2:RadarParament.dopperlen/2-1), ...
                 (1:RadarParament.Rangelen), ...
                 db(abs(DopplerFFTout(:, :, PrintfParament.AntennaIdx))));
            title(sprintf("%dth R-D", FrameIdx));
            ylabel('Range(m)');
            xlabel('Velocity(m/s)');
            zlabel('Amplitude (dB)');
            colorbar;
        end
    end

    %----------距离-角度图----------%
    if PrintfParament.RAMapEn == 1
        figure(4);
        % 提取某个 Chirp 的 Range-Angle 数据
        RAMap = abs(AngleFFTout(:, PrintfParament.ChirpIdx, :));
        RAMap = squeeze(RAMap); % 维度 [numSamplePerChirp, numAngleFFT]
        d      = RadarParament.AntSep;                        % 天线间距
        lambda = RadarParament.lambda;                        % 波长
        numAngleFFT = RadarParament.AngleFFTNum;
        % 定义角度轴和距离轴
        u = (-numAngleFFT/2 : numAngleFFT/2-1) / numAngleFFT; 
        angles = asind( u * lambda / d );   % [deg]
        ranges = (1:RadarParament.Rangelen) * RadarParament.Rres;
        % 绘制 Range-Angle Map
        imagesc(angles, ranges, db(RAMap));
        title(sprintf("%dth Frame %dth Chirp Range-Angle Map", FrameIdx, PrintfParament.ChirpIdx));
        xlabel('Angle (°)');
        ylabel('Range (m)');
        colorbar;

        rangeMag   = abs( RangeFFTout(:, ChirpIdx, PrintfParament.AntennaIdx) );
        [~, idxMax] = max( rangeMag );  
        
        % 2. 提取该 range bin 对应的角度谱
        %    AngleFFTout 大小为 [Rangelen, numChirps, numVchans]
        angleSpec = squeeze( abs( AngleFFTout(idxMax, ChirpIdx, :) ) );  
        
        % 3. 定义角度轴（与上面 RAMap 中保持一致） 
        
        % 4. 绘制 angle spectrum
        figure;
        plot( angles, angleSpec );
        grid on;
        xlabel('Angle (°)');
        ylabel('Amplitude');
        title( sprintf('%dth Frame %dth Chirp: Range bin %d Angle Spectrum', ...
                       FrameIdx, ChirpIdx, idxMax) );
    end

end