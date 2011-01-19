function [ overlap varargout ] =find_overlap(image1,image2,varargin)
% overlap = find_overlap(image1,image1[,numberofrows[,figure]])
% 
%   image1 .... first image to use in overlap search
%   image2 .... second image to u se in overlap search;
%               It has to be of the same size and dimension as
%               image1;
%   numberofrows number of rows to use for search 
%               (Default: 128)
%   figure .... number of figure to plot the computed values on;
%               If 0 than nothing is displayed
%               (Default: 0 )
%   displacement ... plot displacement instead of overlap
%   limits .... limtits to use for line selection algorithm
%               limits(1) ... low  limit std/range
%               limits(2) ... low  limit std/mean
%               limits(3) ... low  limit mean/range
%               limits(4) ... high limit mean/range
%   filterwidth window width of bidirectional moving average filter
%
%
%  overlap .... the overlap between image1 and image2;
%               A positive value means remove the first overlap columns
%               from image2 and append on the right side to image 1;
%               A negative value means remove the first abs(overlap) columns
%               from image1 and append on the right side to image 2;
%
%  displacement the displacement of the second image relative to
%               the first
%  squareddiff  avererage squared fifference values for all displacements
%
%  displacements list of all diplacements for which the squared diff value
%                was computed
%  gradient     gradient of squareddiff
%
%  dispindex    displacement in pixels relative to the leftmost displacement entry
%               

  overlap = NaN;
  if nargout > 1
    varargout{1} = NaN;%{ ( notchidx - detsize ) .* -1 };
  end
  if nargout > 2 
    varargout{2} = [];
  end
  if nargout > 3 
    varargout{3} = [];
  end
  if nargout > 4 
    varargout{4} = [];
  end
  if nargout > 5 
    varargout{5} = NaN;
  end
  nrows = 128;
  showfigs = 0;
  if nargin > 2 
    nrows = varargin{1};
  end
  if ( nargin > 3 ) && ( varargin{2} > 0 )
    showfigs = varargin{2};
  end
  displacementplot = 0;
  if ( nargin > 4 ) && ( varargin{3} ~= 0 )
    displacementplot = 1;
  end
  nrowspace = floor( size(image1,1) / nrows );
  if nrowspace < 1 
    nrowspace = 1;
  end
  startrows = floor( nrowspace / 2 );
  if startrows < 1 
    startrows = 1;
  end
  errvals = [];
  errvalsrev = [];
  steps = [];
  detsize = size(image1,2);
  minvals = [ min(min(image1)),min(min(image2))];
  maxvals = [ max(max(image1)),max(max(image2))];
  minvals(3) = min(minvals);
  maxvals(3) = max(maxvals);
  range = maxvals - minvals;
  image1 = ( image1 - minvals(1) ) ./ range(1);
  image2 = ( image2 - minvals(2) ) ./ range(2);
  totrangesqr = range(3) ^2;
  if size(image1,1) ~= size(image2,1) 
    overlap = NaN;
    if nargout > 1
      varargout{1} = Nan;%{ ( notchidx - detsize ) .* -1 };
    end
    return;
  end
  if    ( nargin > 5 ) ...
     && isnumeric(varargin{4}) ...
     && (    (    (size(varargin{4},1) == 4) ...
               && (size(varargin{4},2) == 1 ) ) ...
          || (    (size(varargin{4},2) == 4 ) ...
               && (size(varargin{4},1) == 1 ) ) )
    rows = selectrows(image1,image2,1:nrowspace:size(image1,1),varargin{4});
  else
    rows = selectrows(image1,image2,1:nrowspace:size(image1,1));
  end
  for searchwidth = -detsize:detsize 
    %errvals(searchwidth,:) = correlate(image1,image2,nrows,nrowspace,searchwidth) ;%./ totrangesqr;
    errvals(searchwidth + detsize + 1,:) = correlate(image1,image2,rows,searchwidth); %./ totrangesqr;
    %errvalsrev(searchwidth,:) = correlate(image2,image1,nrows,nrowspace,searchwidth);% ./ totrangesqr;
