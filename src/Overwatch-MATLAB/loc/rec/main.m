function [measurement] = main(nchan,nsamples,std_dev)
    measurement = pa_wavrecord(1, 5, nsamples, 44100,0, 'asio');
    [trimmed_result, start] = trim_5chan(measurement,100,std_dev);
    for i =1:nchan
        subplot(nchan,1,i)
        plot(trimmed_result(:,i));
        title('trimmed result');
    end
    figure
    for i =1:nchan
        subplot(nchan,1,i)
        plot(measurement(:,i));
        title('measurement');
    end
end