function [mics] = mds_mic_localization(D, th)
    % Config
    mic_transl = 1;
    mic_rot = 4;
    mic_refl = 2;

    N = size(D, 1);

    % Mean removal
    P = eye(N) - ones(N,N)/N;
    B = (-1/2)*P*D.^2*P;

    % Resolve numerical issues by forcing B to be symmetric
    for i = 1:N
        for j = (i+1):N
            B(i,j) = B(j,i);
        end
    end

    % Orthogonal diagonalization
    [U, S] = eig(B);

    if nargin == 1
        th = 0.5;
    end
    % Filter low eigenvalues
    [vals, inds] = sort(diag(S));
    inds = flipud(inds);
    vals = flipud(vals);

    for i = 1:length(vals)
        if vals(i) < th
            vals(i:length(vals)) = [];
            inds(i:length(inds)) = [];
            break
        end
    end

    U = U(:, inds);
    L = diag(vals);

    % MDS!
    mics = U*L^(1/2);

    % Translation correction
    mic_transl_ref = mics(mic_transl,:);
    for i = 1:size(mics, 1)
        mics(i,:) = mics(i,:) - mic_transl_ref;
    end

    % Rotation correction
    th = atan2(mics(mic_rot,2),mics(mic_rot,1)); % Calculate angle
    T = [cos(th) -sin(th); sin(th) cos(th)]; % Rotation matrix
    mics = mics*T; % Rotate

    % Reflection correction
    if mics(mic_refl,2) < 0
        mics(:,2) = -mics(:,2);
    end
end
