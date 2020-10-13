function [Xdrift Ydrift] = AccountDrift(Xdrift, Ydrift)
%This function compares two short brightfield videos and finds a lateral
%displacement between them, then (if asked) corrects all localisations in
%.csv file on the found drift value

%Parameters
Radius = 20; %in pixels
BeforeDriftName = 'beforewashing_568.tif';
AfterDriftName = 'afterwashing_568.tif';
LocFileName = '568.csv';
LocFileNewName = '568c.csv';
Npoints = 3;
Type = 'w';
pixelsize = 117;

%Program starts here

%get folder info
folder = uigetdir
list = dir(folder);

%find the files
for i=3:size(list,1)
    if size(list(i).name,2)>size(BeforeDriftName,2)
        if list(i).name(1,end-size(BeforeDriftName,2)+1:end)==BeforeDriftName
            FullBeforeDriftName = [folder '\' list(i).name];
        end
    end
    if size(list(i).name,2)>size(AfterDriftName,2)
        if list(i).name(1,end-size(AfterDriftName,2)+1:end)==AfterDriftName
            FullAfterDriftName = [folder '\' list(i).name];
        end
    end
    if size(list(i).name,2)>size(LocFileName,2)
        if list(i).name(1,end-size(LocFileName,2)+1:end)==LocFileName
            FullLocFileName = [folder '\' list(i).name];
        end
    end
end


%if drift information is not stated by user
if nargin<2

            % get first frame in before video
            before_info = imfinfo(FullBeforeDriftName); % return tiff structure, one element per image
            before_stack = imread(FullBeforeDriftName, 1) ; % read in first image
            
            %let user to chose fiducial markers
            figure
            imshow(before_stack(:,:,1), [min(min(before_stack(:,:,1))) max(max(before_stack(:,:,1)))])
            for j=1:Npoints
                hold on
                if j>1 plot(x0,y0, '.', 'Color', 'r'); end
                [x0(j) y0(j)] = getpts
            end
            close
            
            %concatenate each successive tiff to tiff_stack
            for ii = 2 : size(before_info, 1)
                temp_tiff = imread(FullBeforeDriftName, ii);
                before_stack = cat(3 , before_stack, temp_tiff);
            end
            
            %search for the specified markers at each frame
            levelB = 0.45; %threshold for images before
            for i=1:size(before_stack,3)
            disp(['I am analyzing before washing stack ' num2str(i) '/' num2str(size(before_stack,3))])
                frame = before_stack(:,:,i);
                for j=1:Npoints
                    [Xbefore(i,j) Ybefore(i,j)] = FindSpotPos(frame, x0(j), y0(j), Radius, Type);
                end
            end
                
            clear before_stack
            
            %here we open after tiff stack and searching for markers
            %position there 
            after_info = imfinfo(FullAfterDriftName); % return tiff structure, one element per image
            after_stack = imread(FullAfterDriftName, 1) ; % read in first image
            
            %concatenate each successive tiff to tiff_stack
            for ii = 2 : size(after_info, 1)
                temp_tiff = imread(FullAfterDriftName, ii);
                after_stack = cat(3 , after_stack, temp_tiff);
            end
            
            %search for the specified markers at each frame
            levelA = 0.03;
            for i=1:size(after_stack,3)
            disp(['I am analyzing after washing stack ' num2str(i) '/' num2str(size(after_stack,3))])
                frame = after_stack(:,:,i);
                for j=1:Npoints
                    [Xafter(i,j) Yafter(i,j)] = FindSpotPos(frame, x0(j), y0(j), Radius, Type, levelA); %threshold for images after
                end
            end
                
            clear after_stack
            
            
            
            %averaging positions and computing drift
%             Xaf = mean(Xafter); Yaf = mean(Yafter);
%             Xbe = mean(Xbefore); Ybe = mean(Ybefore);
  
            for i=1:Npoints
               a = Xafter(:,i);
               b = Yafter(:,i);
               c = Xbefore(:,i); d = Ybefore(:,i); 
               XA(1,i) = mean(a(~isnan(a))); YA(1,i) = mean(b(~isnan(b))); 
               XB(1,i) = mean(c(~isnan(c))); YB(1,i) = mean(d(~isnan(d))); 
            end
            XA
            YA
            XB
            YB
            Xdrift = mean(XA-XB)*pixelsize;
            Ydrift = mean(YA-YB)*pixelsize;
          
            
end
disp(['Drift in x direction: ' num2str(Xdrift) ' nm'])
disp(['Drift in y direction: ' num2str(Ydrift) ' nm'])
%read loc file 
locs = readtable(FullLocFileName);
locs.x_nm_ = locs.x_nm_ - Xdrift; 
locs.y_nm_ = locs.y_nm_ - Ydrift;   
writetable(locs, [FullLocFileName(1,1:end-size(LocFileName,2)) LocFileNewName])
end

