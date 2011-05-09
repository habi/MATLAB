clc;clear all;close all;

[ filename, pathname] = ...
     uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
          '*.*','All Files' },'Choose Input Image',...
          'P:\doc\\image.png');

image=imread([pathname filesep filename]);

InputDialog={...
    'Length of the Scale Bar your are gonna draw in the image. (in pixels)',... %1
    'What`s the pixel size (im um)?',...                                        %2
    'Do not draw scalebar, use width of image. Makes first entry obsolete',...	%3
    };
Name='Input the Details';
NumLines=1;
Defaults={'pixels','1.48','0'};
UserInput=inputdlg(InputDialog,Name,NumLines,Defaults);
UseSize = str2num(UserInput{3});
um = str2num(UserInput{2});

figure
    imshow(image)
    hold on

if UseSize == 0    
    h = helpdlg('choose start-point of scalebar','ScaleBar');
    uiwait(h);
    [ x1,y1 ] = ginput(1);
    h = helpdlg('choose end-point of scalebar','ScaleBar');
    uiwait(h);
    [ x2,y2 ] = ginput(1);
    pixels = str2num(UserInput{1});
elseif UseSize == 1
    h = helpdlg('Using full width of Image as Scale','ScaleBar');
    uiwait(h);
    x1 = 0;
    x2 = size(image,2);
    y1 = size(image,1)/2;
    y2 = size(image,1)/2;
    pixels = size(image,2);
else
    h = helpdlg('You have to set the third option to either 0 or 1. Exiting!','ScaleBar');       
    uiwait(h);
    break
end
    
    line([x1,x2],[y1,y2]);
    
scale = pixels * um /1000;    

length = sqrt((x1-x2)^2+(y1-y2)^2);
dpixel = scale / length * 100 * 1000;
um = 100 / dpixel * 500;

    title([ 'Vectorlength: ' num2str(round(length)) 'px = ' num2str(scale) ...
        'mm, 100px = ' num2str(round(dpixel)) ' um, ' num2str(round(um)) ...
        'px = 500 um'])

% h = helpdlg(['Image Size = ' num2str(size(image,2)) 'x' ...
%     num2str(size(image,1)) ' px - (x1,y1) = (' num2str(round(x1)) ',' ...
%     num2str(round(y1)) ') - (x2, y2) = (' num2str(round(x2)) ',' ...
%     num2str(round(y2)) ')'],'Positions');
% uiwait(h);
% close all;

disp('\documentclass{article}')
disp('\usepackage{graphicx}')
disp('\usepackage{tikz}')
disp('\usepackage{siunitx}')
disp('\usepackage[graphics,tightpage,active]{preview}')
disp('\PreviewEnvironment{tikzpicture}')
disp('\newcommand{\imsize}{\linewidth}')
disp('\newlength\imagewidth           % needed for scalebars')
disp('\newlength\imagescale           % ditto')
disp('\begin{document}%')
disp('%-------------')
disp('\pgfmathsetlength{\imagewidth}{\imsize}%')
disp(['\pgfmathsetlength{\imagescale}{\imagewidth/' num2str(size(image,2)) '}%'])
disp(['\def\x{' num2str(round(size(image,2)*.618)) '}% scalebar-x at golden ratio of x=' num2str(size(image,2)) 'px' ])
disp(['\def\y{' num2str(round(size(image,1)*.9)) '}% scalebar-y at 90% of height of y=' num2str(size(image,1)) 'px' ])
disp(['\def\shadow{' num2str(round((size(image,2)*.618/100))) '}% shadow parameter for scalebar' ])
disp('\begin{tikzpicture}[x=\imagescale,y=-\imagescale]')
disp(['\clip (0,0) rectangle (' num2str(size(image,2)) ',' num2str(size(image,1)) ');'])
disp(['	\node[anchor=north west, inner sep=0pt, outer sep=0pt] at (0,0) {\includegraphics[width=\imagewidth]{' pathname filename '}};' ])
disp(['	% ' num2str(round(length)) 'px = ' num2str(scale) 'mm > 100px = ' num2str(round(dpixel)) ...
    'um > ' num2str(round(um)) 'px = 500um, ' num2str(round(um/500*100)) 'px = 100um'])
disp(['	\draw[|-|,blue,thick] (' num2str(round(x1)) ',' num2str(round(y1)) ...
    ') -- (' num2str(round(x2)) ',' num2str(round(y2)) ') node [sloped,midway,above,fill=white,semitransparent,text opacity=1] '...
    '{\SI{' num2str(scale) '}{\milli\meter} (' num2str(pixels) 'px) TEMPORARY!};' ])
disp(['\draw[|-|,thick] (\x+\shadow,\y+\shadow) -- (\x+' num2str(round(um)) ...
        '+\shadow,\y+\shadow) node [midway, above] {\SI{500}{\micro\meter}};'])
disp(['	\draw[|-|,white,thick] (\x,\y) -- (\x+' num2str(round(um)) ...
    ',\y) node [midway,above] {\SI{500}{\micro\meter}};'])
disp(['	\draw[color=red, anchor=south west] (0,' num2str(size(image,1)) ') node [fill=white, semitransparent] {Legend} node {Legend};']) 
disp('\end{tikzpicture}%');
disp('%-------------')
disp('\end{document}%')