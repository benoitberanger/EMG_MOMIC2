%% Init

close all
clear all
fclose('all');
clc

% path_to_rawdata = [fileparts(pwd) 'MOMIC2_EMG_processing' filesep 'export' ];
path_to_rawdata = [fileparts(pwd) 'MOMIC2_EMG_rawdata' ];

fileList = getAllFilesWithExtention(path_to_rawdata, '*.vmrk', 1);


%%

for f = 1 : length(fileList);
    
    filename = fileList{f};
    
    fid = fopen(filename,'r');
    fileContent = fread(fid,'*char')';
    fclose(fid);
    
    R128found = strfind(fileContent,'R128');
    
    if ~isempty(R128found)
        
        fileList{f,2} = 'R128';
        disp(filename)
        
    else
        
        fileList{f,2} = '';
        
    end
    
end
