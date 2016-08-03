function [ EMGdata ] = importEMGbinaryfiles( filenameNoExtensionNoPath , pathOfFiles )
%%IMPORTEMGBINARYFILES read a binary file from BrainVisionAnalyzer2
%
% The function uses .dat .vhdr .vmrk, optimized for MOMIC2 EMG data
%
% See also segmentEMGperConditions

allExtensions = {'.dat', '.vhdr', '.vmrk'};


%% Check input

if ~( ischar(filenameNoExtensionNoPath) && size(filenameNoExtensionNoPath,1)==1 && size(filenameNoExtensionNoPath,2)>0 )
    error('input(1) must be a char(1,n)')
end
if ~( ischar(pathOfFiles) && size(pathOfFiles,1)==1 && size(pathOfFiles,2)>0 )
    error('input(2) must be a char(1,n)')
end

if ~isempty( strfind(filenameNoExtensionNoPath, '.') )
    error('%s has an extension', filenameNoExtensionNoPath)
end


%% Check exist

% Path
if exist(pathOfFiles,'dir') == 0
    error('%s is not a folder', pathOfFiles)
end

%Check if .dat .vhdr .vmrk are present
for e = 1 : length(allExtensions)
    
    fileName = [pathOfFiles filesep filenameNoExtensionNoPath allExtensions{e}];
    
    if exist(fileName,'file') == 0
        error('%s is not file', fileName)
    end
    
end


%% Fetch the number of samples in .vhdr

fileName = [pathOfFiles filesep filenameNoExtensionNoPath '.vhdr'];

% Open file
fileID = fopen(fileName, 'r');
if fileID < 3
    error('%s could not be open',fileName)
end

% Read file as single char of string
fileContent = fread(fileID,'*char')';
fclose(fileID);

% Fetch the number of samples
osef = regexp(fileContent, 'DataPoints=(\d*)','tokens','once');
DataPoints = str2double( osef{1} );


%% Import the .dat

fileName = [pathOfFiles filesep filenameNoExtensionNoPath '.dat'];

% Open file
fileID = fopen(fileName, 'r');
if fileID < 3
    error('%s could not be open',fileName)
end

EMGdata = single(zeros(5,DataPoints));
EMGdata(1:4,:) = fread(fileID,[4 DataPoints],'float32');
fclose(fileID);

EMGdata(:,end) = []; % it's only zeros
EMGdata = single(EMGdata);


%% Append the markers from .vmrk

fileName = [pathOfFiles filesep filenameNoExtensionNoPath '.vmrk'];

% Open file
fileID = fopen(fileName, 'r');
if fileID < 3
    error('%s could not be open',fileName)
end

% Read file as single char of string
fileContent = fread(fileID,'*char')';
fclose(fileID);

% Parse the file to fetch ther marker lines
expression = 'Mk(\d+)=([a-zA-Z_\s]+),([0-9a-zA-Z_\s]+|),(\d+),(\d),(\d)';
tokens = regexp(fileContent, expression, 'tokens');
markers = cell(length(tokens),6);
for mrk = 1 : length(tokens)
    markers(mrk,:) = tokens{mrk};
end

% In marker lines, fetch the Stimulus
pattern = 'S  \d+';
stimMarkers_idx = regexp(markers(:,3),pattern);
stimMarkers_idx = ~cellfun(@isempty, stimMarkers_idx);
stimMarkers_idx = find(stimMarkers_idx);

% In EMGdata, add the Stimulus marker to the corresponding sample
for smrk = 1 : length(stimMarkers_idx)
    stimValue = sscanf( markers{stimMarkers_idx(smrk),3} , 'S  %d' );
    EMGdata(5,str2double(markers{stimMarkers_idx(smrk),4})) = stimValue;
end


end
