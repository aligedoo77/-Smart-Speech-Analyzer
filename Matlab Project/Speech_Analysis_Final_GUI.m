function SmartSpeechAnalyzer_GUI()

    %% ====== Global Variables ======
    global y fs filtered_y playerOrig playerFilt modeOrig modeFilt darkMode axOrig axFilt;

    y = [];
    fs = 44100;
    filtered_y = [];
    playerOrig = [];
    playerFilt = [];
    modeOrig = "stopped";
    modeFilt = "stopped";
    darkMode = false;

    %% ====== GUI Figure ======
    f = figure('Name','🔊 Smart Speech Analyzer – Gift to Dr. Ahmed Zakaria',...
        'NumberTitle','off','Color','w','Position',[200 50 1000 720],...
        'Resize','on');

    %% ====== Title ======
    uicontrol('Style','text','String','🔊 Smart Speech Analyzer ',...
        'FontSize',16,'FontWeight','bold','Units','normalized',...
        'Position',[0.3 0.935 0.4 0.04],'BackgroundColor','w');

    uicontrol('Style','text','String','🎓 Dr. Ahmed Zakaria♥',...
        'FontSize',14,'FontAngle','italic','Units','normalized',...
        'Position',[0.4 0.9 0.2 0.03],'BackgroundColor','w');

    %% ====== Audio Input Buttons ======
    uicontrol('Style','pushbutton','String','🎙️ Record','FontSize',12,...
        'Units','normalized','Position',[0.05 0.8 0.12 0.05],'Callback',@recordAudio);

    uicontrol('Style','pushbutton','String','📁 Upload','FontSize',12,...
        'Units','normalized','Position',[0.2 0.8 0.12 0.05],'Callback',@uploadAudio);

    %% ====== Original Controls ======
    uicontrol('Style','pushbutton','String','▶ Play Original','FontSize',11,...
        'Units','normalized','Position',[0.05 0.72 0.12 0.05],'Callback',@playOriginal);

    uicontrol('Style','pushbutton','String','⏸/▶ Pause/Resume','FontSize',11,...
        'Units','normalized','Position',[0.2 0.72 0.12 0.05],'Callback',@pauseResumeOriginal);

    uicontrol('Style','pushbutton','String','🔁 Restart','FontSize',11,...
        'Units','normalized','Position',[0.35 0.72 0.12 0.05],'Callback',@restartOriginal);

    %% ====== Filtered Controls ======
    uicontrol('Style','pushbutton','String','▶ Play Filtered','FontSize',11,...
        'Units','normalized','Position',[0.05 0.64 0.12 0.05],'Callback',@playFiltered);

    uicontrol('Style','pushbutton','String','⏸/▶ Pause/Resume','FontSize',11,...
        'Units','normalized','Position',[0.2 0.64 0.12 0.05],'Callback',@pauseResumeFiltered);

    uicontrol('Style','pushbutton','String','🔁 Restart','FontSize',11,...
        'Units','normalized','Position',[0.35 0.64 0.12 0.05],'Callback',@restartFiltered);

    %% ====== Analyze & Dark Mode Buttons ======
    uicontrol('Style','pushbutton','String','📊 Analyze','FontSize',12,...
        'Units','normalized','Position',[0.82 0.8 0.12 0.05],'Callback',@analyzeAudio);

    uicontrol('Style','pushbutton','String','🌗 Dark Mode','FontSize',12,...
        'Units','normalized','Position',[0.82 0.72 0.12 0.05],'Callback',@toggleDarkMode);

    %% ====== Developer Info Panel ======
    panel = uipanel('Title','Programmed by','FontSize',11,...
        'Units','normalized','Position',[0.02 0.01 0.96 0.08],'BackgroundColor','w');

    uicontrol('Style','text','Parent',panel,'String',...
        'Name: Eng. Ali H Omara   Code: 210071     Name: Eng. Abdullah M. Mustafa   Code: 210062',...
        'Units','normalized','Position',[0.1 0.05 0.8 0.8],'FontSize',10,'BackgroundColor','w',...
        'HorizontalAlignment','center');

    %% ====== Axes for Signals ======
    axOrig = axes('Parent',f,'Units','normalized','Position',[0.06 0.35 0.4 0.22]);
    title(axOrig,'Original Signal'); xlabel(axOrig,'Time (s)'); ylabel(axOrig,'Amplitude');

    axFilt = axes('Parent',f,'Units','normalized','Position',[0.54 0.35 0.4 0.22]);
    title(axFilt,'Filtered Signal'); xlabel(axFilt,'Time (s)'); ylabel(axFilt,'Amplitude');

    %% ====== Record Audio ======
    function recordAudio(~,~)
        recObj = audiorecorder(fs, 16, 1);
        recordblocking(recObj, 5);
        y = getaudiodata(recObj);
        audiowrite('recorded_speech.wav', y, fs);
        msgbox('Recording done and saved.');
        updatePlots();
    end

    %% ====== Upload Audio ======
    function uploadAudio(~,~)
        [file, path] = uigetfile({'*.wav;*.mp3;*.opus','Audio Files'});
        if isequal(file,0), return; end
        [y, fs] = audioread(fullfile(path, file));
        if size(y,2)>1, y = y(:,1); end
        msgbox('Audio Loaded Successfully!');
        updatePlots();
    end

    %% ====== Playback Functions (Original / Filtered) ======
    function playOriginal(~,~)
        if isempty(y), return; end
        playerOrig = audioplayer(y, fs);
        play(playerOrig); modeOrig = "playing";
    end

    function pauseResumeOriginal(~,~)
        if isempty(playerOrig), return; end
        if strcmp(modeOrig, "playing")
            pause(playerOrig); modeOrig = "paused";
        else
            resume(playerOrig); modeOrig = "playing";
        end
    end

    function restartOriginal(~,~)
        if isempty(y), return; end
        playerOrig = audioplayer(y, fs);
        play(playerOrig); modeOrig = "playing";
    end

    function playFiltered(~,~)
        if isempty(filtered_y), return; end
        playerFilt = audioplayer(filtered_y, fs);
        play(playerFilt); modeFilt = "playing";
    end

    function pauseResumeFiltered(~,~)
        if isempty(playerFilt), return; end
        if strcmp(modeFilt, "playing")
            pause(playerFilt); modeFilt = "paused";
        else
            resume(playerFilt); modeFilt = "playing";
        end
    end

    function restartFiltered(~,~)
        if isempty(filtered_y), return; end
        playerFilt = audioplayer(filtered_y, fs);
        play(playerFilt); modeFilt = "playing";
    end

    %% ====== Dark Mode Toggle ======
    function toggleDarkMode(~,~)
        darkMode = ~darkMode;
        bg = [0.1 0.1 0.1]; fg = 'w';
        if ~darkMode
            bg = 'w'; fg = 'k';
        end
        set(f, 'Color', bg);
        allUI = findall(f, '-property', 'BackgroundColor');
        for i = 1:length(allUI)
            try
                set(allUI(i), 'BackgroundColor', bg);
                set(allUI(i), 'ForegroundColor', fg);
            end
        end
        set(axOrig,'Color',bg,'XColor',fg,'YColor',fg);
        set(get(axOrig,'Title'),'Color',fg);
        set(get(axOrig,'XLabel'),'Color',fg);
        set(get(axOrig,'YLabel'),'Color',fg);

        set(axFilt,'Color',bg,'XColor',fg,'YColor',fg);
        set(get(axFilt,'Title'),'Color',fg);
        set(get(axFilt,'XLabel'),'Color',fg);
        set(get(axFilt,'YLabel'),'Color',fg);
    end

    %% ====== Analyze Audio ======
    function analyzeAudio(~,~)
        if isempty(y), return; end

        if darkMode
            bg = darkModeColor(); fg = 'w';
        else
            bg = 'w'; fg = 'k';
        end

        [b, a] = butter(4, [300 3400]/(fs/2), 'bandpass');
        filtered_y = filtfilt(b, a, y);
        updatePlots();

        t = (0:length(y)-1)/fs;
        N = length(y);
        Y = fft(y);
        f_axis = (0:N-1)*(fs/N);
        mag = abs(Y);
        halfMag = mag(1:floor(N/2));
        halfFreq = f_axis(1:floor(N/2));
        [~, maxIdx] = max(halfMag);
        dominantFreq = halfFreq(maxIdx);
        meanFreq = sum(halfFreq .* halfMag') / sum(halfMag);

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
        estimatedSyllables = speechDuration * 4;
        estimatedWords = estimatedSyllables / 1.5;
        speechRate = estimatedWords / totalDuration;

        figPlot = figure('Name','📈 Full Audio Analysis','Color',bg,'Position',[150 150 1000 600]);

        subplot(2,2,1); plot(t, y, 'c'); title('Time-Domain','Color',fg);
        xlabel('Time (s)','Color',fg); ylabel('Amplitude','Color',fg);
        set(gca,'Color',bg,'XColor',fg,'YColor',fg);

        subplot(2,2,2); plot(halfFreq, halfMag, 'm'); title('FFT Spectrum','Color',fg);
        xlabel('Freq (Hz)','Color',fg); ylabel('|Y(f)|','Color',fg);
        set(gca,'Color',bg,'XColor',fg,'YColor',fg);

        subplot(2,2,3); spectrogram(y,256,200,512,fs,'yaxis'); title('Spectrogram','Color',fg);
        set(gca,'Color',bg,'XColor',fg,'YColor',fg);

        subplot(2,2,4);
        frameTime = (0:numFrames-1)*frameSize/fs;
        plot(frameTime, rms_values,'b');
        title('RMS','Color',fg);
        xlabel('Time (s)','Color',fg); ylabel('RMS','Color',fg);
        set(gca,'Color',bg,'XColor',fg,'YColor',fg);

        summary = {
            'Total Duration (s)', totalDuration;
            'Silence Duration (s)', silenceDuration;
            'Speech Duration (s)', speechDuration;
            'Estimated Words', estimatedWords;
            'Speech Rate (w/s)', speechRate;
            'Dominant Freq (Hz)', dominantFreq;
            'Mean Freq (Hz)', meanFreq
        };

        figTable = figure('Name','📊 Summary Table','Color','w','Position',[1180 300 300 270]);
        uitable('Data',summary,'ColumnName',{'Metric','Value'},...
            'FontSize',11,'BackgroundColor','w',...
            'Position',[10 10 280 250]);
    end

    %% ====== Update Plots ======
    function updatePlots()
        if ~isempty(y)
            t = (0:length(y)-1)/fs;
            plot(axOrig, t, y, 'b');
            title(axOrig, 'Original Signal'); xlabel(axOrig, 'Time (s)'); ylabel(axOrig, 'Amplitude');
        end
        if ~isempty(filtered_y)
            t2 = (0:length(filtered_y)-1)/fs;
            plot(axFilt, t2, filtered_y, 'r');
            title(axFilt, 'Filtered Signal'); xlabel(axFilt, 'Time (s)'); ylabel(axFilt, 'Amplitude');
        end
        toggleDarkMode(); toggleDarkMode();
    end

    %% ====== Helpers ======
    function c = darkModeColor()
        if darkMode
            c = [0.15 0.15 0.15];
        else
            c = 'w';
        end
    end

    function c = darkModeAxes()
        if darkMode
            c = [0.2 0.2 0.2];
        else
            c = 'w';
        end
    end
end
