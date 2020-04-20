
% data_in form = [no. evolution times x no. evolution fields]
% t form = [no. evolution fields x no. evolution times], in s
% B0 form = [no. evolution fields x 1], in mT

function [fitobject,gof,R1out] = fit_relaxation_cluster(data_in,t,B0,B0_pol,startpoint)

[number_fields, number_times] = size(t);

B0 = B0./1000;

data_int(:,:) = data_in(1,:,:);

calv = max(data_int(:));

%% setting up surface fit 

    for nb = 1:number_fields
        
        h{nb} = singleexphandle_ns(nb,t,B0_pol);
        
    end
    
    for nb = 1:number_fields
    
        if nb < number_fields
    str1{1,nb} = ['h{' num2str(nb) '} (R1_' num2str(nb) ' ,gamma, gammad, noise,  t, B0) + '];
    strA{1,nb} = ['fitobject.R1_' num2str(nb) ' ']; 
        else 
    str1{1,nb} = ['h{' num2str(nb) '} (R1_' num2str(nb) ' ,gamma, gammad, noise,  t, B0)']; 
    strA{1,nb} = ['fitobject.R1_' num2str(nb)]; 
        end
    str2{1,nb} = ['R1_' num2str(nb) ','];
    
    end
    
    newStr1 = join(str1);
    newStr2 = join(str2);
    newStrA = join(strA);
    
      str_ftype = join(['ftype = fittype(@(' string(newStr2) 'gamma,gammad,noise,t,B0) ' ...
          string(newStr1) ', ' '''independent''' ',' '{' '''t''' ' ' '''B0''' '});']);
     eval(string(str_ftype));

   %% setting up fit  
     
    B0up = ones(1,number_fields).*100;
    B0low = ones(1,number_fields).*0;
    R1start = ones(1,number_fields).*5;
    
    foption = fitoptions(ftype);
    foption.Upper = [B0up    0 Inf Inf];
    foption.Lower = [B0low -inf   -Inf  0];
    foption.Robust = 'on';
    foption.MaxIter = 10000;
    foption.MaxFunEvals = 10000;
    
    
    x = t; x = x(:);
    y = repmat(B0,1,number_times); y = y(:);
    z = data_int'; z = z(:);
    
    
    if nargin < 5
        foption.StartPoint = [R1start -10*calv 15*calv 0.02*calv];
    else
        foption.StartPoint =  startpoint;
    end
    
%     yplot(1:5) = x([3,7,11,15,19]);
%     zplot(1:5) = z([3,7,11,15,19]);
%     figure
%     scatter(yplot,zplot)
%     pause
    
    [fitobject,gof] = fit([x,y],z,ftype,foption);
    str_R1 = join(['R1 = [' string(newStrA) '];']);
    eval(string(str_R1));
    R1out = R1;
    
end

function h = singleexphandle_ns(n,t,B0_pol)

mask = zeros(size(t));
mask(n,:)=1;
mask = mask(:);

h = @(R1, gamma, gammad, noise,  t, B0) model(R1, gamma, gammad, noise,  t, B0);
    
    function f = model(R1, gamma, gammad, noise,  t, B0)
        if isequal(size(mask(:)),size(B0(:)))
            f = sqrt(((gamma*B0_pol-gammad*B0).*exp(-t*R1)+gammad*B0).^2 + ...
                2*((gamma*B0_pol-gammad*B0).*exp(-t*R1)+gammad*B0).*abs(noise) + ...
                2*noise.^2);
            f = f.*mask;
        else
            f = zeros(size(B0));
        end
    end
end


