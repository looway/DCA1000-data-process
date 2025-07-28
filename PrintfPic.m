function   [RangeFFTout, DopplerFFTout] = PrintfPic(DataIn, RadarParament, PrintfParament, FrameIdx)

isReal            = RadarParament.IsReal;

%----------距离FFT----------%
RangeFFTout = fft(DataIn,[],1);                     %没有加窗
%----------速度FFT----------%
DopplerFFTout = fftshift(fft(RangeFFTout,[],2),2);  %没有加窗
% Correction = 20 * log10(2^16-1) + 20 * log10(Rangelen) - 20 * log10(sqrt(2));

% chirp波形
if PrintfParament.ChirpMapEn == 1
    figure(1);
    hold off;
    plot((0:RadarParament.Rangelen-1) ./ (RadarParament.fadc), real(DataIn(:, PrintfParament.ChirpIdx, PrintfParament.AntennaIdx))); 
    xlabel('Time(s)');ylabel('Amplitude');hold on;grid on;
    plot((0:RadarParament.Rangelen-1) ./ (RadarParament.fadc), imag(DataIn(:, PrintfParament.ChirpIdx, PrintfParament.AntennaIdx)));
    legend('\it real','\it complex');
    title(sprintf("%dth Frame %dth Chirp", FrameIdx, PrintfParament.ChirpIdx));
end

% 距离谱波形
if PrintfParament.RangeMapEn == 1
    figure(2);
    if isReal == 1
        % plot((1:(Rangelen/2)).*(RadarParament.fadc/RadarParament.NumSample),(abs(RangeFFTout(1:(Rangelen/2),ChirpIdx,1)))); xlabel('Frequence(Hz)');ylabel('Amplitude');
        plot((1:(RadarParament.Rangelen/2)).*RadarParament.Rres, abs(RangeFFTout(1:(RadarParament.Rangelen/2), PrintfParament.ChirpIdx, PrintfParament.AntennaIdx))); 
        xlabel('Range(m)');ylabel('Amplitude(dB)');
        % plot((1:(Rangelen/2)),abs(RangeFFTout(1:(Rangelen/2),1,1))); xlabel('RangeBin');ylabel('Amplitude');
    else
        % plot((1:Rangelen) ./ (RadarParament.fadc), db(abs(RangeFFTout(:,1,1)))); xlabel('Time(s)');ylabel('Amplitude');
        % plot((1:Rangelen), abs(RangeFFTout(:,1,1))); xlabel('Range(m)');ylabel('Amplitude(dB)');
        % plot((1:RadarParament.Rangelen).*(RadarParament.fadc/RadarParament.NumSample),abs(RangeFFTout(:, PrintfParament.ChirpIdx, PrintfParament.AntennaIdx))); 
        plot((1:(RadarParament.Rangelen)).*RadarParament.Rres, abs(RangeFFTout(:, PrintfParament.ChirpIdx, PrintfParament.AntennaIdx)));
        % plot((1:(RadarParament.Rangelen)).*6.06, abs(RangeFFTout(:, PrintfParament.ChirpIdx, PrintfParament.AntennaIdx))); 
        xlabel('Range(m)');ylabel('Amplitude');
    end
    
    title(sprintf("%dth Frame %dth Chirp TDM-FFT", FrameIdx, PrintfParament.ChirpIdx));
end

% 距离-速度图
if PrintfParament.RDMapEn == 1    
    figure(3);
    if isReal == 1
        % imagesc((abs(DopplerFFTout(1:(Rangelen/2),:,1))));
        % mesh(db(abs(DopplerFFTout(1:(Rangelen/2),:,1))));
        mesh((-RadarParament.dopperlen/2:RadarParament.dopperlen/2-1).*RadarParament.Vres, (1:RadarParament.Rangelen/2).*RadarParament.Rres, db(abs(DopplerFFTout(1:(RadarParament.Rangelen/2), :, PrintfParament.AntennaIdx))));
        title(sprintf("%dth R-D", FrameIdx));
        ylabel('Range(m)');
        xlabel('Velocity(m/s)')
        zlabel('Amplitude (dB)');   
        colorbar;
    else
        % imagesc(db(abs(DopplerFFTout(1:(Rangelen),:,1))));
        mesh((-RadarParament.dopperlen/2:RadarParament.dopperlen/2-1), (1:RadarParament.Rangelen), db(abs(DopplerFFTout(:, :, PrintfParament.AntennaIdx))));
        % mesh((-dopperlen/2:dopperlen/2-1).*RadarParament.Vres, (1:Rangelen).*RadarParament.Rres, db(abs(DopplerFFTout(:,:,1))));
        %title('R-D');
        title(sprintf("%dth R-D", FrameIdx));
        ylabel('Range(m)');
        xlabel('Velocity(m/s)')
        zlabel('Amplitude (dB)');   
        colorbar;
    end
   
end

end