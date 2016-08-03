%% Init

close all      % figures
clear          % workspace
fclose('all'); % law-level I/O
clc            % command window

global MetaData


%% Fetch file list

% Where are the files
path_to_binarydata = [fileparts(pwd) filesep 'BrainVisionAnalyzer2' filesep 'export'];
if ~exist(path_to_binarydata,'dir')
    error('%s is not a valid directory',path_to_binarydata)
end 

% Fetch the list
MetaData = getAllFilesWithExtention(path_to_binarydata, '*.dat', 0);
if isempty(MetaData)
    error('no .dat file found in %s',path_to_binarydata)
end 

% Take out the extension
for f = 1 : length(MetaData)
    MetaData{f}(end-3:end) = [];
end


%% Parse the file name

% Header
MetaData_hdr = {'file name', 'subject ID', 'Patients or Control', 'visite', 'run number'};

% Expression to parse the files names
expression = '^MOMIC2_([a-zA-Z]+)(\d+)_?(\w+)?_?_(\d+)$';

% Parse the files names
tokens = regexp(MetaData(:,1),expression,'tokens');

% Fill fileList with the tokens
for f = 1 : length(tokens)
    if ~isempty(tokens{f})
        l = length(tokens{f}{:});
        content = tokens{f}{:};
        MetaData(f,2:1+l) = content;
    end
end


%% Parameters for segementations

segmentTime = 3;     % seconds : time of the segements we want to extract from the EMG
sampleTime  = 1/100; % seconds : time between each samples, i.e. 1/samplingfrequency

segmentLength = segmentTime/sampleTime; % number of samples per segments


%% Load files & segement them

MetaData_hdr{end+1} = 'segements condition 4';
MetaData_hdr{end+1} = 'segements condition 5';

for f = 1 : length(MetaData)
    
    % Echo in CommandWindow
    fprintf('%d | segementation of %s \n',f,MetaData{f,1})
    
    % Import the data
    EMGdata = importEMGbinaryfiles( MetaData{f,1} , path_to_binarydata );
    
    % Segement each conditions we want : 4 and 5
    MetaData{f,6} = segmentEMGperConditions( EMGdata, 4, segmentLength );
    MetaData{f,7} = segmentEMGperConditions( EMGdata, 5, segmentLength );
    
end

save('SegmentedEMG',...
    'MetaData','MetaData_hdr','path_to_binarydata','segmentTime','sampleTime','segmentLength')