%    errvalsrev(searchwidth,:) = correlate(image2,image1,rows,searchwidth);% ./ totrangesqr;
%    steps(searchwidth) = searchwidth;
  end
  if isnan( errvals(1) )
    errvals(1) = errvals(2);
  end
  if isnan( errvals(length(errvals)) )
    errvals(length(errvals)) = errvals(length(errvals) -1);
  end
  windowwidth = 5;
  if    ( nargin > 6 ) ...
     && isnumeric(varargin{5}) ...
     && varargin{5} > 2
    windowwidth = varargin{5}
  end
  filta=ones(1,windowwidth)./windowwidth;
  filtb=1;
  rejectlimit = mean(errvals(find(~isnan(errvals))));
  origerrvals = errvals;
  errvals = filtfilt(filta,filtb,errvals);
  errvalsgrad = gradient(errvals);
  origerrvalsgrad = errvalsgrad;
  notchidx = 1;
  notchval = -inf;
  
  for fndnotch = 2:length(errvalsgrad)-1
    candval = errvalsgrad(fndnotch + 1) - errvalsgrad(fndnotch - 1) ;
    if ( errvalsgrad(fndnotch + 1) > 0 ) && ( errvalsgrad(fndnotch - 1) < 0 ) 
      if    isnan(errvals(fndnotch)) ...
         || ( errvals(fndnotch) > rejectlimit )
        continue;
      end
      edges = [ fndnotch fndnotch];
      edgevals = [ errvals(fndnotch) errvals(fndnotch) ];
      for dsearch = fndnotch - 2:-1:1
        if errvalsgrad(dsearch) > 0 
          edgevals(1) = errvals(dsearch + 1);
          edges(1) = dsearch + 1;
          break;
        end
        if dsearch == 1
          edgevals(1) = errvals(1);
          edges(1) = 1;
        end
      end
      for dsearch = fndnotch + 2:length(errvalsgrad)
        if errvalsgrad(dsearch) < 0 
          edgevals(2) = errvals(dsearch - 1);
          edges(2) = dsearch - 1;
          break;
        end
        if dsearch == length(errvalsgrad)
          edgevals(2) = errvals(length(errvalsgrad));
          edges = length(errvalsgrad);
        end
      end
      height = [ edgevals(1) - errvals(fndnotch) , edgevals(2) - errvals(fndnotch) ];
      if    ( height(1) < notchval ) ...
         || ( height(2) < notchval )
        continue;
      end
      if height(1) > height(2)
        notchval = height(2);
        notchidx = fndnotch - 1;
      else
        notchval = height(1);
        notchidx = fndnotch - 1;
      end
    end
  end
  displacement = notchidx - detsize ;
  if displacement < 0
    overlap = -detsize + abs(displacement);
  else
    overlap = detsize - displacement;
  end
  %if notchidx > detsize 
  %  overlap = notchidx - 2 * detsize ;
  %else
  %  overlap = notchidx;
  %end
  if nargout > 1 
    varargout{1} = displace;
  end
  if nargout > 2 
    varargout{2} = errvals;
  end
  steps = [ -detsize : detsize ];
  if nargout > 3 
    varargout{3} = steps;
  end
  if nargout > 4 
    varargout{4} = gradient(varargout{2});
  end
  if nargout > 5 
    varargout{5} = notchidx;
  end
  if showfigs
    legendtext = [ '\xi_{0,180}=' num2str( displacement ) ];
    totalmax = [ max(errvals) * 1.02 ];
    totalmin = [ min(errvals) * 0.98 ];
    totalmax(2) = max(errvalsgrad) * 1.02;
    totalmin(2) = min(errvalsgrad) * 1.02;
    errvalstorr = gradient(errvalsgrad);
    totalmax(3) = max(errvalstorr) * 1.02;
    totalmin(3) = min(errvalstorr) * 1.02;
    figure(showfigs);
    subplot(3,1,1);
    plot(steps,origerrvals,'linestyle','-');
    hold on;
    plot(steps,errvals,'m-');
    %plot(steps,filtfilt(filta,filtb,errvals),'m-');
    plot([ displacement displacement ] , [ totalmin(1) totalmax(1) ],'--r');
    legend( '\delta^2(\xi)','avg(\delta^2(\xi))', legendtext);
    hold off;
    xlabel('Displacement: \xi');
    set(gca,'xlim',[min(steps) - 10, max(steps) + 10]);
    %ylabel('[1]');
    %title(['\delta^2(\xi) ' titletext]);
    subplot(3,1,2);
    plot(steps,origerrvalsgrad,'linestyle','-');
    hold on;
size(errvalsgrad);
find(~isnan(errvalsgrad));
    xxx = [ filtfilt(filta,filtb,errvalsgrad(2:length(errvalsgrad)-1))];
