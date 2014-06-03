classdef Loc
    properties(GetAccess = public, SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = Loc()
        end
        
        % Processing function
        function CurrentLocation = Localize(~, RangeDiff, MicrophoneLocations, Threshold)
            % Makes use of the fact that the system is overdetermined!
            % Therefore, using 3D is not advised.
            N = size(RangeDiff, 1);
            Np = (N*N-N)/2;
            Pairs = zeros(Np, 2);
            D = size(MicrophoneLocations, 2);

            ii = 1;
            for i = 1:N
                for j = (i+1):N
                    Pairs(ii,1) = i;
                    Pairs(ii,2) = j;
                    ii = ii+1;
                end
            end

            % Generate A and B
            A = zeros(Np,2+N-1);
            for i = 1:Np
                i1 = Pairs(i,1);
                i2 = Pairs(i,2);

                A(i,1:D) = 2*(MicrophoneLocations(i2,:) - MicrophoneLocations(i1,:));
                A(i,D+(i2-1)) = -2*RangeDiff(i2,i1);
            end

            b = zeros(Np,1);
            for i = 1:Np
                i1 = Pairs(i,1);
                i2 = Pairs(i,2);

                b(i) = RangeDiff(i1,i2)^2-norm(MicrophoneLocations(i1,:),2)^2+norm(MicrophoneLocations(i2,:),2)^2;
            end

            % Remove possible worst column
            SmallestValue = 0;
            SmallestID = [];

            for i = 1:size(A,2)
                Value = sum(abs(A(:,i)));

                if Value < Threshold
                    if (Value < SmallestValue) || (isempty(SmallestID))
                        SmallestValue = Value;
                        SmallestID = i;
                    end
                end
            end

            A(:, SmallestID) = [];

            % Least squares approximation
            CurrentLocation = (A'*A)^-1*A'*b;
            CurrentLocation = CurrentLocation(1:D)';
        end
    end
end