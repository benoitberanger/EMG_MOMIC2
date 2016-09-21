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

[~,~,MetaDataXLS] = xlsread('MetaDataCECILE_1essSub.xls');


%% xcorr

muscles = {'extG' 'extD' 'fleG' 'fleD'};

for f = 1 : size(MetaDataXLS,1)
    
%     if MetaDataXLS{f,6} == 1
        
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
            
            MetaDataXLS{f,8}  = C4.max.ext;
            MetaDataXLS{f,9}  = C4.max.fle;
            MetaDataXLS{f,10}  = C5.max.ext;
            MetaDataXLS{f,11} = C5.max.fle;
            MetaDataXLS{f,12} = C4.RHO.ext;
            MetaDataXLS{f,13} = C4.RHO.fle;
            MetaDataXLS{f,14} = C5.RHO.ext;
            MetaDataXLS{f,15} = C5.RHO.fle;
            MetaDataXLS{f,16} = C4.PVAL.ext;
            MetaDataXLS{f,17} = C4.PVAL.fle;
            MetaDataXLS{f,18} = C5.PVAL.ext;
            MetaDataXLS{f,19} = C5.PVAL.fle;
            
        end

        
%     end
    
end


%% Select the runs

Controls_idx = cell2mat(MetaDataXLS(:,7))>0 & strcmp(MetaDataXLS(:,2),'C');
Patients_idx = cell2mat(MetaDataXLS(:,7))>0 & strcmp(MetaDataXLS(:,2),'P');

Controls = MetaDataXLS(Controls_idx,8:end);
Patients = MetaDataXLS(Patients_idx,8:end);

hdr = {'xcorr cond4 ext' 'xcorr cond4 fle' 'xcorr cond5 ext' 'xcorr cond5 fle'...
    'corrRHO cond4 ext' 'corrRHO cond4 fle' 'corrRHO cond5 ext' 'corrRHO cond5 fle'...
    'corrPVAL cond4 ext' 'corrPVAL cond4 fle' 'corrPVAL cond5 ext' 'corrPVAL cond5 fle'};

save('PatientsControlsSTATS',...
    'Controls','Patients','hdr')
