function [EROI_EiE_all] = EROIcalc(Z,e,Y,x,Foot,year,mask,nation)

% Anne Owen and Lina Brand Correa 2018
% EROI function

tStart = tic;
      
%% stage 1 - make the variables holders
i = 161; % sectors
s = 49; % No of regions 

%% Step 2: Generate box variables      
    Z0 = Z;
    Z0(:,nation*161-160:nation*161) = Z0(:,nation*161-160:nation*161).*mask; % Z0 matrix 
    A0 = Z0./repmat(x',i*s,1); % A0 matrix
    L0 = inv(eye(i*s) - A0); % L0 matrix 
    F0 = diag(e)*L0*diag(Y); % F0 matrix 

%% Step 3: Calculate EiE (see Equation (A13))
    EROI_EiE_all = (Foot - F0);     
disp(['  done=' num2str(toc(tStart)/60) 'm'])
end

