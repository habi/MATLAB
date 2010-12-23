function merge_test(templatesize,detsize,displacement,nrows,snrdb,varargin)
% merge_test(templatesize,detectorsize,displacement,numberofrows,signaltonoiseratio,[showdisplacement[,emptylines]])
%
%   templatesize ....... Width of the phantom image to generate
%   detectorsize ....... Width of the detector 
%   displacement ....... The displacement of the detector between two consecutive images
%   nrows .............. number of rows to use for finding the overlap after applying the noise
%   signaltonoiseratio . Signal to noise ration in DB
%   showdisplacement ....... show diplacement between images insteadof overlap
%   emptylines ......... number of lines to add before and after the image to mimic small samples
%                        ( detector is not square anymore )
%                        (Default: 0 )
  warning off Images:initSize:adjustingMag % suppress the warning about big images
  testslice = phantom('Modified Shepp-Logan',templatesize);% ,'gaussian',0.0,10^(-snrdb/2) / 6) ;
  showdisplacement = 0;
  if nargin > 5 
    showdisplacement = 1;
  end
  if nargin > 6 
    testslice = [ ...
      zeros(varargin{2} , size(testslice,2) ) ; ...
      testslice; ...
      zeros(varargin{2} , size(testslice,2) ) ...
    ];
  end
%  max(max(testslice))
%  figure(1);
%  imshow(testslice,[]);
%  for slice = 1:128;
%    testimg(slice,:) = radon(testslice,10 * rand(1,1));
%  end
%  imrange = max(max(testimg)) - min(min(testimg));
%  testimg = testimg ./ imrange;
%  imrange = max(max(testimg)) - min(min(testimg));
  testimg = testslice;
  figure(1);
  imshow(testimg,[]);
  ov = detsize - abs(displacement);
  if ov < 0 
    ov = 2;
  end
  slicesize = detsize - ov
  fullwidth = size(testimg,2);
  blocks = 2;
  
  slices = [struct('slicedata',[] )];
  slicestart = 1;
  stitched = [];
  if blocks * slicesize + ov > fullwidth
    enlarge = blocks * slicesize + ov - fullwidth;
    testimg = [testimg zeros(size(testimg,1),enlarge)];
  end
  fullwidth = size(testimg,2);
  %for block = blocks:-1:1
  revert = 0;
  for block = 1:blocks
    projection = testimg(:,slicestart:slicestart + detsize - 1);
%    slices(block).slicedata =  - log ( ( slices(block).slicedata ) * 0.6  + 0.3  );
    projection = imnoise(projection,'gaussian',0.0,10^(-snrdb/2)/6 );
    slices(block).slicedata =  projection;
    slicestart = slicestart + slicesize;
  end
  if displacement < 0 
disp 'flipall'
    for block = 1:blocks
      slices(block).slicedata = fliplr(slices(block).slicedata);
    end
  end
  stitched = [slices(:).slicedata ];
  figure(2);
  imshow(stitched,[]);
  overlap = find_overlap(slices(1).slicedata,slices(2).slicedata,nrows,3,showdisplacement);
  if overlap < 0 
    merged =  [ slices(2).slicedata slices(1).slicedata(:,abs(overlap) + 1:detsize) ];
  else 
    merged = [ slices(1).slicedata slices(2).slicedata(:,overlap:detsize) ];
  end
  figure(4);
  imshow(merged,[]);
end
