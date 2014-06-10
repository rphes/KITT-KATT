classdef PredictionFilter < handle
    properties (SetAccess = public)
        % Deviation
        DeviationMax
        
        % Current data
        Data = []
        
        % Calibration
        CalibrationCounter = 0
        CalibrationThreshold = 3
        
        % Order
        Order
    end
    
    methods
        function Self = PredictionFilter(DeviationMax, Order)
            Self.DeviationMax = DeviationMax;
            Self.Order = Order;
        end
        
        function Prediction = Predict(Self, Data)
            if Self.Order == 1
                Prediction = Data(length(Data))*2 - Data(length(Data)-1);
            elseif Self.Order == 2
                Prediction = 5/2*TempData(length(TempData))-2*TempData(length(TempData)-1)+1/2*TempData(length(TempData)-2);
            else
                error(['Unknown order ' num2str(Self.Order)]);
            end
        end
        
        function Evaluate(Self, NewValues)
            % Correct orientation of new values
            if size(NewValues, 1) == 1
                NewValues = NewValues';
            end
        
            % If at this stage not enough data is given, nothing can be
            % done
            if (isempty(NewValues)) && (size(Self.Data, 1) < 3)
                warning('Early stage error: could not predict value.');
                return
            end
            
            % Check calibration
            if Self.CalibrationCounter < Self.CalibrationThreshold
                % Calibration mode
                
                % Check if enough data is acquired
                if (size(Self.Data, 1) < 3)
                    % Add new values
                    Self.Data = [Self.Data; NewValues'];
                    return
                else
                    % Calibration is fine if current values are inside
                    % predicted value range
                    
                    % Current data length
                    Length = size(Self.Data(:,1));
                
                    % Check them all
                    AllGood = 1;
                    
                    for i = 1:size(Self.Data, 2)
                        TempData = Self.Data(1:Length, i);
                        
                        % Predicted value
                        Prediction = Self.Predict(TempData);

                        if (sum(isnan(NewValues)) > 0) || (isempty(NewValues)) || (abs(NewValues(i) - Prediction) > Self.DeviationMax)
                            AllGood = 0;
                        end
                    end
                    
                    % Check if all were good
                    if AllGood
                        Self.CalibrationCounter = Self.CalibrationCounter + 1;
                    end
                    
                    % Add new values
                    Self.Data = [Self.Data; NewValues'];
                end
            else
                % Correction mode
                
                % Current data length
                Length = size(Self.Data(:,1));
                
                for i = 1:size(Self.Data, 2)
                    TempData = Self.Data(1:Length, i);
                    
                    % Predicted value
                    Prediction = Self.Predict(TempData);
                    
                    % Filter value
                    if (sum(isnan(NewValues)) > 0) || (isempty(NewValues)) || (abs(NewValues(i) - Prediction) > Self.DeviationMax)
                        Self.Data(Length+1, i) = Prediction;
                    else
                        Self.Data(Length+1, i) = NewValues(i);
                    end
                end
            end
        end
    end
end

