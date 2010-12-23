function minidx=merge_test_new(inputimages,nrows,stepwidth,maxsearchrange)

  nrowspace = floor( size(inputimages(1).slicedata,1) / nrows ); % abstand der rows
  maxsearchwidth = floor(size(inputimages(1).slicedata,2) * maxsearchrange);
  errvals = [];
  step = 1;
  steps = [];
  for searchwidth = 1:stepwidth:maxsearchwidth
    errvals(step,:) = correlate(inputimages,length(inputimages),nrows,nrowspace,searchwidth);
    steps(step) = searchwidth;
    step = step + 1;
  end
  minval = [];
  minidx = [];
  figure
  [minval minidx] = min(errvals)
  plot(steps,errvals);
  subplot(1,1,1);
  notches = [];
  sidestep = floor(5 / stepwidth);
  if sidestep < 1 
    sidestep = 1;
  end
  blocks = length(inputimages)
%   for block = 1:blocks - 1;
%     notches(:,block) = errvals(minidx(block)-sidestep:minidx(block)+sidestep,block);
%   end
%   notches;
  minidx = steps(minidx);
  
end

function errval = correlate(slices,blocks,nrows,nrowspace,searchwidth)
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
