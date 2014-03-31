function calculate_model()
    global sWeight;
    global sRes;
    global sPoles;
    global A;
    global B;
    global C;
    global L;
    global K;

    % Calculate state-space model
    car_weight = get(sWeight, 'Value'); % Weight of car
    car_rolling_coef = get(sRes, 'Value'); % Friction coefficient
    comp_poles = [get(sPoles, 'Value') get(sPoles, 'Value')-0.1]; % Compensator poles

    % State-space model calculation
    A = [0 1;0 -car_rolling_coef/car_weight];
    B = [0;1/car_weight];
    C = [1 0];

    % Observer feedback matrix
    L = place(A',C', [-4 -4.3])';

    % Stabilization matrix
    K = place(A,B, comp_poles);
end