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
%
%  overlap .... the overlap between image1 and image2;
%               A positive value means remove the first overlap columns
%               from image2 and append on the right side to image 1;
%               A negative value means remove the first abs(overlap) columns
%               from image1 and append on the right side to image 2;

  nrows = 128;
  showfigs = 0;
  if nargin > 2 
    nrows = varargin{1};
  end
  if ( nargin > 3 ) && varargin{2}
    showfigs = varargin{2};
  end
  displacementplot = 0;
  if ( nargin > 4 ) && varargin{3}
    displacementplot = 1;
  end
  nrowspace = floor( size(image1,1) / nrows );
  if nrowspace < 1 
    nrowspace = 1;
  end
  errvals = [];
  errvalsrev = [];
  steps = [];
  detsize = size(image1,2);
  for searchwidth = 1:detsize 
    errvals(searchwidth,:) = correlate(image1,image2,nrows,nrowspace,searchwidth);
    errvalsrev(searchwidth,:) = correlate(image2,image1,nrows,nrowspace,searchwidth);
    steps(searchwidth) = searchwidth;
  end
  errvals = [ errvals ; errvalsrev(detsize - 1:-1:1,:) ];
  steps = [steps, steps(1:detsize - 1) + detsize ];
  errvalsgrad = gradient(errvals);
  notchidx = 1;
  notchval = -1000;
  for fndnotch = 2:length(errvalsgrad)-1
    candval = errvalsgrad(fndnotch + 1) - errvalsgrad(fndnotch - 1) ;
    if ( errvalsgrad(fndnotch + 1) > 0 ) && ( errvalsgrad(fndnotch - 1) < 0 ) 
      edges = [ fndnotch fndnotch];
      edgevals = [ errvals(fndnotch) errvals(fndnotch) ];
      for dsearch = fndnotch - 1:-1:1
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
      for dsearch = fndnotch + 1:length(errvalsgrad)
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
      if height(1) > height(2)
        if height(2) > notchval
          notchval = height(2);
          notchidx = fndnotch;
        end
      else
        if height(1) > notchval
          notchval = height(1);
          notchidx = fndnotch;
        end
      end
    end
  end
  if notchidx > detsize 
    overlap = notchidx - 2 * detsize ;
  else
    overlap = notchidx;
  end
  if nargout > 1 
    varargout(1) = { ( notchidx - detsize ) .* -1 };
  end
  if showfigs
    legendtext = [ 'Overlap=' num2str(overlap) ];
    if displacementplot 
      steps = ( steps - detsize ) ;
      notchidx = ( notchidx - detsize ) .* -1;
      legendtext = [ '\xi_{0,180}=' num2str( notchidx ) ];
      errvals = [errvals(length(errvals):-1:1)];
      errvalsgrad = gradient(errvals);
    end 
    totalmax = [ max(errvals) * 1.02 ];
    totalmin = [ min(errvals) * 0.98 ];
    totalmax(2) = max(errvalsgrad) * 1.02;
    totalmin(2) = min(errvalsgrad) * 1.02;
    figure(showfigs);
    subplot(2,1,1);
    plot(steps,errvals);
    hold on;
    plot([ notchidx notchidx ] , [ totalmin(1) totalmax(1) ],'--r');
    legend( '\delta^2(\xi)', legendtext);
    hold off;
    xlabel('Displacement: \xi');
    set(gca,'xlim',[min(steps) - 10, max(steps) + 10]);
    %ylabel('[1]');
    %title(['\delta^2(\xi) ' titletext]);
    subplot(2,1,2);
    plot(steps,errvalsgrad);
    hold on;
    plot([ notchidx notchidx ] , [ totalmin(2) totalmax(2) ],'--r');
    hold off;
    xlabel('Displacement: \xi');
    %ylabel('\nabla\delta^2(\xi)');
    legend( '\nabla\delta^2(\xi)', legendtext);
    set(gca,'xlim',[min(steps) - 1, max(steps) + 1]);
    hold off;
    %title(['\nabla\delta^2(\xi) ' titletext]);
  end
  clear nrows showfigs nrowspace errvals errvalsrev steps searchwidth detsize totalmax totalmin errvalsgrad notchidx notchval fndnotch candval titletext edgevals edges height;
end

function errval = correlate(image1,image2,nrows,nrowspace,searchwidth)
  width1 = size(image1,2);
  width2 = size(image2,2);
  height1 = size(image1,1);
  height2 = size(image2,1);
  rows1 = 1:nrowspace:height1;
  rows2 = 1:nrowspace:height2;
  dat1 = image1(rows1,width1 - searchwidth + 1:width1);
  dat2 = image2(rows2,1:searchwidth);
  diff = dat1 - dat2;
  [ width height ] = size(diff);
  errval = sum( sum( diff .* diff ) ) / width / height;
  clear width1 width2 height1 height2 rows1 rows2 dat1 dat2 diff width height;
end
