function plot_channel_estimate(channel_estimate,xLabel,yLabel,Title)
%USAGE
%input a sequence channel_estimate, desired x and y labels and a title
%   for the plot
%output is a plot of dots with a line connected to a highlighted x-axis
%   and the correct labels and title
%Font and size can be adjusted below
FontSize=17;
FontName='Arial';
plot(channel_estimate,'ro','MarkerSize',15,'MarkerFaceColor','r')
ylim([min(channel_estimate-1) max(channel_estimate+1)])
xlim([0 length(channel_estimate)+1])
%draw lines to x axis
for i=1:length(channel_estimate)
    line([i i],[0 channel_estimate(i)],'LineStyle','-','LineWidth',2,'Color','r')
end
%draw x axis
line([0 length(channel_estimate)+1],[0 0],'LineStyle','-','LineWidth',2)
if xLabel==0
    xlabel('')
else
    xlabel(xLabel,'FontName',FontName,'FontSize',FontSize,'Interpreter','Latex')
end
if yLabel==0
    ylabel('')
else
    ylabel(yLabel,'FontName',FontName,'FontSize',FontSize,'Interpreter','Latex');
end
if Title==0
    title('');
else
    title(Title,'FontName',FontName,'FontSize',FontSize,'Interpreter','Latex')
end

end