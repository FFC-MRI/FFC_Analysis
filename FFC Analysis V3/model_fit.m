
function f = model_fit(R1,gamma,gammad,B0,noise,t,B0pol)

f = sqrt(((gamma*B0pol-gammad*B0).*exp(-t*R1)+gammad*B0).^2 + ...
                2*((gamma*B0pol-gammad*B0).*exp(-t*R1)+gammad*B0).*abs(noise) + ...
                2*noise.^2);
            
end