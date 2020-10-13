function [X, Y] = FindSpotPos(Image, x0, y0, R, type, level)
%This function searches for the center position of the spot (either white
%or black) near point x0, y0, in radius R. Returns nan if found nothing
%within R
MinSize = 5; % minimal size of the spot in pixels


%level = graythresh(Image);
%level = 0.4;
if nargin < 6 
    level = graythresh(Image);
end
BW = im2bw(Image,level);




if type == 'b'
    BW = ~BW;
    s=size(BW);
elseif type == 'w'
    BW = BW;
    s=size(BW);
else
    error('The spot type is wrong! Use w for white spots and b for black spots')
end

CC = bwconncomp(BW);

%to check
% figure
% imshow(BW)
% close


% go through all "islands" and choose the one which is the closest to x0 y0
% and within distance R. If no such island was found - saves (nan,nan)
MinDist = R; X = nan; Y = nan;
for i=1:size(CC.PixelIdxList,2)
    if size(CC.PixelIdxList{1,i},1)>MinSize
        xx = floor(CC.PixelIdxList{1,i}(:)/s(1))+1;
        yy = (CC.PixelIdxList{1,i}(:)/s(1) - floor(CC.PixelIdxList{1,i}(:)/s(1)))*s(1);
        
        
        xc = mean(xx); yc = mean(yy);
        if (xc-x0)^2+(yc-y0)^2<MinDist^2
            MinDist = sqrt((xc-x0)^2+(yc-y0)^2);
            X = xc; Y = yc;
        end
    end
end


%to check
% figure 
% imshow(Image)
% hold on
% plot(X, Y, 'o', 'Color', 'r')
end

