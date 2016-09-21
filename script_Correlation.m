%% Init

close all      % figures
clear          % workspace
fclose('all'); % law-level I/O
clc            % command window


Min = 50; % pts
Max = 200; % pts
Window = Min:Max;

%% Load the data if needed

global MetaData

if isempty(MetaData)
    fileName = 'SegmentedEMG';
    fprintf('Loading ''%s'' \n',fileName)
    load(fileName)
    fprintf('Loading DONE \n')
end


%% Load .xls

[~,~,MetaDataXLS] = xlsread('MetaDataCECILE.xls');


%% xcorr

muscles = {'extG' 'extD' 'fleG' 'fleD'};

for f = 1 : size(MetaDataXLS,1)
    
    if MetaDataXLS{f,6} == 1
        
        for m = 1:length(muscles)
            
            C4.mean.extG = mean(MetaData{f,6}.extG(:,Window),1);
            C4.mean.extD = mean(MetaData{f,6}.extD(:,Window),1);
            C4.mean.fleG = mean(MetaData{f,6}.fleG(:,Window),1);
            C4.mean.fleD = mean(MetaData{f,6}.fleD(:,Window),1);
            [C4.coef.ext,C4.lags.ext]=xcorr(C4.mean.extG,C4.mean.extD,'coeff');
            [C4.coef.fle,C4.lags.fle]=xcorr(C4.mean.fleG,C4.mean.fleD,'coeff');
            C4.max.ext = max(C4.coef.ext);
            C4.max.fle = max(C4.coef.fle);
            [C4.RHO.ext,C4.PVAL.ext] = corr(C4.mean.extG',C4.mean.extD');
            [C4.RHO.fle,C4.PVAL.fle] = corr(C4.mean.fleG',C4.mean.fleD');
            
            C5.mean.extG = mean(MetaData{f,7}.extG(:,Window),1);
            C5.mean.extD = mean(MetaData{f,7}.extD(:,Window),1);
            C5.mean.fleG = mean(MetaData{f,7}.fleG(:,Window),1);
            C5.mean.fleD = mean(MetaData{f,7}.fleD(:,Window),1);
            [C5.coef.ext,C5.lags.ext]=xcorr(C5.mean.extG,C5.mean.extD,'coeff');
            [C5.coef.fle,C5.lags.fle]=xcorr(C5.mean.fleG,C5.mean.fleD,'coeff');
            C5.max.ext = max(C5.coef.ext);
            C5.max.fle = max(C5.coef.fle);
            [C5.RHO.ext,C5.PVAL.ext] = corr(C5.mean.extG',C5.mean.extD');
            [C5.RHO.fle,C5.PVAL.fle] = corr(C5.mean.fleG',C5.mean.fleD');
            
            MetaDataXLS{f,7}  = C4.max.ext;
            MetaDataXLS{f,8}  = C4.max.fle;
            MetaDataXLS{f,9}  = C5.max.ext;
            MetaDataXLS{f,10} = C5.max.fle;
            MetaDataXLS{f,11} = C4.RHO.ext;
            MetaDataXLS{f,12} = C4.RHO.fle;
            MetaDataXLS{f,13} = C5.RHO.ext;
            MetaDataXLS{f,14} = C5.RHO.fle;
            MetaDataXLS{f,15} = C4.PVAL.ext;
            MetaDataXLS{f,16} = C4.PVAL.fle;
            MetaDataXLS{f,17} = C5.PVAL.ext;
            MetaDataXLS{f,18} = C5.PVAL.fle;
            
        end

        
    end
    
end