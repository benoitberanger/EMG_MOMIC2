function formatvmrk_start_end(filename)

% output = [filename(1:end-5) '_after.vmrk'];
output = filename;

%% LOAD VMRK
fid = fopen(filename,'r');
X = fread(fid,'*char')';
fclose(fid);


%% AVOID SPLITING SCAN TWICE
X = strrep(X,'R128_tag,','R128_ctr,');


%% SPLIT CTR AND TAG SCAN
X = strrep(X,'R128,','R128_ctr,');
k = strfind(X,'R128_ctr');
for i = 1:length(k)
    if mod(i,2) == 0
        X(k(i)+5:k(i)+7) = 'tag';
    end
end


%% RENAME MARKERS
X = strrep(X,'R128','grad');
X = strrep(X,'S  6,','bloc20,');
X = strrep(X,'S  1,','cross,');
X = strrep(X,'S  4,','flic,');
X = strrep(X,'S  8,','flac,');


%% SPLIT SHORT AND LONG BLOC
k = strfind(X,'bloc20');
k = [k length(X)];
for i = 1:length(k)-1
    l = strfind(X(k(i):k(i+1)),'flic');
    if length(l) > 90
        X(k(i)+4:k(i)+5) = '40';
    end
end

%% SAVE VMRK
fid = fopen(output,'w');
fwrite(fid,X);
fclose(fid);


%% Open file

% Open file in read mode
fid = fopen(output,'r');

% Rewind file
frewind(fid)


%% Count lines : to optimze memory

% Count lines
line_count = 0;
while ~feof(fid)
    fgets(fid);
    line_count = line_count + 1;
end
fprintf( '\n' )
fprintf( '%d lines in %s \n' , line_count , output )

% Rewind file
frewind(fid)


%% Read file & parse it

file_content = cell(line_count,1);

data = cell(line_count,6);

expression = 'Mk(\d+)=([a-zA-Z_\s]+),([0-9a-zA-Z_\s]+|),(\d+),(\d),(\d)';

% Save file content
line_count = 0;
while ~feof(fid)
    
    line_content = fgets(fid);
    line_count = line_count + 1;
    
    file_content{line_count,1} = line_content;
    
    tokens = regexp(line_content,expression,'tokens');
    if ~isempty( tokens )
        data(line_count,:) = tokens{:};
    end
    
end


% Transform each numeric column
for column = [1 4 5 6]
%     data(:,column) = num2cell( str2double( data(:,column) ) );
    data(:,column) = cellfun( @str2double , data(:,column) , 'UniformOutput' , 0 );
end

%% 'Start' and 'End' are present in the file ?

if ~( any(~cellfun( 'isempty' , regexp(data(:,3),'Start') )) || any(~cellfun( 'isempty' , regexp(data(:,3),'End') )) )
    %% Where are markers ?
    
    % Is it a line containing 'Mk[xx]=' ?
    mrk_flag = ~isnan( cell2mat( data(:,1) ) );
    
    % Indexes of lines containing 'Mk[xx]=' ?
    mrk_index = find( mrk_flag );
    fprintf( '%d markers detected \n' , length(mrk_index) )
    
    % Find the first 'grad'
    grad_index = find ( ~cellfun( 'isempty' , regexp(data(:,3),'grad') ) );
    first_grad_index = grad_index(1);
    fprintf( 'first ''grad'' detected @ line = %d , Mk = %d \n' , first_grad_index , data{first_grad_index,1} )
    
    % Find the last 'grad'
    grad_index = find ( ~cellfun( 'isempty' , regexp(data(:,3),'grad') ) );
    last_grad_index = grad_index(end);
    fprintf( 'first ''grad'' detected @ line = %d , Mk = %d \n' , last_grad_index , data{last_grad_index,1} )
    
    
    %% Where put the Start marker ?
    
    SamplingTime = 200; % micro secondes
    Offcet_start = -400*1000 ; % micro seconds
    Offcet_end = +200*1000 ; % micro seconds
    
    
    %% Add 'Start' before the first 'grad'
    
    % Split data in two parts
    dataUP_start = data(1:first_grad_index-1,:);
    dataDOWN_start = data(first_grad_index:end,:);
    
    % Before, we had :
    disp('Before, we had :')
    disp(dataUP_start(end,:))
    disp(dataDOWN_start(1:2,:))
    
    % Add Start marker
    dataUP_start(end+1,:) = { dataUP_start{end,1}+1 'Comment' 'Start' dataDOWN_start{1,4}+Offcet_start/SamplingTime, dataUP_start{end,5} dataUP_start{end,6} };
    
    % Increase marker index
    dataDOWN_start(:,1) = cellfun( @(x) {x+1} , dataDOWN_start(:,1) );
    
    % Collapse UP and DOWN
    data_start = vertcat( dataUP_start , dataDOWN_start );
    
    % Now, we have :
    disp('Now, we have :')
    disp(data_start(first_grad_index-1 : first_grad_index+2,:))
    
    
    %% Add 'End' after the last 'grad'
    
    % Because we add a line, last_grad_index need to be incresed
    last_grad_index = last_grad_index + 1;
    
    % Split data in two parts
    dataUP_end = data_start(1:last_grad_index,:);
    dataDOWN_end = data_start(last_grad_index+1:end,:);
    
    % Before, we had :
    disp('Before, we had :')
    disp(dataUP_end(end,:))
    
    if size(dataDOWN_end,1) > 1
        disp(dataDOWN_end(1:2,:))
    elseif size(dataDOWN_end,1) > 0
        disp(dataDOWN_end(:,:))
    else
        disp(dataDOWN_end(:,:))
    end
    
    % Add Start marker
    dataUP_end(end+1,:) = { dataUP_end{end,1}+1 'Comment' 'End' dataUP_end{end,4}+Offcet_end/SamplingTime, dataUP_end{end,5} dataUP_end{end,6} };
    
    % Increase marker index
    dataDOWN_end(:,1) = cellfun( @(x) {x+1} , dataDOWN_end(:,1) );
    
    % Collapse UP and DOWN
    data_start_end = vertcat( dataUP_end , dataDOWN_end );
    
    % Now, we have :
    disp('Now, we have :')
    disp(data_start_end(last_grad_index-1 : last_grad_index+2,:))
    
    
    %% Write in the .vmrk file
    
    % Open file in read mode
    fid = fopen(output,'w');
    
    % Rewind file
    frewind(fid)
    
    % No modifications over the first lines of the file
    for line = 1 : mrk_index(1)
        fprintf(fid,'%s',file_content{line});
    end
    
    % Over-write the rest of the file
    for line = mrk_index(2) : line_count+2
        fprintf(fid,'Mk%d=%s,%s,%d,%d,%d\n',data_start_end{line,1},data_start_end{line,2},data_start_end{line,3},data_start_end{line,4},data_start_end{line,5},data_start_end{line,6});
    end
    
end

%% Close file

fclose(fid);

end
