classdef TDOA < hgsetget
    properties (SetAccess = private)
        M; % The deconvolution matrix
        %         x; % The 1cm recording
        IsBusyFlag = 0;
        IsReadyFlag= 0;
        R=[]; % the range difference matrix
        settings = struct('Fs', 48000,...
            'peak_threshold', 0.65, ...
            'peak_stddev', 4, ...
            'peak_intervals', 600, ... % no. of intervals divided into
            'trim_threshold', 0.8, ...
            'trim_padding', 50, ... % no. of trailing zeros
            'trim_spacing', 250, ... % no. of samples as 'prediction error' 
            'speed_sound', 340, ...
            'nsamples', 44100/8*2, ... % number of samples to record
            'loc_threshold',0.05);
        RecData = []; % the raw, recorded data
        RecDataTrimmed = []; % the raw data trimmed to right length
        % debatable if needed:
                MicrophoneLocations = [
                    0 0;
                    0 1;
                    1 1;
                    1 0;
                    0.5 0;
                    ];
%         MicrophoneLocations = [
%             0     0;
%             0     2.9;
%             2.9   2.9;
%             2.9   0;
%             -0.95 1.45
%             ];
    end
    
    methods
        % Constructor
        function Self = TDOA(M, RXXr, RXXrPoint)
            set(Self,'M',M);
            % not neededwhen recording:
            data = RXXr(RXXrPoint,:,:);
            data = reshape(data,size(data,2),size(data,3));
            set(Self,'RecData',data);
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
            result = data;
        end
        
        % find peaks with std_dev algorithm
        function [Peak] = FindPeak(Self, data)
            std_interval=[];
            mean_interval=[];
            number_of_intervals=Self.settings.peak_intervals;
            threshold=Self.settings.peak_stddev;
%             Peak=0;
%             step_size=floor(length(data)/number_of_intervals)-1;
%             for i=1:number_of_intervals
%                 interval_start=1+(i-1)*step_size;
%                 std_interval(i)=std(data(interval_start:interval_start+step_size));
%                 mean_interval(i)=mean(std_interval(1:i-1));
%                 if (i~=1)&&(std_interval(i)/mean_interval(i)>threshold)
%                     Peak=interval_start;
%                     return
%                 end
%             end
            Peak = 0;
            maxval = max(abs(data));
            for i=1:length(data)
                if abs(data(i))>=Self.settings.peak_threshold*maxval
                    Peak = i;
                    break;
                end
            end
            if (Peak == 0)
                Peak=1;
            end
        end
        
        % estimate h[n]
        function [h, delay] = EstChannel(Self, i)
            x{i} = Self.RecDataTrimmed(:,i);
            N_y = size(Self.M{i},2);
            diff = N_y-length(x{i});
            
            if diff > 0
                x{i} = [x{i};zeros(diff,1)];
            elseif diff < 0
                x{i} = x{i}(1:N_y);
            end
            h = Self.M{i}*x{i};
            
            %             Find delay
            delay = Self.FindPeak(h)/Self.settings.Fs;
            %   Plot delay
%             sampleno = Self.FindPeak(h);
%             subplot(5,1,i)
%             title(['recording number' num2str(i)]);
%             plot(h)
%             hold on;
%             plot(sampleno,h(sampleno),'r+');
%             hold off;
        end
        
        % make R matrix
        function R = RangeDiff(Self)
            N = size(Self.RecDataTrimmed,2);
            
            d = [];
            % Recover channel impulse responses
            for i = 1:N
                [~, d(i)] = Self.EstChannel(i);
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
            %             Self.IsBusyFlag = 1;
            %             Self.IsReadyFlag = 0;
            
            % Record
            %             Self.Record5Channels();
            set(Self,'RecDataTrimmed',Self.TrimData());
            
            % Create R matrix
            set(Self,'R',Self.RangeDiff());
            
            % Then set TDOA status to not-busy and processing is ready
            set(Self,'IsBusyFlag',0,'IsReadyFlag',1);
%            
            figure
            subplot(2,1,2)
            plot(Self.RecDataTrimmed);
            xlim([0 18000]);
            title('trimmed');
            subplot(2,1,1)
            plot(Self.RecData);
            xlim([0 18000]);
            title('original');
        end
        
    end
end

