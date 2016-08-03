%% Init

close all
clear
fclose('all');
clc

% filename = 'MOMIC2_P21_0003';
filename = 'MOMIC2_C11_0003';

path = 'E:\MOMIC2_EMG_processing\BrainVisionAnalyzer2\export';

EMGdata = importEMGbinaryfiles(filename, path);


%% abs



for emg = 1 : 4
    EMGdata(emg,:) = abs(EMGdata(emg,:));
end

XY = EMGdata(1,:).*EMGdata(3,:);


%% Normalization

moy_1 = mean(EMGdata(1,:));
moy_2 = mean(EMGdata(2,:));
moy_3 = mean(EMGdata(3,:));
moy_4 = mean(EMGdata(4,:));

EMGdata(1,:) = EMGdata(1,:)/moy_3;
EMGdata(2,:) = EMGdata(2,:)/moy_4;
EMGdata(3,:) = EMGdata(3,:)/moy_1;
EMGdata(4,:) = EMGdata(4,:)/moy_2;


%% xcorr

[C_ext,LAGS_ext]=xcorr(EMGdata(1,:),EMGdata(3,:),'coeff');
[C_fle,LAGS_fle]=xcorr(EMGdata(2,:),EMGdata(4,:),'coeff');

% Figure
figure( ...
    'Name'        , mfilename                , ...
    'NumberTitle' , 'off'                    , ...
    'Units'       , 'Normalized'             , ...
    'Position'    , [0.05, 0.05, 0.90, 0.80]   ...
    )



subplot(2,1,1)
hold all
plot(C_ext,'DisplayName','C_ext')
plot(C_fle,'DisplayName','C_fle')

legend('-DynamicLegend');

subplot(2,1,2)
hold all
plot(LAGS_ext,'DisplayName','LAGS_ext')
plot(LAGS_fle,'DisplayName','LAGS_fle')

legend('-DynamicLegend');

%% Plot

% Figure
figure( ...
    'Name'        , mfilename                , ...
    'NumberTitle' , 'off'                    , ...
    'Units'       , 'Normalized'             , ...
    'Position'    , [0.05, 0.05, 0.90, 0.80]   ...
    )

hold all

% nb = 4
% count = 0;
% for p = [1 3 5]
%     count = count + 1;
%     ax(count) = subplot(nb,1,count);
%     plot(EMGdata(p,:));
% end
% linkaxes(ax,'x')
% 
% ax(end+1) = subplot(nb,1,length(ax)+1);
% plot(XY);
% linkaxes(ax,'x')

ax(1) = subplot(4,1,1);
plot(EMGdata(1,:));
ylabel('abs(extG)')

ax(2) = subplot(4,1,2);
plot(EMGdata(3,:));
ylabel('abs(extD)')

ax(3) = subplot(4,1,3);
plot(EMGdata(5,:));
ylabel('Condition')

ax(4) = subplot(4,1,4);
plot(XY);
ylabel('abs(extG) x abs(extD)')

linkaxes(ax,'x')


%% Read all files


fileList = getAllFilesWithExtention(path, '*.vmrk', 0);

disp(length(fileList))

for f = 1 : length(fileList)
    
    disp(f)
    
    fileList{f}(end-4:end) = [];
    
    % s.(fileList{f}) = importEMGbinaryfiles(fileList{f}, path);
    
%     EMGdata = importEMGbinaryfiles(fileList{f}, path);
    
end

