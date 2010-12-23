function [xy_pos,xy_neg]=fct_SetPoints(InputImage)
%% Function takes an Image as input, and lets the user select positive and
%% negative points on this image interactively. The output of the function
%% are two vectors [xy_pos, xy_neg ] which are the coordinates of the
%% selected positive and negative points.
%%
%% example usage: 
%%    image = phantom;
%%    [xy_pos,xy_neg]=fct_SetPoints(image)

%% Choose Positive Points
figure_setpositive = figure;
    imshow(InputImage,[])
    wait=helpdlg('Choose positive Points in shown picture. Stop with right mouse button',...
        'Selection');
	uiwait(wait)
    hold on % let me draw over stuff already drawn
    xy_pos = []; % empty positive coordinates at the beginning
    n = 0; % set pointer to zero
    button = 1; % clicking with left mouse button keeps going, clicking another button ends the selection
    while button == 1 % abort if another mousebutton than 1 is pressed
        [xi,yi,button] = ginput(1);
        if button == 1 % only save point if left mouse button is pressed
            plot(xi,yi,'g+'); % plot the chosen points as 'r' red '+' crosses over the image
            n = n+1;
            xy_pos(:,n) = [xi,yi];
        end
    end
close(figure_setpositive);

%% Choose negative Points
figure_setnegative = figure;
    imshow(InputImage,[])
    hold on;
    if size(xy_pos,2) >= 1 % If we haven't saved a positive point, we can proceed without showing it to the user
        hold on;
        plot(xy_pos(1,:),xy_pos(2,:),'go')
        title([ 'You chose these ' num2str(size(xy_pos,2)) ' positive Points'])
    else
        xy_pos = [];
    end
    wait=helpdlg({['You chose ' num2str(size(xy_pos,2)) ,...
        ' positive points (Marked in picture with green circle)'];...
        [''];['Now choose negative Points in shown picture. Stop with right mouse button']},...
    'Selection');
    uiwait(wait)
    hold on % let me draw over stuff already drawn
    xy_neg = []; % empty negative coordinates at the beginning
    n = 0; % set pointer to zero
    button = 1; % clicking with left mouse button keeps going, clicking another button ends the selection
    while button == 1
        [xi,yi,button] = ginput(1);
        if button == 1
            plot(xi,yi,'r+'); % plot the chosen points as 'r' red '+' crosses
            n = n+1;
            xy_neg(:,n) = [xi,yi];
        end
    end
close(figure_setnegative)    

if size(xy_neg,2) == 0 % Warn the user if he has not chosen a negative point
	warn=warndlg('You did not choose a negative Point. Proceeding...','Warning');
    uiwait(warn)
end    

figure_showall = figure;
    imshow(InputImage);
    hold on
    title([ num2str(size(xy_pos,2)) ' green circles as positive Points - ',...
        num2str(size(xy_neg,2)) ' red circles as negative Points'])
    if size(xy_pos,2) >= 1
        plot(xy_pos(1,:),xy_pos(2,:),'go')
        if size(xy_neg,2) >= 1
            plot(xy_neg(1,:),xy_neg(2,:),'ro')
        end
    elseif size(xy_pos,2)== 0
        if size(xy_neg,2)== 0
            warn=warndlg('You did not choose one point at all. You might start again...','Warning');
            uiwait(warn)
        elseif size(xy_neg,2) >= 1
            plot(xy_neg(1,:),xy_neg(2,:),'ro')
        end
    end

end
