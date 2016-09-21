function plotSegements( runName )
%PLOTSEGEMENTS plots the segemented EMG data from MOMIC2
%   runName such as 'MOMIC2_C03_0002'


%% Check input

if ~( ischar(runName) && size(runName,1)==1 && size(runName,2)>0  )
    error('runName must be char(1,n)')
end


%% Load the data if needed

global MetaData

if isempty(MetaData)
    fileName = 'SegmentedEMG';
    fprintf('Loading ''%s'' \n',fileName)
    load(fileName)
    fprintf('Loading DONE \n')
end


%% Check the runName


file_idx = find(strcmp(MetaData(:,1),runName));
if isempty(file_idx)
    error('invalid run name')
end


%% Figures

conditions = [5 4];

for c = 1 : length(conditions)
    
    switch conditions(c)
        case 4
            column = 6;
        case 5
            column = 7;
    end
    
    % Open an almost fullscreen window
    figure( ...
        'Name'        , [runName ' : Condition ' num2str(conditions(c))], ...
        'NumberTitle' , 'off'                    , ...
        'Units'       , 'Normalized'             , ...
        'Position'    , [0.05, 0.05, 0.90, 0.80]   ...
        )
    
    % extG ----------------------------------------------------------------
    
    ax(1) = subplot(2,2,1);
    hold all
    for seg = 1 : size(MetaData{file_idx,column}.extG,1)
        plot(MetaData{file_idx,column}.extG(seg,:))
    end
    plot(mean(MetaData{file_idx,column}.extG(:,:),1),'LineWidth',4)
    ylabel('extG')
    
    % fleG ----------------------------------------------------------------
    
    ax(2) = subplot(2,2,2);
    hold all
    for seg = 1 : size(MetaData{file_idx,column}.fleG,1)
        plot(MetaData{file_idx,column}.fleG(seg,:))
    end
    plot(mean(MetaData{file_idx,column}.fleG(:,:),1),'LineWidth',4)
    ylabel('fleG')
    
    % extD ----------------------------------------------------------------
    
    ax(3) = subplot(2,2,3);
    hold all
    for seg = 1 : size(MetaData{file_idx,column}.extD,1)
        plot(MetaData{file_idx,column}.extD(seg,:))
    end
    plot(mean(MetaData{file_idx,column}.extD(:,:),1),'LineWidth',4)
    ylabel('extD')
    
    % fleD ----------------------------------------------------------------
    
    ax(4) = subplot(2,2,4);
    hold all
    for seg = 1 : size(MetaData{file_idx,column}.fleD,1)
        plot(MetaData{file_idx,column}.fleD(seg,:))
    end
    plot(mean(MetaData{file_idx,column}.fleD(:,:),1),'LineWidth',4)
    ylabel('fleD')
    
    % Scale adaptation
    
    y1 = ylim(ax(1));
    y2 = ylim(ax(2));
    y3 = ylim(ax(3));
    y4 = ylim(ax(4));
    
    ylim( ax(1) , [ min([y1 y2 y3 y4]) max([y1 y2 y3 y4]) ] )
    
    linkaxes(ax,'xy')
    
end


%%

Min = 50; % pts
Max = 200; % pts
Window = Min:Max;

C4.mean.extG = mean(MetaData{file_idx,6}.extG(:,Window),1);
C4.mean.extD = mean(MetaData{file_idx,6}.extD(:,Window),1);
C4.mean.fleG = mean(MetaData{file_idx,6}.fleG(:,Window),1);
C4.mean.fleD = mean(MetaData{file_idx,6}.fleD(:,Window),1);
[C4.coef.ext,C4.lags.ext]=xcorr(C4.mean.extG,C4.mean.extD,'coeff');
[C4.coef.fle,C4.lags.fle]=xcorr(C4.mean.fleG,C4.mean.fleD,'coeff');
C4.max.ext = max(C4.coef.ext);
C4.max.fle = max(C4.coef.fle);
[C4.RHO.ext,C4.PVAL.ext] = corr(C4.mean.extG',C4.mean.extD');
[C4.RHO.fle,C4.PVAL.fle] = corr(C4.mean.fleG',C4.mean.fleD');

C5.mean.extG = mean(MetaData{file_idx,7}.extG(:,Window),1);
C5.mean.extD = mean(MetaData{file_idx,7}.extD(:,Window),1);
C5.mean.fleG = mean(MetaData{file_idx,7}.fleG(:,Window),1);
C5.mean.fleD = mean(MetaData{file_idx,7}.fleD(:,Window),1);
[C5.coef.ext,C5.lags.ext]=xcorr(C5.mean.extG,C5.mean.extD,'coeff');
[C5.coef.fle,C5.lags.fle]=xcorr(C5.mean.fleG,C5.mean.fleD,'coeff');
C5.max.ext = max(C5.coef.ext);
C5.max.fle = max(C5.coef.fle);
[C5.RHO.ext,C5.PVAL.ext] = corr(C5.mean.extG',C5.mean.extD');
[C5.RHO.fle,C5.PVAL.fle] = corr(C5.mean.fleG',C5.mean.fleD');

fprintf('\n ')
fprintf('XCORR \n ')
fprintf('Condition 4 : ext=%1.3g fle=%1.3g \n ',C4.max.ext, C4.max.fle);
fprintf('Condition 5 : ext=%1.3g fle=%1.3g \n ',C5.max.ext, C5.max.fle);
fprintf('\n ')
fprintf('CORR : RHO \n ')
fprintf('Condition 4 : ext=%1.3g fle=%1.3g \n ',C4.RHO.ext, C4.RHO.fle);
fprintf('Condition 5 : ext=%1.3g fle=%1.3g \n ',C5.RHO.ext, C5.RHO.fle);
fprintf('\n ')
fprintf('CORR : PVAL \n ')
fprintf('Condition 4 : ext=%1.3g fle=%1.3g \n ',C4.PVAL.ext, C4.PVAL.fle);
fprintf('Condition 5 : ext=%1.3g fle=%1.3g \n ',C5.PVAL.ext, C5.PVAL.fle);


end
