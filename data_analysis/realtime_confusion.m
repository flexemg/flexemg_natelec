%% reset workspace
close all
clear
clc

%% define gestures
gestDict = containers.Map ('KeyType','int32','ValueType','any');
gestDict(100) = 'Rest';
gestDict(101) = 'IndFlex';
gestDict(102) = 'IndExt';
gestDict(103) = 'MidFlex';
gestDict(104) = 'MidExt';
gestDict(105) = 'RinFlex';
gestDict(106) = 'RinExt';
gestDict(107) = 'PinFlex';
gestDict(108) = 'PinExt';
gestDict(109) = 'ThuFlex';
gestDict(110) = 'ThuExt';
gestDict(111) = 'ThuAdd';
gestDict(112) = 'ThuAbd';
gestDict(201) = 'One';
gestDict(202) = 'Two';
gestDict(203) = 'Three';
gestDict(204) = 'Four';
gestDict(205) = 'Five';
gestDict(206) = 'ThumbUp';
gestDict(207) = 'Fist';
gestDict(208) = 'Flat';

%% 13 single-DOF gesture baseline results
files = dir('./realtime_data/*.mat');
gather_realtime_results(files,2,gestDict);

%% 8 multi-DOF gesture baseline results
% files = dir('./realtime_data/*mu*.mat');
% gather_realtime_results(files,6,gestDict);

%% 21-gesture append baseline results
% files = dir('./realtime_data/*mu*.mat');
% gather_realtime_results(files,4,gestDict);

%% Arm position before update
% files = dir('./realtime_data/*ap*.mat');
% gather_realtime_results(files,3,gestDict);

%% Arm position after update baseline
% files = dir('./realtime_data/*ap*.mat');
% gather_realtime_results(files,5,gestDict);

%% Arm position after update new
% files = dir('./realtime_data/*ap*.mat');
% gather_realtime_results(files,6,gestDict);

%% New day before update
% files = dir('./realtime_data/*nd*.mat');
% gather_realtime_results(files,3,gestDict);

%% New day after update new
% files = dir('./realtime_data/*nd*.mat');
% gather_realtime_results(files,5,gestDict);

%% Prolong before update
% files = dir('./realtime_data/*pw*.mat');
% gather_realtime_results(files,3,gestDict);

%% Prolong after update new
% files = dir('./realtime_data/*pw*.mat');
% gather_realtime_results(files,5,gestDict);

%% function gathering results
function gather_realtime_results(files,sessionNum,gestDict)
    holdLabel = [];
    holdLabelHat = [];
    allLabel = [];
    allLabelHat = [];
    for f = files'
        load([f.folder '/' f.name]);
        session = experiment(sessionNum).trials;
        for g = 1:length(session)
            prediction = session(g).prediction;
            label = session(g).offlineLabel;
%             label = 100.*ones(size(session(g).prediction));
%             label((session(g).onsetUser:session(g).offsetUser)./50) = session(g).gesture;
            if length(prediction) ~= length(label)
                minLength = min([length(label) length(prediction)]);
                prediction = prediction(1:minLength);
                label = label(1:minLength);
            end
            holdStart = find(diff(session(g).blindLabel) > 0,1);
            holdEnd = find(diff(session(g).blindLabel) < 0,1,'last')-1;
            holdLabelHat = [holdLabelHat; prediction(holdStart:holdEnd)];
            holdLabel = [holdLabel; label(holdStart:holdEnd)];
            allLabelHat = [allLabelHat; prediction];
            allLabel = [allLabel; label];
        end
    end

    f = figure;
    plot_confusion_matrix(holdLabel,holdLabelHat,gestDict,f,false);
%     f = figure;
%     plot_confusion_matrix(allLabel,allLabelHat,gestDict,f,false);
end

%% main plotting function for confusion matrix
function plot_confusion_matrix(correct,predict,gestDict,f,cbar)
    % calculate overall accuracy
    accuracy = sum(correct == predict)/length(predict);
    % get only gestures involved with this experiment
    gestures = sort(cell2mat(gestDict.keys));
    gestures(~ismember(gestures,unique([correct; predict]))) = [];
    gestureLabels = cell(size(gestures));
    for i = 1:length(gestures)
        gestureLabels{i} = gestDict(gestures(i));
    end
    c = confusionmat(correct,predict,'Order',gestures);
    c = c./repmat(sum(c,2),1,length(gestures)).*100;
    c = round(c.*100)./100;
    
    gestAvgAcc = mean(diag(c));

    baseSize = 700;
    baseGest = 13;
    scaledSize = round(baseSize*length(gestures)/baseGest);

    set(f,'Position',[100 100 scaledSize 2*scaledSize])
    imagesc(c)
    colormap(flipud(gray(2048)))
    axis square
    xticks(1:length(gestures));
    xticklabels(gestureLabels);
    xtickangle(45);
    yticks(1:length(gestures));
    yticklabels(gestureLabels);
    set(gca, 'FontSize', 14)

    ylabel('Actual Gesture','FontSize',16,'FontWeight','bold')
    xlabel('Predicted Gesture','FontSize',16,'FontWeight','bold')
    caxis([0 100])
    if cbar
        cb = colorbar('west');
        set(cb,'position',[.855 .48 .02 0.25]);
        ylabel(cb,'Percentage');
        set(cb, 'YAxisLocation','left')
    end
    for i = 1:length(gestures)
        for j = 1:length(gestures)
            if c(i,j) > 0
                accTxt = num2str(c(i,j));
                if i == j
                    text(j,i, accTxt,'Color','white','FontSize',12,'VerticalAlignment','middle','HorizontalAlignment','center')
                else
                    text(j,i, accTxt,'Color','red','FontSize',12,'VerticalAlignment','middle','HorizontalAlignment','center')
                end
            end
        end
    end
    title({['Overall accuracy: ' num2str(accuracy*100) '%']; 
        ['Non-weighted accuracy: ' num2str(gestAvgAcc) '%']});
end