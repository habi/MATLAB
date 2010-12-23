function [image, width, height] = readDumpImage(filename, lines, type)
% Reads a dump file into memory.
%   function [image, width, height] = readDumpImage(filename, lines, type)
%   
%   INPUT PARAMETERS
%       'filename' is the relative or absolute name of the file.
%       'lines' is a vector containing the line numbers to be read. Values
%           may be duplicate, but must be in [1,height].  Default: [1:height]
%           (read all)
%       'type' is the format of the image pixels, either 'float32' or
%           'uint16'. Default: 'float32'
%       
%   OUTPUT PARAMETERS
%       'image' is a matrix 'height' x 'width' containing the image data.
%       'width' is the width of the dump image.
%       'height' is the height of the dump image.
%
%   EXAMPLE
%       [image, width, height] = readDumpImage('sin.dmp', []);
%       image = readDumpImage('sin.dmp', [1,height]);
%
%       img = readDumpImage('proj0001.DMP', inf, 'int16');
%
%       In the first line, width and height of the image 'sin.dmp' are
%       read. On the second line, the first and the last line of the dump
%       image are read and returned in the variable 'image'.
%
%   Author: Stefan Heinzer, IBT ETH/Uni Zurich
%   Date  : Dec 2003

% Revisions
%   16-Feb-2005 (sth) Added functionality to read tif files


%--------------------------------------------------------------------------
% Check arguments, prepare parameters needed
%--------------------------------------------------------------------------

% treat tif files differently
n = length(filename);
if strcmp(filename(n-3:n), '.tif') | strcmp(filename(n-4:n), '.tiff')
    image = imread(filename);
    width = size(image, 2);
    height = size(image, 1);

    % crop tif image if SLS camera border exists
    % TODO: find better solution, e.g. check first 24 border pixels to be
    % black.
    if width == 1072
        indent = 24;
        image = image(1:height, 1+indent:width-indent);
        width = size(image, 2);
    end

    return;
end

% open file
fid = fopen(filename);
if fid <= 0
    error(['file not found: ' filename]);    
end

dim = fread(fid, 3, 'uint16');
width = dim(1);
height = dim(2);
headerOffset = 6;

if nargin < 3
    type = 'float32';    
end
if nargin < 2 || (~isempty(lines) && max(lines) == inf)
    readAll = 1;
    lines = 1:height;
else
    readAll = 0;
    if max(lines) > height | min(lines) < 1
        fclose(fid);
        error('lines to read must be in 1:height');    
    end
end

if strcmp(type, 'float32')
    pixelTypeSize = 4;
elseif strcmp(type, 'int16')
    pixelTypeSize = 2;
else
    % if you want to read dump images of other pixel types, add an elseif
    % entry specifying the pixelTypeSize for this type.
    fclose(fid);
    error(['unknown pixel type: ' type]);
end

%--------------------------------------------------------------------------
% Read image data
%--------------------------------------------------------------------------

% sizeStr = [num2str(height) ' x ' num2str(width)];
% disp(['reading file "' filename '"; size: ' sizeStr]);
if readAll
    data = zeros(width, height);
    try
    for i=1:height
        data(:,i) = fread(fid, width, type);
        [msg, num] = ferror(fid);
        if num ~= 0
            disp(['line ' num2str(i) ': ' msg]);
            break;
        end
    end
    catch
       [msg, num] = ferror(fid);
       display(['ERROR: line ' num2str(i) ': ' msg]);
       beep;
    end
else
    data = zeros(width, length(lines));
    headerOffset = 6;
    for i = 1:length(lines)
        fseek(fid, headerOffset+(lines(i)-1)*width*pixelTypeSize, -1);
        data(:,i) = fread(fid, width, type');
        [msg, num] = ferror(fid);
        if num ~= 0
            disp(['line ' num2str(i) ': ' msg]);
            break;
        end
    end
end
fclose(fid);

%--------------------------------------------------------------------------
% Do validity checks and prepare output parameters
%--------------------------------------------------------------------------

% check image for NaN (not a number) entries and set them to 0.
badEntries = find(~isfinite(data));
if length(badEntries) > 0
    warning(['data containes ' num2str(length(badEntries)) ' NaN/Inf entries. Setting them to 0.']);
    data(badEntries) = 0;
end

% rotate image by 90�
image = data'; 
clear data;
end
