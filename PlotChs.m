%% Function to plot data channels
% Arguments:
% data          - Data to plot
% ChansToPlot   - Channels to plot
% Fs            - Sampling frequency

function f = PlotChs(data, ChansToPlot ,Fs)

    f = figure;
    time = [1:1:length(data)]./Fs;
    %{
    color = [
        0.267,0.447,0.769;
        0.267,0.447,0.769;
        0.267,0.447,0.769;
        0.749,0.565,0;
        0.329, 0.51 0.208;
        0.329, 0.51 0.208;
        0.329, 0.51 0.208;
        0.329, 0.51 0.208;
        0.329, 0.51 0.208;
        0.749,0.565,0;
        0.267,0.447,0.769;
        0.267,0.447,0.769;
        0,0,0;
        0,0,0;
        0,0,0;
        0,0,0;
        ];
    %}

    offsets = (1:length(ChansToPlot)).*1000;
    for i = 1:length(ChansToPlot)
        offset = ones(1,length(data)) .* offsets(i);
        %plot(time,data(ChansToPlot(i),:) + offset,15,1000,'color',color(ChansToPlot(i),:),'linewidth',1)
        plot(time,data(ChansToPlot(i),:) + offset,15,1000,'color',[0 0 0],'linewidth',0.5)
        f.Children.YTick = offsets;
        f.Children.YTickLabel{i} = ChansToPlot(i);
        hold on
    end

    xlim([0, time(end)])

    xlabel('Time (s)')
    set(gca,'Fontsize',20)
    %f.Position = [25 1 560 1178];

end