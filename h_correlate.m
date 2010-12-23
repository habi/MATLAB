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
%            [graddiffx graddiffy] = gradient(diff);
            graddiff2 = graddiffx .* graddiffx;
            errval(1,block) = sum(sum(graddiff2)) / width / height;
%            graddiff2 = graddiffy .* graddiffy;
%            errval(blocki) = ( errval(block) + sum(sum(graddiff2)) / width / height ) * 0.5;
%            errval(block) = sum(sum(graddiff2)) / width / height ;
        end
end