clc;clear all,close all
for xcounter=1:25
	a(xcounter,:,xcounter)=rand;
        for ycounter=1:50
            a(:,ycounter,:)=rand;
        end
end

a = squeeze(a);
p1 = patch(isosurface(a, .25),'FaceColor','red',...
 'EdgeColor','none');
p2 = patch(isocaps(a, .25),'FaceColor','interp',...
 'EdgeColor','none');
view(3); axis tight;
% colormap(gray(100))
camlight left; camlight; lighting gouraud
isonormals(a,p1)