classdef TDOA < hgsetget
    properties (SetAccess = private)
        M; % The deconvolution matrix
        %         x; % The 1cm recording
        IsBusyFlag = 0;
        IsReadyFlag= 0;
        R=[]; % the range difference matrix
        h=[]; % the obtained channel impulse responses
        settings = struct('Fs', 48000,...
            'peak_threshold', 1, ...
            'peak_stddev', 4, ...
            'peak_intervals', 600, ... % no. of intervals divided into
            'peak_maxinterval', 1000, ... % maximum no. of samples btwen pks
            'trim_threshold', 0.8, ...
            'trim_padding', 250, ... % no. of trailing zeros
            'trim_spacing', 250, ... % no. of samples as 'prediction error'
            'trim_length', 10000, ... % no. of samples the trimmed data should be
            'speed_sound', 330, ...
            'nsamples', 44100/8*2, ... % number of samples to record
            'loc_threshold',0.05);
        RecData = []; % the raw, recorded data
        RecDataTrimmed = []; % the raw data trimmed to right length
        RecDataSegment = {}; % the trimmed data is cut into segments stored in this variable
        % debatable if needed:
%                 MicrophoneLocations = [
%                     0 0;
%                     0 1;
%                     1 1;
%                     1 0;
%                     0.5 0;
%                     ];
        MicrophoneLocations = [
            0     0;
            0     2.9;
            2.9   2.9;
            2.9   0;
            -0.95 1.45
            ];
        x={};
    end
    
    methods
        % Constructor
%         function Self = TDOA(M, RXXr, RXXrPoint, x)
            function Self = TDOA(RXXr,RXXrPoint,x)
%             set(Self,'M',M);
            % not neededwhen recording:
            data = RXXr(RXXrPoint,:,:);
            data = reshape(data,size(data,2),size(data,3));
            set(Self,'RecData',data);
            set(Self,'x',x);
        end
        
        % Check if TDOA determination is busy
        function Ret = IsBusy(Self)
            Ret = get(Self,'IsBusyFlag');
        end
        
        % Check if TDOA determination is ready
        function Ret = IsReady(Self)
            Ret = get(Self,'IsReadyFlag');
        end
        
        % function to record the right amount of samples (>=2 periods)
        function Record5Channels(Self)
            Self.RecData = pa_wavrecord(1, 5, Self.settings.nsamples, Self.settings.Fs, 0, 'asio');
            if isEmpty(Self.RecData)
                disp('Recording is empty');
            end
        end
        
        % function to trim the recorded data to the right length
        function [result] = TrimData(Self)
            temp=Self.RecData;
            data=abs(temp);
            start = size(data,1)*ones(1,size(data,2));
            level=Self.settings.trim_threshold;
            padding = Self.settings.trim_padding;
            % Find starts
            max_sig = max(max(data));
            for i = 1:size(data,2)
                for j = 1:size(data,1)
                    if abs(data(j,i)) >= level*max_sig
                        start(i) = j;
                        break
                    end
                end
            end
            if start>Self.settings.trim_spacing
                start = min(start)-Self.settings.trim_spacing;
            else
                start = 1;
            end
            if start-padding <= 0
                data = [zeros(padding-start, size(temp,2)); temp];
            else
                data = temp((start-padding):size(temp,1),:);
            end
            size(data)
            result = data(1:Self.settings.trim_length,:);
        end
        
        function [DataSegment] = TrimDataToIntervals(Self)
            Data = Self.RecDataTrimmed;
            PeakThreshold = 0.65;
            SpacingCoefficient = 0.9;
            PeakFrequency = 8;
            Fs = 48000;
            Shrink = 500;
            
            % Calculate stuff
            PeakSkip = round(Fs/PeakFrequency*SpacingCoefficient);
            IntervalLengthHalf = round(Fs/PeakFrequency/2);
            
            Peaks = {};
            PeaksQuality = [];
            NumberPeaks = 0;
            
            % Find peaks
            for Set = 1:5
                MaxLevel = max(Data(:, Set));
                TriggerLevel = MaxLevel*PeakThreshold;
                
                Peaks{Set} = [];
                
                Sample = 1;
                while Sample < length(Data(:, Set))
                    if Data(Sample, Set) >= TriggerLevel
                        Peaks{Set} = [Peaks{Set} Sample];
                        NumberPeaks = NumberPeaks + 1;
                        
                        % Skip
                        Sample = Sample + PeakSkip;
                    else
                        Sample = Sample + 1;
                    end
                end
                
                SetQuality = std(Data(:, Set))/max(Data(:, Set));
                
                % Determine quality
                PeaksQuality = [PeaksQuality SetQuality];
            end
            
            % Determine point
            [~, PeaksBestQuality] = min(PeaksQuality);
            PeaksBoundary = Peaks{PeaksBestQuality}(1) - IntervalLengthHalf;
            
            % Make negative
            while PeaksBoundary > 0
                PeaksBoundary = PeaksBoundary - 2*IntervalLengthHalf;
            end
            
            % Great succes
            % Much good
            
            DataSegmented = {};
            DataSegmentedBounds = {};
            
            % Now segment data
            Index = 1;
            for Interval = PeaksBoundary:(2*IntervalLengthHalf):size(Data,1)
                % The best peaks correspond most likely to the closest mic, therefore
                % shrinking could prevent errors
                
                % Determine boundary
                IntervalBegin = Interval+Shrink;
                IntervalEnd = Interval + 2*IntervalLengthHalf;
                
                % Check boundaries
                if IntervalBegin < 1
                    IntervalBegin = 1;
                end
                
                if IntervalBegin > size(Data,1)
                    continue
                end
                
                if IntervalEnd > size(Data,1)
                    IntervalEnd = size(Data,1);
                end
                
                % Create segment
                DataSegmentedBounds{Index} = [IntervalBegin IntervalEnd];
                DataSegment{Index} = Data(IntervalBegin:IntervalEnd, :);
                Index = Index + 1;
            end
            
            % Plot
