function displayDumpImage(sourceImage, varargin )
    
    newFigure = 0;
    if nargin > 1
        newFigure = varargin{1};
    end
    display = 0;
    if nargin > 2
      display = varargin{2} ;
    end

    % read the image data
    if isnumeric(sourceImage) | islogical(sourceImage)
        img = sourceImage;
        [height, width] = size(sourceImage);
        sourceImage = 'unknown';
    else
        [img, width, height] = readDumpImage(sourceImage,inf,'float32');
    end
    if nargin > 4
      if varargin{4} < 0
        nimg(:,:) = img(:,width:-1:1);
        img=nimg;
        clear nimg;
      end
    end
    if newFigure
        % display the image in a new figure
      fighnd = figure;
    else
      fighnd = gcf;
    end
    colormap('gray');
    datamin = min(min(img));
    datamax = max(max(img));
    autoscale = 1;
    if    ( nargin > 3 ) ...
       && ( length(varargin{3}) == 2 )
      valuerange = varargin{3};
      minval = valuerange(1);
      maxval = valuerange(2);
      autoscale = 0
    else
      maxval = datamax;
      minval = datamin;
    end
    factor=1/( datamax-datamin );
    shift=datamin;
    if ~display 
      if autoscale == 1
         
        edthnd = [ findobj(fighnd,'type','uicontrol','style','edit','tag','MIN_EDT') ...
                   findobj(fighnd,'type','uicontrol','style','edit','tag','MAX_EDT') ];
        if length( edthnd == 2 )
          value = sscanf(get(edthnd(1),'string'),'%f');;
          minval = value;
          value = sscanf(get(edthnd(2),'string'),'%f');;
          maxval = value;;
        end
      end
      imghnd=imagesc(img,[minval maxval]);
      set(imghnd,'tag','IMAGE_DSP');
      axis equal;
      titlehnd = title(sourceImage);
      set(titlehnd,'tag','TITLE_TXT','HandleVisibility','on','STRING',sourceImage);
      cbarhnd=colorbar('east');
      set(cbarhnd,'tag','COLOR_DSP');
      imgaxhnd=get(imghnd,'parent');
      fighnd=get(imgaxhnd,'parent');
      sldpos=get(cbarhnd,'position');
      sldpos(1) = sldpos(1) + 2 * sldpos(3);
      sldpos(2) = sldpos(2) - 0.015;
      sldpos(3) = 0.025;
      sldpos(4) = sldpos(4) + 0.03;
      sldhnd = [ findobj(fighnd,'type','uicontrol','style','slider','tag','MIN_SLD') ...
                 findobj(fighnd,'type','uicontrol','style','slider','tag','MAX_SLD') ...
                 findobj(fighnd,'type','uicontrol','style','slider','tag','IMG_SLD') ];
      if length(sldhnd) < 2 
        if length(sldhnd) < 1
          sldhnd(1) = uicontrol(fighnd);
        end  
        sldhnd(2) = uicontrol(fighnd);
      end
      set(sldhnd(1),'style','slider','units','normalized','position',sldpos);
      set(sldhnd(1),'min',0,'max',1,'sliderstep',[0.0005 0.05],'tag','MIN_SLD');
      set(sldhnd(1),'value',( minval -shift ) * factor,'callback',@callback,'max',1,'min',0);
      sldpos(1) = sldpos(1) + 0.03;
      set(sldhnd(2),'style','slider','units','normalized','position',sldpos);
      set(sldhnd(2),'min',0,'max',1,'sliderstep',[0.0005 0.05],'tag','MAX_SLD');
      set(sldhnd(2),'value',( maxval - shift ) * factor ,'callback',@callback,'min',0,'max',1);
      edtpos = sldpos;
      edtpos(1) = edtpos(1) - 0.075; 

      edtpos(2) = edtpos(2) - 0.075;
      edtpos(3) = 0.1;
      edtpos(4) = 0.05;
      edthnd = [ findobj(fighnd,'type','uicontrol','style','edit','tag','MIN_EDT') ...
                 findobj(fighnd,'type','uicontrol','style','edit','tag','MAX_EDT') ];
      %set(gca,'color',[0,0,0],'clim',[minval maxval]);
      set(gca,'color',[0,0,0]);
      if length(edthnd) < 2 
        if length(edthnd) < 1
          edthnd(1) = uicontrol(fighnd);
        end  
        edthnd(2) = uicontrol(fighnd);
      end
      set(edthnd(1),'style','edit','units','normalized','position',edtpos,'min',min(datamin,minval),'max',max(datamax,maxval));
      set(edthnd(1),'tag','MIN_EDT','string',sprintf('%.4f',minval),'callback',@callback);
      edtpos(2) = sldpos(2) + sldpos(4) + 0.035;
      set(edthnd(2),'style','edit','units','normalized','position',edtpos,'min',datamin,'max',datamax);
      set(edthnd(2),'tag','MAX_EDT','string',sprintf('%.4f',maxval),'callback',@callback);
      if length(sldhnd) < 3
        sldhnd(3) = uicontrol(fighnd);
      end
      pos = get(imgaxhnd,'position');
      set(sldhnd(3),'style','slider','units','normalized','tag','IMG_SLD');
      position = get(sldhnd(3),'position');
      position(1) = pos(1) -0.1;
      position(2) = pos(2);;
      position(3) = 0.03;
      position(4) = pos(4);
      [m dum1 dum2 dum3 sample] = regexp({get(titlehnd,'string') pwd},'(\/|^)([^\s\/]+)\/(rec(_DMP)?|sin|prj2cpr|$;)');
      recdir = '';
      if isempty(m{1})
        sample = sample{2}{1};
      else
        sample = sample{1}{1};
      end
      if isempty(sample{3})
         recdir = ['/' dir([pwd '/rec*']) ]
      else
         recdir = sample{3}
      end;
      count=length(dir([pwd recdir '/' sample{2} '*.DMP']));
      set(sldhnd(3),'position',position,'min',0,'max',1,'sliderstep',[ 1 / ( count - 1 ), 10 / ( count - 1 ) ]);
      [m dum1 dum2 dum3 digits] = regexp(get(titlehnd,'string'),[sample{2} '(\d+).*\.DMP']);
      value = sscanf(digits{1}{1},'%f');
      value = 1 - ( value - 1 ) / ( count - 1 );
      set(sldhnd(3),'value',value,'callback',@callback);
      set(fighnd,'userdata',{length(digits{1}{1}) count pwd} );
    else
      range = maxval - minval;
      title(sourceImage);
      cutoffon = range * 0.1761;
      noiselevel =  minval + cutoffon;
      level = ones(2 ,2 ) .* range .* 0.5;
      toplevel = maxval - cutoffon;
      steps = range / 500;
      if display < 2
        mesh(img);
        set(gca,'zlim',[minval maxval]);
        return;
      end
      [ rows cols ] = size(img);
      levelfaces=[];
      subplot(2,2,4);
      set(gca,'units','normalized','visible','off')
      text(0,0.75,0.85,'File:','horizontalalignment','left','verticalalignment','baseline','fontsize',12);
      text(0,0.675,0.85,sourceImage,'horizontalalignment','left','verticalalignment','baseline','fontsize',12);
      text(0,0.5,0.85,'Press j or k to move level up and down','horizontalalignment','left','verticalalignment','baseline','fontsize',12);
      text(0,0.4,0.85,'Press n or t to mark level as nois or signal','horizontalalignment','left','verticalalignment','baseline','fontsize',12);
      text(0,0.3,0.85,'Upper case makes 20 steps, lower case 1','horizontalalignment','left','verticalalignment','baseline','fontsize',12);
      text(0,0.15,0.65,'Press q to quit','horizontalalignment','left','verticalalignment','baseline','fontsize',12);
      set(gca,'position',[ 0.7 0.05 0.25 0.25 ],'view',[ 0 0 ],'cameraposition',[ 10000000 0 0 ],'cameraupvector',[0 1 0]);
      leveltexts = text(0,0.05,0.85,[  'Signal: ' num2str(toplevel,'%7.4f') ...
                                      ' Noise: '  num2str(noiselevel,'%7.4f') ...
                                      ' SNR: '    num2str(toplevel/noiselevel,'%5.2f') ], ...
                        'horizontalalignment','left','verticalalignment','baseline','fontsize',11);
      subplot(2,2,2);
      mesh(img);
      set(gca,'position',[ 0.7 0.3 0.25 0.65 ],'view',[ 0 0 ],'cameraposition',[ 10000000 0 0 ],'cameraupvector',[0 1 0]);
      levelfaces(1,2)  = surface( [ 1 cols ; 1 cols ] , [ 1 1 ; rows rows ],level );
      set(gca,'zlim',[ floor(minval * 500) ceil(maxval *500 ) ] ./ 500, 'ylim',[ 0 rows ],'drawmode','fast','color','none');
      set(gca,'box','on');
      rotate3d(gca,'off')
      subplot(2,2,3)
      mesh(img);
      set(gca,'position',[ 0.05 0.05 0.65 0.25 ],'view',[ 0 0 ],'cameraposition',[ 0 -1000000 0 ],'cameraupvector',[0 0 1]);
      set(gca,'zlim',[ floor(minval * 500) ceil(maxval *500 ) ] ./ 500, 'xlim',[ 0 cols ],'drawmode','fast','color','none');
      set(gca,'box','on');
      levelfaces(1,3)  = surface( [ 1 cols ; 1 cols ] , [ 1 1 ; rows rows ],level );
      rotate3d(gca,'off')
      subplot(2,2,1)
      mesh(img);
      set(gcf,'units','normalized');
      set(gca,'position',[ 0.05 0.30 0.65 0.65 ],'view',[0 0],'cameraposition',[ 0 0 10 ],'cameraupvector',[0 1 0])
      set(gca,'xlim',[0 cols],'ylim',[0 rows],'visible','off','drawmode','fast');
      set(gca,'color',[0,0,0],'box','on');
      levelfaces(1)  = surface( [ 1 cols ; 1 cols ] , [ 1 1 ; rows rows ],level );
      set(levelfaces(1,1),'facecolor',[0.05 0.05 0.05]);
      rotate3d(gca,'off');
      disp 'Press j or k to move level plane up and down';
      disp 'Press n or t to define actual level as noise- or toplevel';
      disp 'Press q to quit';
      disp 'Uppercdase has speed 10 instead of 1';
      while 1
        if ~waitforbuttonpress
          continue;
        end
        key = get(gcf,'currentcharacter');
        switch key
          case {'q' 'Q'}
            break;
          case 'j'
            level = increaseLevel(levelfaces,steps,minval,maxval);
          case 'J'
            level = increaseLevel(levelfaces,steps * 20,minval,maxval);
          case 'k'
            level = increaseLevel(levelfaces,-steps,minval,maxval);
          case 'K'
            level = increaseLevel(levelfaces,-steps * 20,minval,maxval);
          case {'n' 'N' }
            noiselevel = level(1,1);
            set(leveltexts,'string',[  'Signal: ' num2str(toplevel,'%7.4f') ...
                                      ' Noise: '  num2str(noiselevel,'%7.4f') ...
                                      ' SNR: '    num2str(toplevel/noiselevel,'%5.2f') ]);
          case { 't' 'T' }
            toplevel = level(1,1);
            set(leveltexts,'string',[  'Signal: ' num2str(toplevel,'%7.4f') ...
                                      ' Noise: '  num2str(noiselevel,'%7.4f') ...
                                      ' SNR: '    num2str(toplevel/noiselevel,'%5.2f') ]);
          otherwise
        end
      end
    end
    clear gcf
    

