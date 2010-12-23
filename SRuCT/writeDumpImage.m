function writeDumpImage(image, file, format, noScaling)
% Writes dump file to disk.
%   function writeDumpImage(image, file, format, noScaling)
%   
%   INPUT PARAMETERS
%       'file' is the filename where to write the image.
%       'image' is an array width x height containing the image data, which
%           must either be of type 'float32' or 'uint16'.
%       'format' is 'dmp' or one of the formats supported by imwrite. A 
%           commonly used format is 'tiff'. If the format is 'dmp', the image 
%           is saved in the dump format (6 bytes header + image data),
%           where as the image data is saved as float32.
%       'noScaling' For image formats other than DMP, scaling is applied
%           before saving the image. If this option is 1, this scaling can
%           be suppressed.
%   Author: Stefan Heinzer, IBT ETH/Uni Zurich
%   Date  : Dec 2003

%--------------------------------------------------------------------------
% Check arguments, prepare parameters needed
%--------------------------------------------------------------------------

if nargin < 1
    error('please submit image data');    
end
if nargin < 3
    format = 'dmp';
else
    if strcmp(format, 'DMP')
        format = 'dmp';    
    end
end
if nargin < 4
    noScaling = 0;
end

if nargin < 1
    file = ['dump.' format];
end

%--------------------------------------------------------------------------
% write file according to format
%--------------------------------------------------------------------------

if strcmp(format, 'dmp')
    fid = fopen(file, 'w');
    if fid == -1
        error(['failed to open/create ' filename]);    
    end
    [height, width] = size(image);
    fwrite(fid, width, 'uint16');
    fwrite(fid, height, 'uint16');
    fwrite(fid, 0, 'uint16');
    fwrite(fid, image', 'float32');
    close(fid);
else
    minVal = min(min(image));
    maxVal = max(max(image));
    % image = double(image);
    image = (image - minVal*ones(size(image)))/(maxVal-minVal);
    imwrite(image, file, format);    
end

