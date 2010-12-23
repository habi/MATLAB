function merge_test(templatesize,detsize,ov,nrows,stepwidth,steprange,snrdb)

testing = 1

% testing on below
%%function merge_test(templatesize,detsize,ov,nrows,stepwidth,steprange,snrdb)    
if testing == 1
    templatesize = 1024
    detsize = 512 
    ov = 128
    nrows = 10 
    stepwidth = 10      
    steprange = 1:.1:5
    snrdb = 10
end
% testing on above

  testslice = phantom('Modified Shepp-Logan',templatesize);% ,'gaussian',0.0,10^(-snrdb/2) / 6) ;
  scrsz = get(0,'ScreenSize');
  templatesize
  testimg = testslice;
  figure('Position',[25 scrsz(4)/2 scrsz(3)/2 scrsz(4)/3])
    imshow(testimg,[]);
  slicesize = detsize - ov
  fullwidth = size(testimg,2)
  blocks = ceil( ( fullwidth - ov ) / slicesize )
  slices = [struct('slicedata',[] )];
  slicestart = 1;
  stitched = [];
  if blocks * slicesize + ov  - fullwidth >= detsize
    reduce = floor(( blocks * slicesize + ov  - fullwidth ) / detsize);
    blocks = blocks - reduce ;
  end
  if blocks * slicesize + ov > fullwidth
    enlarge = blocks * slicesize + ov - fullwidth;
    testimg = [testimg zeros(size(testimg,1),enlarge)];
  end
  testimagesize = size(testimg,2)
  %for block = blocks:-1:1
  for block = 1:blocks
    slices(block) = struct('slicedata',testimg(:,slicestart:slicestart + detsize - 1));
%    slices(block).slicedata =  - log ( ( slices(block).slicedata ) * 0.6  + 0.3  );
    slices(block).slicedata = imnoise(slices(block).slicedata,'gaussian',0.0,10^(-snrdb/2)/6 );
    stitched = [stitched slices(block).slicedata];
    slicestart = slicestart + slicesize;
  end
  figure('Position',[25 0 scrsz(3)/2 scrsz(4)/3])
    imshow(stitched,[]);
  nrowspace = floor( size(testimg,1) / nrows ); 
  errvals = [];
  step = 1;
  steps = [];
  for searchwidth = steprange(1):stepwidth:steprange(2) - 1
    errvals(step,:) = correlate(slices,blocks,nrows,nrowspace,searchwidth + 1,testimg);
    steps(step) = searchwidth + 1;
    step = step + 1;
  end
  minval = [];
  minidx = [];
  figure(3);
  [minval minidx] = min(errvals);
  plot(steps,errvals);
  subplot(1,1,1);
  notches = [];
  sidestep = floor(5 / stepwidth)
  if sidestep < 1 
    sidestep = 1;
  end
  for block = 1:blocks - 1;
    notches(:,block) = errvals(minidx(block)-sidestep:minidx(block)+sidestep,block);
  end
  notches
  minidx = steps(minidx)
  merged = slices(1).slicedata;
  for block = 2:blocks
    merged = [ merged slices(block).slicedata(:,minidx(block - 1) + 1:detsize) ];
  end
  figure(4);
  imshow(merged,[]);
if testing == 1
end
end

function errval = correlate(slices,blocks,nrows,nrowspace,searchwidth,testimg)
  corrs = struct('correlation',[],'cutat',0);
  val = [];
  pos = [];
  for block = 1:blocks-1
    width1 = size(slices(block).slicedata,2);
    width2 = size(slices(block +1).slicedata,2);
    height1 = size(slices(block).slicedata,1);
    height2 = size(slices(block +1).slicedata,1);
    rows1 = 1:nrowspace:height1;
    rows2 = 1:nrowspace:height2;
    dat1 = slices(block).slicedata(rows1,width1 - searchwidth + 1:width1);
    dat2 = slices(block +1).slicedata(rows2,1:searchwidth);
    diff = dat1 - dat2;
    [ width height ] = size(diff);
    graddiffx = diff;
  %  [graddiffx graddiffy] = gradient(diff);
    graddiff2 = graddiffx .* graddiffx;
    errval(1,block) = sum(sum(graddiff2)) / width / height;
%    graddiff2 = graddiffy .* graddiffy;
%    errval(blocki) = ( errval(block) + sum(sum(graddiff2)) / width / height ) * 0.5;
%    errval(block) = sum(sum(graddiff2)) / width / height ;
  end;

end