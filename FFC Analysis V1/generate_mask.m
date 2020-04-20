function [mask] = generate_mask(H9_se_nav_v9,n_ROIs)

%% Generate mask

data = H9_se_nav_v9.magimage;

dim = size(data);

figure

mask = zeros(dim(1),dim(2),dim(3));
maskt = zeros(dim(1),dim(2),dim(3));

for cx = 1:dim(3)
    for dx = 1:n_ROIs
    
imagesc(data(:,:,cx,end,end))
maskt(:,:,cx) = roipoly;
mask(:,:,:) = mask+maskt;
maskt = zeros(dim(1),dim(2),dim(3));

    end 
end

mask(mask>0) = 1;


figure
for cx = 1:dim(3)
    subplot(1,dim(3),cx)
    imagesc(mask)
end
disp('Paused. Press any key to continue.');
pause 
 
end


