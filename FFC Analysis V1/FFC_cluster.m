function [cluster_out] = FFC_cluster(pulseseq,thresh,mask,smoothing_size,mode_size,imagetype)

%% sort out the inputs and prepare the outputs

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % B0_pol = pulseseq.param{62, 3}./1000;
Bevo = pulseseq.fieldpoints;
B0_pol = pulseseq.B0_pol./1000;

%% extracts the image from the pulse sequence object

if imagetype == 1
data = abs(pulseseq.compleximage);
else 
data = pulseseq.magimage;
end

%% normalisation of the image
[~,indnorm] = min(pulseseq.timepoints(1,:));
[~,indfield] = max(Bevo); % the firs tacquisition is not necessarily at the highest field
normalisedimage = squeeze(data)./squeeze(repmat(data(:,:,1,indnorm,indfield),1,1,1,size(data,4),size(data,5)));
%% smoothing

if isnan(smoothing_size) ~= 1
    display('smoothing')
[data_i] = smoothing_ns(normalisedimage,smoothing_size);
normalisedimage = data_i;
end

%% make a mask for the image
% [mag,bin] = hist(data(:),1000);
% [~,indmag] = max(mag);
% mask = data<bin(indmag)/10;
% % % % % % % % mask = data>max(data(:))/20;
% % % % % % % % mask = sum(mask(:,:,:),3) > 1;


%% vectorisation of the image
clusdata = reshape(normalisedimage.*repmat(mask,1,1,size(data,4),size(data,5)),size(data,1)*size(data,2),size(data,4)*size(data,5));

%% data for fit 
datavtemp = squeeze(data);
datav = reshape(datavtemp,size(data,1)*size(data,2),size(data,4)*size(data,5));

%% hierarchical clustering squareform (https://www.mathworks.com/help/stats/hierarchical-clustering.html)
Y = pdist(clusdata);
Z = linkage(Y);

c = cophenet(Z,Y); % check validity of linkage (should be close to 1)
I = inconsistent(Z); % check for inconsistency

T = cluster(Z,'cutoff',thresh);
T_unfiltered = T;

clusterimg = reshape(T,size(data,1),size(data,2));

clusterimg_unfiltered = clusterimg; 


%% smoothing

if isnan(mode_size) ~= 1
    display('mode filter applied')
    
% clusterimg = medfilt2(clusterimg,[median_size,median_size])
clusterimg = colfilt(clusterimg, [mode_size mode_size], 'sliding', @mode);

T = reshape(clusterimg,size(T,1),size(T,2));
end


% figure(41)
% imagesc(clusterimg_unfiltered)
% figure(42)
% dendrogram(Z)
% figure(43)
% imagesc(clusterimg)


cluster_out.mode_size = mode_size; 
cluster_out.clusterimg_unfilt = clusterimg_unfiltered;
cluster_out.dendrogram = Z;
cluster_out.smoothing_size = smoothing_size;
cluster_out.mask = mask;
cluster_out.threshold = thresh; 
cluster_out.pulseseq = pulseseq;
cluster_out.T_unfilt = T_unfiltered;
cluster_out.clusterimg = clusterimg;
cluster_out.T = T;
cluster_out.clusdata = clusdata;
cluster_out.data = data;
cluster_out.fitdata = datav;


end


function [data_i] = smoothing_ns(data_i,sigma)

if isempty(sigma) == 0
      
dim = size(data_i);

    for jx = 1:dim(3)
        for px = 1:dim(4)
    
    imgtemp(:,:) = data_i(:,:,jx,px);
    
% 2-D Gaussian smoothing kernel with standard deviation specified by sigma
    
    D = imgaussfilt(imgtemp,sigma);
    
    data_i(:,:,jx,px) = D; 
    
        end
    end



end

end