%             figure(1);
%             hold off;
%             for Index = 1:5
%                 subplot(5,1,Index);
%                 Time = (1:length(Data(:, Index)))/Fs;
%                 plot(Time, Data(:, Index));
%                 title(['Channel ' num2str(Index)]);
%                 xlabel 'Time (s)';
%                 ylabel 'Amplitude';
%                 hold on;
%                 
%                 MaxValue = max(Data(:, Index));
%                 
%                 for Segment = 1:length(DataSegmentedBounds)
%                     stem(DataSegmentedBounds{Segment}/Fs, MaxValue*[1 1], 'r');
%                 end
%             end
        end
        
        % find peaks
        function [Peak] = FindPeak(Self, k)
            data = Self.h{k};
            if isempty(data)
                disp('empty dataset');
            end
            Peak = ones(1,size(data,2));
            % Step 1: Find maximum peak in all samples
            MaxInterval = Self.settings.peak_maxinterval;
            maxloc = ones(1,size(data,2));
            Height = ones(1,size(data,2));
            Peak = ones(1, size(data,2));
            for i = 1:size(data,2)
                [~, maxloc(i)] = findpeaks(data(:,i),'SORTSTR','descend','NPEAKS',1);
            end
            maxloc = maxloc(1);
            % Step 2: Set interval to [maxloc-size, maxloc+size]
            if (maxloc-MaxInterval<=0 && maxloc+MaxInterval<=size(data,1))
                NewVal = [1, maxloc+MaxInterval];
            elseif (maxloc+MaxInterval>size(data,1) && maxloc-MaxInterval>0)
                NewVal = [maxloc-MaxInterval, size(data,1)];
            elseif (maxloc+MaxInterval>size(data,1) && maxloc-MaxInterval<=0)
                NewVal = [1, size(data,1)];
            else
                NewVal = [maxloc-MaxInterval, maxloc+MaxInterval];
            end
            % Step 3: Find peaks in NewVal of all recordings
            data = data(NewVal(1):NewVal(2),:);
            for i = 1:size(data,2)
                [Height(i), Peak(i)] = findpeaks(data(:,i),'SORTSTR','descend','NPEAKS',1);
                % plot result
%                 subplot(5,1,i)
%                 plot(data(:,i))
%                 hold on
%                 plot(Peak(i),Height(i),'r+');
%                 hold off
%                 if i == 5
%                     figure
%                 end
            end
            
        end
        
        % estimate h[n] with MF        
        function [h] = EstMatched(Self,ii, i)
            x1 = Self.x{i};
            y = Self.RecDataSegment{ii}(:,i);
            N_x = length(x1);
            N_y=length(y);
            L = N_y-N_x+1;
            xr = flipud(x1);
            h{1} = filter(xr,1,y);
            h{1} = h{1}(N_x+1:end);
            alpha = x1'*x1;
            h{1} = h{1}/alpha;
        end
        
        % make R matrix
        function R = RangeDiff(Self,k)
            N = size(Self.RecDataTrimmed,2);
            d = [];
            % Find sample number of peak
            for m=1:N
                d(m) = Self.FindPeak(k)./Self.settings.Fs;
            end
            % Generate R matrix
            R=[];
            for i = 1:N
                for j = (i+1):N
                    R(i,j) = (d(i)-d(j))*Self.settings.speed_sound;
                    R(j,i) = -R(i,j);
                end
            end
        end
        
        % Range difference matrix retrieval function
        function RangeDiffMatrix = GetRangeDiffMatrix(Self)
            RangeDiffMatrix = get(Self,'R');
        end
        
        % Start TDOA determination
        function Start(Self)
            % Make sure TDOA indicates it is busy and not ready
            set(Self,'IsBusyFlag',1,'IsReadyFlag',0);
            % Record
            %             Self.Record5Channels();
            set(Self,'RecDataTrimmed',Self.TrimData());
            % Cut trimmed data recordings into segments
            set(Self,'RecDataSegment',Self.TrimDataToIntervals());
            % Now, for each interval we want to do the localization
            % using the new interval data
            for ii=1:size(Self.RecDataSegment,2);
                for i = 1:size(Self.RecDataTrimmed,2)
                    set(Self,'h',[Self.h, Self.EstMatched(ii,i)]);
                end
                % Each data segment must then be localized..
                set(Self,'R',Self.RangeDiff(ii));
                % .. and plotted.
                figure
                for p=1:5
                    subplot(5,1,p)
                    plot(Self.h{p})
                end
                title([num2str(ii)]);
            end
            % Create R matrix
            % Then set TDOA status to not-busy and processing is ready
%            
%             figure
%             subplot(2,1,2)
%             plot(Self.RecDataTrimmed);
%             xlim([0 18000]);
%             title('trimmed');
%             subplot(2,1,1)
%             plot(Self.RecData);
%             xlim([0 18000]);
%             title('original');
            set(Self,'IsBusyFlag',0,'IsReadyFlag',1);
        end
        
    end
end

