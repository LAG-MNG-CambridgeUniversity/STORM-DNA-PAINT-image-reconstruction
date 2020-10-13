function [file,path] = CropSynaptosome()
%This function uses an image with two colors in order to crop and save it
%into smaller images with one synaptosome in each
ImageSize = 150; %in pixels
NumberOfSynaptosomes = 2;
Channel1 = 1;
Channel2 = 2;
SaveFolder = 'Cropped synaptosomes';
MinSize = 10; %minimum size of accepted cluster (in pixels)
[file,path] = uigetfile

Image = imread([path file]);



%ask user to manually select approximate synaptosome
for i=1:NumberOfSynaptosomes
   figure
   imshow(Image)
   
   if i>1
       for j=1:i-1
           hold on
           plot(Xin(j,1), Yin(j,1), 'o', 'MarkerSize', 10, 'Color', 'w')
       end
   end
   
   [Xin(i,1) Yin(i,1)] = getpts;
   close
end


%check folder for results saving and if not exist - create one
SaveFolderFull = [path SaveFolder];
if ~exist(SaveFolderFull, 'dir')
   mkdir(SaveFolderFull)
end


%get positions of all clusters in image
BW1 = im2bw(Image(:,:,Channel1),0);
BW2 = im2bw(Image(:,:,Channel2),0);


CC1 = bwconncomp(BW1);
CC2 = bwconncomp(BW2);
% go through all "islands" and choose the one which is the closest to x0 y0
% and within distance R. If no such island was found - saves (nan,nan)
NumberOfClusters1 = size(CC1.PixelIdxList,2); s = size(BW1);
for i=1:size(CC1.PixelIdxList,2)
    if size(CC1.PixelIdxList{1,i},1)>MinSize
        xx = floor(CC1.PixelIdxList{1,i}(:)/s(1))+1;
        yy = (CC1.PixelIdxList{1,i}(:)/s(1) - floor(CC1.PixelIdxList{1,i}(:)/s(1)))*s(1);
        XCluster1(i,1) = mean(xx); YCluster1(i,1) = mean(yy); SizeCluster1(i,1) = size(xx,1);
    end
end
NumberOfClusters1 = size(XCluster1,1);


NumberOfClusters2 = size(CC2.PixelIdxList,2);
for i=1:size(CC2.PixelIdxList,2)
    if size(CC2.PixelIdxList{1,i},1)>MinSize
        xx = floor(CC2.PixelIdxList{1,i}(:)/s(1))+1;
        yy = (CC2.PixelIdxList{1,i}(:)/s(1) - floor(CC2.PixelIdxList{1,i}(:)/s(1)))*s(1);
        XCluster2(i,1) = mean(xx); YCluster2(i,1) = mean(yy); SizeCluster2(i,1) = size(xx,1);
    end
end
NumberOfClusters2 = size(XCluster2,1);

%here we are looking for largest spot in both channels and search its
%center to find center for cropped image
for i=1:NumberOfSynaptosomes
        
        MinDist = 10000; 
        %Check for the closest spot from each channel
        for j=1:NumberOfClusters1
            if (XCluster1(j,1)-Xin(i,1))^2+(YCluster1(j,1)-Yin(i,1))^2<MinDist^2
                MinDist = sqrt((XCluster1(j,1)-Xin(i,1))^2+(YCluster1(j,1)-Yin(i,1))^2);
                xc1 = XCluster1(j,1); yc1 = YCluster1(j,1); s1 = SizeCluster1(j,1)
            end
        end
        MinDist = 10000; 
        for j=1:NumberOfClusters2
            if (XCluster2(j,1)-Xin(i,1))^2+(YCluster2(j,1)-Yin(i,1))^2<MinDist^2
                MinDist = sqrt((XCluster2(j,1)-Xin(i,1))^2+(YCluster2(j,1)-Yin(i,1))^2);
                xc2 = XCluster2(j,1); yc2 = YCluster2(j,1); s2 = SizeCluster2(j,1)
            end
        end
        
        
        %for cropping area we choose larger synaptosome
        if s1>=s2
            img = Image(yc1-round(ImageSize/2)+1:yc1+round(ImageSize/2),xc1-round(ImageSize/2)+1:xc1+round(ImageSize/2),:);
        else
            img = Image(yc2-round(ImageSize/2)+1:yc2+round(ImageSize/2),xc2-round(ImageSize/2)+1:xc2+round(ImageSize/2),:);
        end
%         imshow(img)
%         size(img)
%         %saving
%         saveas(gcf, [SaveFolderFull '\' file(1:end-3) '_synaptosome' num2str(i) '.tif'], 'tiffn')
%         close
          imwrite(img, [SaveFolderFull '\' file(1:end-4) '_synaptosome' num2str(i) '.tif'])
end


end

