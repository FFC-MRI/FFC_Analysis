function [cluster_fit] = FFC_cluster_fit(cluster_out,min_cluster,startpoint_R1,noise_factor)
%% sort out the inputs and prepare the outputs

pulseseq = cluster_out.pulseseq;

Bevo = pulseseq.fieldpoints;
B0_pol = pulseseq.B0_pol./1000;

%% extracts the image from the pulse sequence object
data = pulseseq.magimage;

clusdata = cluster_out.fitdata;

time = pulseseq.timepoints;

T = cluster_out.T;


%% estimation of the dispersion curves using the clustered data and 2-dimension fit
Nclust = max(T);
cluster_fit.tR1 = [];
cluster_fit.tgamma = [];
cluster_fit.tgammad = [];
cluster_fit.tnoise = [];
cluster_fit.tres = [];
cluster_fit.tdR1 = [];

for indClust = 1:Nclust
    if sum(T==indClust)<min_cluster
        continue
    end
    
%     disp(indClust)
    % prepares the data
    temp = clusdata(T==indClust,:);
    dataclust_t = median(temp,1);
    dataclust_t = reshape(dataclust_t,size(data,4),size(data,5));
    % estimate the start point
    dataclust(1,:,:) = dataclust_t;

%      startpoint = [startpoint_R1 -max(dataclust(:))/B0_pol max(dataclust(:))/B0_pol (noise_factor/100)*max(dataclust(:))];
    
startpoint = [startpoint_R1 -max(dataclust(:)) max(dataclust(:)) (noise_factor/100)*max(dataclust(:))];
     
    [fitobject,gof,R1out] = fit_relaxation_cluster(dataclust,time./1000,Bevo,B0_pol,startpoint);
    % extract the results from the fit
    
    cluster_fit.cluster(indClust,:) = indClust;
    cluster_fit.tR1(indClust,:) = R1out;
    cluster_fit.tgamma(indClust) = fitobject.gamma; 
    cluster_fit.tgammad(indClust) = fitobject.gammad;
    cluster_fit.tnoise(indClust) = fitobject.noise; 
    cluster_fit.tres(indClust) = gof.rsquare; 
    cluster_fit.c = confint(fitobject);
    cluster_fit.tdR1(indClust,:) = diff(cluster_fit.c(:,1:4))./2;    
    cluster_fit.Bevo = Bevo;
    cluster_fit.B0pol = B0_pol;
    cluster_fit.startpoint = startpoint;
    cluster_fit.T = T;
    cluster_fit.data(indClust).a = dataclust_t;
    cluster_fit.time(indClust).a = time./1000;
    
end

end


