%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XML Parser for MeVisLab-Manhole-Cover-XML-Files
% First version 22.12.2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear all;close all;

%% MeVisLab
xDoc = xmlread('C:\Users\haberthuer\Desktop\XML-Test.xml');

%% 04
xDoc = xmlread('D:\SLS\2010a\mrg\R108C04At-mrg\R108C04At-mrg.2936x2936x1024.marker.xml');
xDoc = xmlread('D:\SLS\2010a\mrg\R108C04Bt-mrg\R108C04Bt-mrg.2932x2932x1024.marker.xml');
xDoc = xmlread('D:\SLS\2010c\R108C04D_B1_mrg\R108C04D_B1_mrg.2948.2948.1024.marker.xml');

%% 10
xDoc = xmlread('D:\SLS\2010c\R108C10C_B1_mrg\R108C10C_B1_mrg.2948.2948.1024.marker.xml');

%% 21
xDoc = xmlread('D:\SLS\2010c\R108C21D_B1_mrg\R108C21D_B1_mrg.2948.2948.1024.marker.xml');

%% 36
xDoc = xmlread('D:\SLS\2010c\R108C36A_B1_mrg\R108C36A_B1_mrg.2948.2948.1024.marker.xml');

%% 60
% xDoc = xmlread('D:\SLS\2010c\R108C60B_B1_mrg\R108C60B_B1_mrg.2948.2948.1024.marker.xml');
% xDoc = xmlread('D:\SLS\2010c\R108C60B_B3_mrg\R108C60B_B3_mrg.2948.2948.1024.marker.xml');
% xDoc = xmlread('D:\SLS\2010a\mrg\R108C60C_B1-mrg\R108C60C_B1-mrg.2394x2934x1024.marker.xml');
% xDoc = xmlread('D:\SLS\2009f\mrg\R108C60Et-mrg\R108C60Et-mrg.2444.2944.1024.marker.xml');

% Find a deep list of all listitem elements.
allListItems = xDoc.getElementsByTagName('pos');

% Preallocate Size for Position
Position = zeros(3,allListItems.getLength);

for k = 0:allListItems.getLength-1
	currentListItem = allListItems.item(k);
	childNode = currentListItem.getFirstChild;
	currentPosition = char(childNode.getData);
    ARGLBARGL = str2num(char(cellstr(regexp(currentPosition, ' ', 'split'))));
    Position(:,k+1) = [ ARGLBARGL(1) , ARGLBARGL(2) , ARGLBARGL(3) ];
end

Position

figure
    plot3(Position(1,:),Position(2,:),Position(3,:),'*')
    title([ num2str(allListItems.getLength) ' Markers' ]);
    grid on