function [level] = increaseLevel(hnd,by,minval,maxval)
  levelvalues = get(hnd(1,1),'zdata');
  newlevelvalues = levelvalues + by;
  if    ~isempty( find( newlevelvalues < minval ) )...
     || ~isempty( find( newlevelvalues > maxval ) )
    level = levelvalues;
    return;
  end
  for i=1:length(hnd)
    set(hnd(i),'zdata',newlevelvalues);
  end
  level = newlevelvalues;
  return
%    [r c] = size(img);
%    img(r,:)
%    min(img(r,:))
%    max(img(r,:))
%    a = ind2sub(c,find([img(r,:)] < 0.0 ));
%    img(r,a) = img(r,a) - min(img(r,:));
%    figure
%    plot(img(r,:))
    
    %img(r,a) = img(r,a) - min(img(r,:))
  
    

function callback(hnd,data)
  fig = get(hnd,'parent');
  img = findobj(fig,'tag','IMAGE_DSP');
  scb = findobj(fig,'tag','COLOR_DSP');
  axs = get(img,'parent');
  sbd = findobj(scb,'type','image');
  switch get(hnd,'tag');
    case 'MIN_SLD' 
      mxsld = findobj(fig,'tag','MAX_SLD');
      mxedt = findobj(fig,'tag','MAX_EDT');
      mnedt = findobj(fig,'tag','MIN_EDT');
      value = get(hnd,'value');
      datmin = get(mxedt,'min');
      datmax = get(mxedt,'max');
      factor = 1/(datmax - datmin);
      shift = datmin;
      value = value / factor + shift;
      limit = get(mxsld,'value') / factor + shift;
      if ( value > limit ) 
        value = limit - 0.0001;
        set(hnd,'value', ( value - shift ) * factor);
      end
      set(mnedt,'string',sprintf('%.4f',value));
      limits = get(axs,'clim');
      limits(1) = value;
      set(axs,'clim',limits);
      set(sbd,'ydata',limits);
      set(scb,'ylim',limits);
    case 'MAX_SLD'
      mnsld = findobj(fig,'tag','MIN_SLD') ;
      mxedt = findobj(fig,'tag','MAX_EDT') ;
      mnedt = findobj(fig,'tag','MIN_EDT') ;
      value = get(hnd,'value');
      datmin = get(mxedt,'min');
      datmax = get(mxedt,'max');
      factor = 1/(datmax - datmin);
      shift = datmin;
      value = value / factor + shift;
      limit = get(mnsld,'value') / factor + shift;
      if ( value < limit )
        value = limit + 0.0001;
        set(hnd,'value', ( value - shift ) * factor);
      end
      set(mxedt,'string',sprintf('%.4f',value));
      limits = get(axs,'clim')
      limits(2) = value;
      set(axs,'clim',limits);
      set(sbd,'ydata',limits);
      set(scb,'ylim',limits);
    case 'MIN_EDT'
      mnsld = findobj(fig,'tag','MIN_SLD') ;
      mxsld = findobj(fig,'tag','MAX_SLD');
      mxedt = findobj(fig,'tag','MAX_EDT') ;
      mnedt = findobj(fig,'tag','MIN_EDT') ;
      value = sscanf(get(hnd,'string'),'%f');
      datmin = get(mxedt,'min');
      datmax = get(mxedt,'max');
      factor = 1/(datmax - datmin);
      shift = datmin;
      limit = get(mxsld,'value') / factor + shift;
      if ( value > limit ) 
        value = limit - 0.0001;
        set(hnd,'string', sprintf('%.4f',value ));
      elseif value < datmin
        value = datmin ;
        set(hnd,'string', sprintf('%.4f',value ));
      end
      limits = get(axs,'clim');
      limits(1) = value;
      set(axs,'clim',limits);
      value = (value - shift ) * factor;
      set(mnsld,'value',value);
      set(sbd,'ydata',limits);
      set(scb,'ylim',limits);
    case 'MAX_EDT'
      mnsld = findobj(fig,'tag','MIN_SLD') ;
      mxsld = findobj(fig,'tag','MAX_SLD');
      mxedt = findobj(fig,'tag','MAX_EDT') ;
      mnedt = findobj(fig,'tag','MIN_EDT') ;
      value = sscanf(get(hnd,'string'),'%f');
      datmin = get(mxedt,'min');
      datmax = get(mxedt,'max');
      factor = 1/(datmax - datmin);
      shift = datmin;
      limit = get(mnsld,'value') / factor + shift;
      if ( value < limit )
        value = limit + 0.0001;
        set(hnd,'string', sprintf('%.4f',value));
      elseif value > datmax;
        value = datmax;
        set(hnd,'string', sprintf('%.4f',value));
      end
      limits = get(axs,'clim');
      limits(2) = value;
      set(axs,'clim',limits);
      value = (value - shift ) * factor;
      set(mxsld,'value',value);
      set(sbd,'ydata',limits);
      set(scb,'ylim',limits);
    case 'IMG_SLD'
      digitcount = get(fig,'userdata');
      tithnd = findobj(fig,'tag','TITLE_TXT');
      text = get(tithnd,'string');
      value = round( ( 1 - get(hnd,'value') ) * ( digitcount{2} - 1 ) ) + 1;
      pat = sprintf('\\d{%i,%i}(\\D+\\.DMP)$',digitcount{1},digitcount{1});
      replace = sprintf([ sprintf('%%0.%ii',digitcount{1}) '$1' ],value);
      thisdir = pwd;
      cd(digitcount{3});
      actfig = gcf;
      figure(fig);
      displayDumpImage([regexprep(text,pat,replace) ]);
      figure(actfig);
      cd(thisdir);
  end
