%% Init

close all
clear all
fclose('all');
clc

path_to_rawdata = [fileparts(pwd) 'MOMIC2_EMG_rawdata' ];
path_to_raw_analyzer = [fileparts(pwd) 'MOMIC2_EMG_processing' filesep 'BrainVisionAnalyzer2' filesep 'raw'];


%% Fetch the files names


fileListMRK = getAllFilesWithExtention(path_to_rawdata, '*.vmrk', 1);
fileListHDR = getAllFilesWithExtention(path_to_rawdata, '*.vhdr', 1);
fileListEEG = getAllFilesWithExtention(path_to_rawdata, '*.eeg', 1);


%% Copy the files

disp(length(fileListMRK))

for f = 1 : length(fileListMRK);
    
    disp(f)
    
    [~, name, ext] = fileparts(fileListMRK{f});
    copyfile( fileListMRK{f} , [ path_to_raw_analyzer filesep name ext ] );
    
    [~, name, ext] = fileparts(fileListHDR{f});
    copyfile( fileListHDR{f} , [ path_to_raw_analyzer filesep name ext ] );
    
    [~, name, ext] = fileparts(fileListEEG{f});
    copyfile( fileListEEG{f} , [ path_to_raw_analyzer filesep name ext ] );
    
end
