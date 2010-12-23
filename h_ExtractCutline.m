function cutline = h_ExtractCutline(image1,image2,ImageSize,DetectorSize)
    overlap = 0.15;
    cutline = floor(size(image1,2)*overlap);
%     step = 1;
%     for searchwidth = StepRange(1):StepWidth:StepRange(2) - 1
%         errvals(step,:) = h_correlate(slices,blocks,NumRows,NumRowspace,searchwidth + 1,testimg);
%         steps(step) = searchwidth + 1;
%         step = step + 1;
%     end
    
end




function merge_images_function_chris(templatesize,DetectorSize,Overlap,NumRows,StepWidth,StepRange)
  testslice = phantom('Modified Shepp-Logan',templatesize);
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
  slicesize = DetectorSize - Overlap
  fullwidth = size(testimg,2);
  blocks = ceil( ( fullwidth - Overlap ) / slicesize )
  slices = [struct('slicedata',[] )];
  slicestart = 1;
  stitched = [];
  if blocks * slicesize + Overlap  - fullwidth >= DetectorSize
    reduce = floor(( blocks * slicesize + Overlap  - fullwidth ) / DetectorSize);
    blocks = blocks - reduce ;
  end
  if blocks * slicesize + Overlap > fullwidth
    enlarge = blocks * slicesize + Overlap - fullwidth;
    testimg = [testimg zeros(size(testimg,1),enlarge)];
  end
  size(testimg,2);
  %for block = blocks:-1:1
  for block = 1:blocks
    slices(block) = struct('slicedata',testimg(:,slicestart:slicestart + DetectorSize - 1));
    stitched = [stitched slices(block).slicedata];
    slicestart = slicestart + slicesize;
  end
  figure(2);
  imshow(stitched,[]);
  NumRowspace = floor( size(testimg,1) / NumRows ); 
  errvals = [];
  step = 1;
  steps = [];
  for searchwidth = StepRange(1):StepWidth:StepRange(2) - 1
    errvals(step,:) = correlate(slices,blocks,NumRows,NumRowspace,searchwidth + 1,testimg);
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
  sidestep = floor(5 / StepWidth)
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
    merged = [ merged slices(block).slicedata(:,minidx(block - 1) + 1:DetectorSize) ];
  end
  figure(4);
  imshow(merged,[]);
end

function errval = correlate(slices,blocks,NumRows,NumRowspace,searchwidth,testimg)
  corrs = struct('correlation',[],'cutat',0);
  val = [];
  pos = [];
  for block = 1:blocks-1
    width1 = size(slices(block).slicedata,2);
    width2 = size(slices(block +1).slicedata,2);
    height1 = size(slices(block).slicedata,1);
    height2 = size(slices(block +1).slicedata,1);
    rows1 = 1:NumRowspace:height1;
    rows2 = 1:NumRowspace:height2;
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
