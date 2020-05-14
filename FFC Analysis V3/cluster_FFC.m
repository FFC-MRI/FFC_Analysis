function [Cluster_out] = cluster_FFC(pulseseq,thresh,mask,smoothing_size,median_filter_size,minimum_cluster_size)

%% extracts the image from the pulse sequence object
data = abs(pulseseq.compleximage);

%% normalisation of the image
[~,indnorm] = min(pulseseq.timepoints(1,:));
normalisedimage = squeeze(data)./squeeze(repmat(data(:,:,1,indnorm,1),1,1,1,size(data,4),size(data,5)));

dim = size(normalisedimage);

if isnan(smoothing_size) ~= 1
    display('smoothing')
[data_i] = smoothing_ns(normalisedimage,smoothing_size);
normalisedimage = data_i;
end


%% make a mask for the image
mask2 = reshape(mask,[prod(dim(1:2)),1]);
pixs = find(mask == 1);

%% vectorisation of the image
clusdata = reshape(normalisedimage.*repmat(mask,1,1,size(data,4),size(data,5)),size(data,1)*size(data,2),size(data,4)*size(data,5));
clusdata2 = clusdata(pixs,:);

clusterimaget = zeros(length(mask2),1);

%% hierarchical clustering squareform (https://www.mathworks.com/help/stats/hierarchical-clustering.html)
Y = pdist(clusdata2);
Z = linkage(Y);

c = cophenet(Z,Y); % check validity of linkage (should be close to 1)
I = inconsistent(Z); % check for inconsistency

T = cluster(Z,'cutoff',thresh);

clusterimaget(pixs) = T;
% clusterimaget = T;
clusterimg = reshape(clusterimaget,dim(1),dim(2));

% J = medfilt2(clusterimg,[median_filter_size,median_filter_size]);



clusterimg2 = clusterimg;
clusterimg2(clusterimg2 == 0) = -max(clusterimg(:));
AT = max(clusterimg(:));

J = medfilt2(clusterimg);

for lx = 1: max(T)
    
    if length(J(J == lx)) < 10
        
        J(J == lx) = -max(J(:));
        
    end
    
end

J(J == 0) = -max(J(:));

figure(41)
imagesc(clusterimg2)
caxis([-AT AT])
colormap jet
figure(42)
dendrogram(Z)
figure(43)
imagesc(J)
caxis([-max(J(:)) max(J(:))])
colormap jet

Cluster_out.filtered_clusterimg = J;
Cluster_out.clusterimg = clusterimg;
Cluster_out.threshold = thresh;
Cluster_out.min_cluster_size = minimum_cluster_size;
Cluster_out.median_filter_size = median_filter_size;
Cluster_out.mask = mask;
Cluster_out.Z = Z;
Cluster_out.clusdata2 = clusdata2;
Cluster_out.data = data;
Cluster_out.T = T;

display('finished')

end



%%

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

