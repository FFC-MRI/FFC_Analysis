
function maskout = draw_circle_ROI(Image_in,lims,maskin,circlesize)

figure('units','normalized','outerposition',[0 0 1 1])

[rows, columns, ~] = size(Image_in);

subplot(2,2,[1 2])
imagesc(Image_in);
axis image
colormap gray
title('Draw each ROI here.','FontSize',20);
caxis([lims])

[xi,yi] = getpts;

xir = round(xi);
yir = round(yi);
        
mask(:,:) = createCirclesMask([rows,columns],[xir,yir],[circlesize]);
 
mask = mask.*maskin;

maskout = mask;

subplot(2,2,[3 4])

imagesc(maskout);
axis image
colormap gray
title('ROI','FontSize',20);
 
end
    