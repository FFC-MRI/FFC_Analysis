clear all
close all

load('data20191205.mat')
data = d;
img = d;

figure('Position', [100 300 1400 500])

%% Step One 

subplot(1,2,1)

imagesc((abs(img(:,:,1,6,1))))
axis square
colorbar

[x0, y0] = getpts;

x0r = round(x0);
y0r = round(y0);

disp(x0r)
disp(y0r)

pause

for Bx = 1:4
    
    for Ex = 1:10
        
        
        img_temp(:,:) = data(:,:,1,Ex,Bx);
       
        
        subplot(1,2,2)
        imagesc((abs(img_temp)))
        title(['Field ' num2str(Bx) ', Evolution ' num2str(Ex)])
        axis square
        colorbar
        caxis([0 200])
        hold on
        scatter(x0,y0,'w','MarkerFaceColor','w')
        
        [xi,yi] = getpts;

        xir = round(xi);
        yir = round(yi);
        
        for Cx = 1:4
            
        mask(:,:,Ex,Bx,Cx) = createCirclesMask([32,32],[xir(Cx),yir(Cx)],[1]);
        
        figure 
        imagesc(mask(:,:,Ex,Bx,Cx))
        pause 
        
        end
        
        xi_out(Ex,Bx,Cx,:) = xir;
        yi_out(Ex,Bx,Cx,:) = yir;
        
    end
    
end 

%%

out.mask = mask;
out.xi_out = xi_out;
out.yi_out = yi_out;

save('ROIout','out')

    %%
    
    figure
    
    for Cx = 1:4
        for Bx = 1:4
            for Ex = 1:10
            
    imshow(mask(:,:,Ex,Bx,Cx));
    axis square
    title(['Bottle ' num2str(Cx) ', Field ' num2str(Bx) ', Evolution ' num2str(Ex)])
    pause 

            end
        end
    end
    
    
    