size(xxx);
max(xxx);
mean(xxx);
median(xxx);
min(xxx);
    plot(steps,filtfilt(filta,filtb,errvalsgrad'),'m-');
    plot([ displacement displacement ] , [ totalmin(2) totalmax(2) ],'--r');
    hold off;
    xlabel('Displacement: \xi');
    %ylabel('\nabla\delta^2(\xi)');
    legend( '\nabla\delta^2(\xi)','avg(\nabla\delta^2(\xi))', legendtext);
    set(gca,'xlim',[min(steps) - 1, max(steps) + 1]);
    hold off;
    subplot(3,1,3);
    plot(steps,errvalstorr,'linestyle','-');
    hold on;
    plot(steps,filtfilt(filta,filtb,errvalstorr),'m-');
    plot([ displacement displacement ] , [ totalmin(2) totalmax(2) ],'--r');
    hold off;
    xlabel('Displacement: \xi');
    %ylabel('\nabla\delta^2(\xi)');
    legend( '\nabla\nabla\delta^2(\xi)','avg(\nabla\nabla\delta^2(\xi))', legendtext);
    set(gca,'xlim',[min(steps) - 1, max(steps) + 1]);
    hold off;
    %title(['\nabla\delta^2(\xi) ' titletext]);
  end
  clear nrows showfigs nrowspace errvals errvalsrev steps searchwidth detsize totalmax totalmin errvalsgrad notchidx notchval fndnotch candval titletext edgevals edges height;
end

%function errval = correlate(image1,image2,nrows,nrowspace,searchwidth)
function errval = correlate(image1,image2,rows,searchwidth,varargin)
  maxvals = ones(1,3);
  minvals = zeros(1,3);
  range = maxvals - minvals;
  if nargin > 4
    if nargin > 5
      minvals = varargin{1};
      maxvals = varargin{2};
    else
      range = varargin{1};
    end
  end
  width1 = size(image1,2);
  width2 = size(image2,2);
  height1 = size(image1,1);
  height2 = size(image2,1);
  rows1 = rows;%1:nrowspace:height1;
  rows2 = rows;%1:nrowspace:height2;
  if    ( abs(searchwidth) == width1 ) ...
     || ( abs(searchwidth) == width2 ) ...
    errval = NaN;
    clear width1 width2 height1 height2 rows1 rows2 width height;
    return;
  end
  if ( searchwidth < 0 ) 
    dat1 = image1(rows1,1:width1 - abs(searchwidth));% ./ range(3);
    dat2 = ( image2(rows2,abs(searchwidth) + 1:width2) );% ./ range(3);
  else 
    dat1 = image1(rows1,searchwidth + 1:width1);% ./ range(3);
    dat2 = image2(rows2,1:width2 - searchwidth);% ./ range(3);
  end
  diff = dat1 - dat2;
  [ width height ] = size(diff);
  errval = sum( sum( diff .* diff ) ) / width / height ;
  clear width1 width2 height1 height2 rows1 rows2 dat1 dat2 diff width height;
end

function rows = selectrows(image1,image2,candidates,varargin)

  limits = [ 0.01 0.1 0.03 0.9 ];
  if nargin > 3 
    limits = varargin{1};
  end
  rows = [];
  timage1 = image1;
  timage2 = image2;
  %minvals = [ min(min(timage1(:))) , min(min(timage2(:))) ];
  %maxvals = [ max(max(timage1(:))) max(max(timage2(:))) ];
  %minvals(3) = min(minvals)
  %maxvals(3) = max(maxvals)
  %range = [ maxvals(1) - minvals(1) , maxvals(2) - minvals(2) ]
  rowmeans(:,1) = mean(timage1,2);
  rowmeans(:,2) = mean(timage2,2);
  rowstd(:,1) = std(timage1,0,2);
  rowstd(:,2) = std(timage2,0,2);
  %rowmeans(:,1) = ( mean(timage1,2) - minvals(1) ) ./ range(1);
  %rowmeans(:,2) = ( mean(timage2,2) - minvals(2) ) ./ range(2) 
  %rowstd(:,1) = std(timage1,0,2) ./ range(1);
  %rowstd(:,2) = std(timage2,0,2) ./ range(2)
  rows = [1:size(image1,1)];
  [remrows remcols ] = find(rowstd < limits(1) );
  rows(remrows) = NaN;
  [remrows remcols ] = find(rowstd < rowmeans .* limits(2) );
  rows(remrows) = NaN;
  [remrows remcols ] = find( rowmeans < limits(3) );
  rows(remrows) = NaN;
  [remrows remcols ] = find( rowmeans > limits(4) );
  rows(remrows) = NaN;
  rows = rows(candidates);
  rows = rows(find(~isnan(rows)));
  clear timage1 timage2;
end
