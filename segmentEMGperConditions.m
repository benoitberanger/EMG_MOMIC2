function [ Segements ] = segmentEMGperConditions( EMGdata, Condition , segmentLength )
%% SEGMENTEMGPERCONDITIONS Cuts EMG data into segements
%
% This function uses the output of importEMGbinaryfiles, and some paramers
%
% See also importEMGbinaryfiles

Segements = struct;

% Assiciate channels to the corresponding muscle
extG.raw = EMGdata(1,:);
fleG.raw = EMGdata(2,:);
extD.raw = EMGdata(3,:);
fleD.raw = EMGdata(4,:);
markers  = EMGdata(5,:); % last channel is the stimulation marlers

% Absulute value
extG.abs = abs(extG.raw);
fleG.abs = abs(fleG.raw);
extD.abs = abs(extD.raw);
fleD.abs = abs(fleD.raw);

% Mean of the signal
extG.mean = mean(extG.abs);
fleG.mean = mean(fleG.abs);
extD.mean = mean(extD.abs);
fleD.mean = mean(fleD.abs);

% 'Normalize' the signal with the mean
extG.norm = extG.abs/extD.mean;
fleG.norm = fleG.abs/fleD.mean;
extD.norm = extD.abs/extG.mean;
fleD.norm = fleD.abs/fleG.mean;

% Where is condition ?
condition_idx = find(markers == Condition);

% Pre-allocate some memory
Segements.extG = zeros(length(condition_idx), segmentLength);
Segements.extD = zeros(length(condition_idx), segmentLength);
Segements.fleG = zeros(length(condition_idx), segmentLength);
Segements.fleD = zeros(length(condition_idx), segmentLength);

% Segement
for s = 1 : length(condition_idx)
    
    Segements.extG(s,:) = extG.norm( condition_idx(s):condition_idx(s)+segmentLength-1 );
    Segements.extD(s,:) = extD.norm( condition_idx(s):condition_idx(s)+segmentLength-1 );
    Segements.fleG(s,:) = fleG.norm( condition_idx(s):condition_idx(s)+segmentLength-1 );
    Segements.fleD(s,:) = fleD.norm( condition_idx(s):condition_idx(s)+segmentLength-1 );
    
end

end
