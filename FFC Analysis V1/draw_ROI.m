
function maskout = draw_ROI2(Image_in,lims,maskin)

figure('units','normalized','outerposition',[0 0 1 1])

[rows, columns, ~] = size(Image_in);
subplot(2,2,[1 2]);
imagesc(Image_in);
axis image
colormap gray
title('Draw each ROI here.','FontSize',20);
caxis([lims])
subplot(2,2,3);
imagesc(Image_in);
caxis([lims])
axis image
colormap gray

title('ROI boundary display','FontSize',20);

maskout = zeros(rows, columns);

subplot(2,2,4);
imagesc(maskout);
axis image
colormap gray


while 1 < 2
    
	button = questdlg('Draw next ROI or Finish.', 'Next ROI' , 'Draw', 'Finish', 'Draw');
    
if strcmpi(button, 'Finish')
		
    break;
    
end
    
    subplot(2,2,[1 2]);
    [mask_temp, xi, yi] = roipoly();
    maskout = maskout | mask_temp;
    
    maskout = maskout .* maskin;
    
    
    subplot(2,2,3)
    hold on;
	plot(xi, yi, 'r-', 'LineWidth', 2);
    
    subplot(2,2,4)
    imagesc(maskout);
    axis image
colormap gray
    title('ROI mask disiplay','FontSize',20);
    
    
end

end
    