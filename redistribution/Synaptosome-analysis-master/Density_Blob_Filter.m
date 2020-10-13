%   This function performs a 2 step filtering based on a density of
%   localizations and their spatial distribution in order to remove loose
%   blobs of localizations. Adapted from Ezra Bruggeman code
%
%   INPUT:   
%   X............: nx2 or nx3 double containing coordinates of n points
%   Radius.......: maximum radius of blobs should be removed
%   N_min........: minimum number of neighbours a point needs to have in
%                  order for it not to be filtered out in R
%   Blob.........: should be 1 if you want to perform loose blob filtering
%   and 0 if not
%   OUTPUT:
%   locs_filtered: mx2 or mx3 double containing the coordinates of the
%                  filtered points (with m < or = n, the number of points
%                  from the input)
%   indeces......: nx1 double (with same length as number of points from
%                  the input X) that can be used to check which points were
%                  kept and which were filtered out
%                  (1 = kept, 0 = filtered out)
%   numNeighbours: nx1 double (with same length as number of points from
%                  the input X) that contains the number of neighbours
%                  within a radius search_radius for each localization
%   Author: Ezra Bruggeman, Stas Makarchuk
%   Last updated: 16/05/2019

function [locs_filtered, indeces, numNeighbours] = Density_Blob_Filter(X,Radius,N_min,Blob,show)

disp('Density filtering:')

% Get number of neighbours within a radius R/2, R and 2*R for every localization

[idx,~]= rangesearch(X,X,Radius);
numNeighbours = cellfun(@(x) numel(x), idx);
clear idx

if Blob
disp('Blob filtering out /2:')

[idx,~]= rangesearch(X,X,Radius/2);
numNeighbours_2 = cellfun(@(x) numel(x), idx);

disp('Blob filtering out X2:')
[idx,~]= rangesearch(X,X,2*Radius);
numNeighboursX2 = cellfun(@(x) numel(x), idx);

%difference between numberofNeighbours for different Radius

DifR = (numNeighboursX2 - numNeighbours) - (numNeighbours - numNeighbours_2);

end

% Create an array with the same length as the number of localizations with
% 1 at the index of every localization that has more than n neighbours in
% Radius
indeces = zeros(size(numNeighbours));
indeces(numNeighbours > N_min) = 1;


if size(X,2) == 2 % If 2D
    x = X(:,1); y = X(:,2);
    if Blob
        disp('Filtering out...')
        locs = array2table([indeces DifR x y],'VariableNames',{'id', 'DifR','x','y'});
        locs_filtered = locs(locs.DifR>0,:);
    else
        locs = array2table([indeces x y],'VariableNames',{'id','x','y'});
        locs_filtered = locs(locs.id == 1,:);
    end
    
    locs_filtered = [locs_filtered.x locs_filtered.y];
elseif size(X,2) == 3 % If 3D
    x = X(:,1); y = X(:,2); z = X(:,3);
    if Blob
        locs = array2table([indeces DifR x y],'VariableNames',{'id', 'DifR','x','y', 'z'});
        locs_filtered = locs(locs.id == 1,locs.DifR>0,:);
    else
        locs = array2table([indeces x y],'VariableNames',{'id','x','y','z'});
        locs_filtered = locs(locs.id == 1,:);
    end
    locs_filtered = [locs_filtered.x locs_filtered.y locs_filtered.z];
end


disp(['    Number of points before filtering: ' num2str(size(X,1))])
disp(['    Number of points after  filtering: ' num2str(size(locs_filtered,1))])
disp(['    Percentage of points filtered out: ' num2str(round(100-(100*size(locs_filtered,1)/size(X,1)))) '%'])



if show
    if size(X,2) == 2
        figure('units','normalized','outerposition',[0 0 1 1]);
        
        xmax = max(locs.x); xmin = min(locs.x);
        ymax = max(locs.y); ymin = min(locs.y);
        
        subplot(131)
        scatter(locs.x,locs.y,'.r')
        title('Before filtering','FontSize',20)
        pbaspect([1 1 1]); xlim([xmin xmax]); ylim([ymin ymax]);
        
        subplot(132)
        scatter(locs_filtered(:,1),locs_filtered(:,2),'.b')
        title('After filtering','FontSize',20)
        pbaspect([1 1 1]); xlim([xmin xmax]); ylim([ymin ymax])
        
        subplot(133)
        scatter(locs.x,locs.y,'.r')
        hold on
        scatter(locs_filtered(:,1),locs_filtered(:,2),'.b')
        title('Overlay','FontSize',20)
        pbaspect([1 1 1]); xlim([xmin xmax]); ylim([ymin ymax])
        
    elseif size(X,2) == 3
        print('No option to display 3D data (yet).')
    end
end


end

