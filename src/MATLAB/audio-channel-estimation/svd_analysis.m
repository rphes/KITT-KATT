init;

L = 10:10:200;
subplot_y = 2;
subplot_x = ceil(length(seqs_desc)/subplot_y);

for i = 1:length(seqs_desc)
    L_mat = [];

    sing_vals = [];
    for j = 1:length(L) 
        [h, A] = est_project(x{i},y{i},L(j));
        vals = svd(A)';

        if size(sing_vals,1) == 0
            sing_vals = vals;
        else
            diff = size(sing_vals,2) - length(vals);
            if diff < 0
                sing_vals = [sing_vals zeros(size(sing_vals,1),-diff)];
            end

            sing_vals = [sing_vals;vals];
        end
    end

    for j = 1:size(sing_vals,2)
        L_mat = [L_mat;L];
    end
   
    
    % Go MATLAB :p
    sing_vals(sing_vals == 0) = NaN;
    
    % Find minimum singular value
    val = 100;
    
    for j = 1:size(sing_vals,1)
        for k = 1:size(sing_vals,2)
            if (~isnan(sing_vals(j,k))) && (val > sing_vals(j,k))
                val = sing_vals(j,k);
            end
        end
    end

    subplot(subplot_y,subplot_x,i);
    stem(L_mat',sing_vals,'MarkerEdgeColor','blue', 'MarkerFaceColor','blue', 'LineStyle','none');
    ylim([val-0.05 val+0.2]);
    xlabel 'L';
    ylabel 'Singular values';
    title(['Singular values (' seqs_desc{i} ')']);
    grid on;
end

display '[Done]';