classdef TDOA
    properties (SetAccess = private)
        M; % The deconvolution matrix
        x; % The 1cm recording 
        IsBusyFlag = 0;
        IsReadyFlag= 0;
        R ={}; % the range difference matrix
        settings = struct('Fs', 44100,...
            'peak_threshold', 0.5, ...
            'peak_stddev', 7, ...
            'peak_intervals', 100, ... % no. of intervals divided into
            'trim_threshold', 0.85, ...
            'trim_padding', 750, ...
            'speed_sound', 330, ...
            'nsamples', 44100/8*2); % number of samples to record
        RecData = []; % the raw, recorded data
        RecDataTrimmed = []; % the raw data trimmed to right length
    end
    
    methods
        % Constructor
        function Self = TDOA(M, RXXr, x)
            Self.M=M;
            Self.x=x;
            % not needed when recording:
            data = RXXr(1,:,:);
            data = reshape(data,size(data,2),size(data,3));
            Self.RecData = data;
        end
        
        % Check if TDOA determination is busy
        function Ret = IsBusy(Self)
            Ret = Self.IsBusyFlag;
        end
        
        % Check if TDOA determination is ready
        function Ret = IsReady(Self)
            Ret = Self.IsReadyFlag;
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
            start = [];
            % Find starts
            for i = 1:size(Self.RecData,2)
                % Maximum signal level
                max_sig = max(abs(Self.RecData(:,i)));
                for j = 1:length(Self.RecData(:,i))
                    if Self.RecData(j,i) >= Self.settings.trim_threshold*max_sig
                        start(i) = j;
                        break
                    end
                end
            end
            start = min(start);

            if start-Self.settings.trim_padding <= 0
                result = [zeros(Self.settings.trim_padding-start, size(Self.RecData,2)); Self.RecData];
            else
                result = Self.RecData((start-Self.settings.trim_padding):size(Self.RecData,1),:);
            end
        end
        
        % find peaks with std_dev algorithm
        function [Peak] = FindPeak(Self, data)
            std_interval=[];
            mean_interval=[];
            number_of_intervals=Self.settings.peak_intervals;
            threshold=Self.settings.peak_stddev;
            Peak=0;
            step_size=floor(length(data)/number_of_intervals)-1;
            for i=1:number_of_intervals
                interval_start=1+(i-1)*step_size;
                std_interval(i)=std(data(interval_start:interval_start+step_size));
                mean_interval(i)=mean(std_interval(1:i-1));
                if (i~=1)&&(std_interval(i)/mean_interval(i)>threshold)
                    Peak=interval_start;
                    return
                end
            end
            if (Peak == 0)
                Peak=1;
            end
        end      
        
        % estimate h[n]
        function [h, delay] = EstChannel(Self)
            x = Self.x;
            if size(x,2) > 1
                x = x';
            end    

            N_y = size(Self.M{1},2);
            diff = N_y-length(x);

            if diff > 0
                x = [x;zeros(diff,1)];
            elseif diff < 0
                x = x(1:N_y);
            end

            h = Self.M{1}*x;

            % Find delay
            delay = Self.FindPeak(h);
        end
        
        % make R matrix
        function R = RangeDiff(Self)
            data_trimmed = Self.RecDataTrimmed;
            M = Self.M;
            N = size(data_trimmed,2);
    
            d = [];
            % Recover channel impulse responses
            for i = 1:N
                 [~, d(i)] = Self.EstChannel();
            end

            % Generate R matrix
            for i = 1:N
                for j = (i+1):N
                    R(i,j) = (d(i)-d(j))*Self.settings.speed_sound;
                    R(j,i) = -R(i,j);
                end
            end
        end       
        
        % Range difference matrix retrieval function
        function RangeDiffMatrix = GetRangeDiffMatrix(Self)
            RangeDiffMatrix = Self.R;
        end

        % Start TDOA determination
        function Start(Self)
            % Make sure TDOA indicates it is busy and not ready
            Self.IsBusyFlag = 1;
            Self.IsReadyFlag = 0;
            
            % Record
%             Self.Record5Channels();
            disp('Trimming data');
            Self.RecDataTrimmed = Self.TrimData();
            disp('Trimming done');

            % Deconvolve
            disp('Deconvolving data');
            Self.RangeDiff();
            disp('Deconvolving done');
            
            % Create R matrix
            Self.R = Self.RangeDiff();
            
            % Then set TDOA status to not-busy and processing is ready
            Self.IsBusyFlag = 0;
            Self.IsReadyFlag = 1;
            plot(Self.RecDataTrimmed);
            figure
            plot(Self.RecData);
        end
        
    end
end

