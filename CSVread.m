function content = CSVread( filename )



%% Open file in write mod

% Open
fileID = fopen( filename , 'r' );
if fileID == -1
    error('could not open file')
end

% Read file as single char of string
fileContent = fread(fileID,'*char')';
fclose(fileID);


%% Parse the file

% Parse the file to fetch ther marker lines
expression = '(\w+);(\w+);(\d+);(\w+)?;(\d+);(\d+)?;(\d)?;(\d)?';
tokens = regexp(fileContent, expression, 'tokens');

% Store the extracted tokens
content = cell(length(tokens),length(tokens{1}));
for t = 1 : length(tokens)
    content(t,:) = tokens{t};
end

for col = 1 : size(content,2)
    if ~all( isnan( str2double( content(:,col) ) ) ) % only txt == 0
        content(:,col) = num2cell( str2double( content(:,col) ) );
    end
end

% rawcontent = textscan(fileID, '%s %s %d %s %d %d %d %d\r','Delimiter',';');
% fclose( fileID );
% content = [ rawcontent{1} rawcontent{2} num2cell(rawcontent{3}) rawcontent{4} num2cell(rawcontent{5}) num2cell(rawcontent{6}) num2cell(rawcontent{7}) num2cell(rawcontent{8}) ];


end % function
