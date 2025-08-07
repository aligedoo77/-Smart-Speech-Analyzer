% ================[ Speech Signal Analysis – Final with Smart Filter ]===============
% Developed by Eng. Ali H Omara 💪
% Features: Recording/Upload, FFT, Noise Removal, Speech Rate, Summary Table
% ===================================================================================

clc;
clear;
close all;

%% STEP 1: Input Audio
choice = menu('Choose input method:', '🎙️ Record from Microphone', '📁 Load Audio File');

if choice == 1
    disp('Recording...');
    recObj = audiorecorder(44100, 16, 1);
    recordblocking(recObj, 5);
    y = getaudiodata(recObj);
    fs = 44100;
    audiowrite('recorded_speech.wav', y, fs);
    disp('Saved as "recorded_speech.wav"');
elseif choice == 2
    [file, path] = uigetfile({'*.wav;*.mp3;*.opus', 'Audio Files'}, 'Select File');
    if isequal(file, 0)
        error('No file selected.');
    end
    [y, fs] = audioread(fullfile(path, file));
else
    error('Invalid choice');
end

% Convert to mono
if size(y,2) > 1
    y = y(:,1);
end

%% STEP 2: Time-Domain Plot
t = (0:length(y)-1)/fs;
figure;
plot(t, y);
xlabel('Time (s)');
ylabel('Amplitude');
title({'Time-Domain Signal'; 'by Eng. Ali H Omara'}, 'FontWeight','bold', 'FontSize', 14);

%% STEP 3: FFT Analysis
N = length(y);
Y = fft(y);
f = (0:N-1)*(fs/N);
magnitude = abs(Y);
halfMag = magnitude(1:floor(N/2));
halfFreq = f(1:floor(N/2));

[maxMag, maxIdx] = max(halfMag);
dominantFreq = halfFreq(maxIdx);
meanFreq = sum(halfFreq .* halfMag') / sum(halfMag);

figure;
plot(halfFreq, halfMag);
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
title({'Frequency-Domain (FFT)'; 'by Eng. Ali H Omara'}, 'FontWeight','bold','FontSize',14);

%% STEP 4: Silence Detection using RMS
frameSize = 1024;
threshold = 0.02;
numFrames = floor(length(y)/frameSize);
silenceFrames = 0;
rms_values = zeros(1, numFrames);

for i = 1:numFrames
    frame = y((i-1)*frameSize + 1 : i*frameSize);
    rms_values(i) = rms(frame);
    if rms(frame) < threshold
        silenceFrames = silenceFrames + 1;
    end
end

silenceDuration = (silenceFrames * frameSize) / fs;
totalDuration = length(y)/fs;
speechDuration = totalDuration - silenceDuration;

%% STEP 5: Speech Rate Estimation
estimatedSyllables = speechDuration * 4;
estimatedWords = estimatedSyllables / 1.5;
speechRate = estimatedWords / totalDuration;

%% STEP 6: RMS Plot
frameTime = (0:numFrames-1)*frameSize/fs;
figure;
plot(frameTime, rms_values);
xlabel('Time (s)');
ylabel('RMS Amplitude');
title({'Silence Detection via RMS'; 'by Eng. Ali H Omara'}, 'FontWeight','bold','FontSize',14);

%% STEP 7: Spectrogram
figure;
spectrogram(y, 256, 200, 512, fs, 'yaxis');
title({'Spectrogram of Speech'; 'by Eng. Ali H Omara'}, 'FontWeight','bold','FontSize',14);

%% STEP 8: Advanced Noise Reduction using Wiener Filter
y = double(y);  % ensure type
filtered_y = wiener2(y, [5 1]);

%% STEP 9: Play Original and Filtered
disp('Playing original audio...');
soundsc(y, fs);
pause(totalDuration + 1);

disp('Playing filtered audio...');
soundsc(filtered_y, fs);
pause(totalDuration + 1);

%% STEP 10: Save Filtered Audio
audiowrite('filtered_speech.wav', filtered_y, fs);
disp('Filtered audio saved.');

%% STEP 11: Display Results Table
resultsData = {
    'Total Duration (s)', totalDuration;
    'Silence Duration (s)', silenceDuration;
    'Speech Duration (s)', speechDuration;
    'Estimated Words', estimatedWords;
    'Speech Rate (words/sec)', speechRate;
    'Dominant Frequency (Hz)', dominantFreq;
    'Mean Frequency (Hz)', meanFreq
};

figure('Name','📊 Analysis Summary – by Eng. Ali H Omara','NumberTitle','off','Color','w', 'Position', [400 300 550 230]);

uitable('Data', resultsData, ...
        'ColumnName', {'Metric', 'Value'}, ...
        'ColumnWidth', {250, 150}, ...
        'FontSize', 12, ...
        'Position', [30 30 480 170]);
