% Anne Owen and Lina Brand Correa 2018
% Run this code second to calculate Primary Energy EROI

%% Step 1 make the masks
load EIOU_PRIM.mat
load NRG_PRIM.mat
tStart = tic;
col = 20; % position of coal sector
oil = 21; % position of oil sector
gas1 = 22; gas2 = 23; % position of gas sector
all = {col,oil,gas1,gas2};
mask = ones(7889,161);
fuellookup = [20,20,21,22;23,20,21,23];

for a = 1:49
    for b = 1:4
        for c = 1:4
            mask(:,all{c}) = zeros(7889,1); %all fuels
           
        end
    end
end

%% step 1a make new vector for EiE
NRG_PRIM_EiE = zeros(1,7889,17);
for a = 1:17
    NRG_PRIM_EiE(1,:,a) = NRG_PRIM(1,:,a)+EIOU_PRIM(1,:,a);
end          
%% Step 2 make Ei by calling function
 
datapath = 'O:/UKERC/EXIOBASE V3.4';
EXIOconc = xlsread('1_FIN_170_countries_TFCdata_25_10_17','1.4_EXIO_elec_squash','C3:FG165');
bigEXIOconc = zeros(49*163,49*161);
for a = 1:49
     bigEXIOconc(a*163-162:a*163,a*161-160:a*161) = EXIOconc;
end
EiE = zeros(49,17,4);
ET = zeros(49,17,4);
EdE = zeros(49,17,4);
EROI_EiE_all = zeros(7889,7889);
EROI_PRIM_result = zeros(49,17,4);
for year = 1995:2011 
    year
    Astruct = importdata([datapath '/IOT_' num2str(year) '_ixi/A.txt']);
    Ystruct = importdata([datapath '/IOT_' num2str(year) '_ixi/Y.txt']);
    x_full = inv(eye(7987)-Astruct.data)*sum(Ystruct.data,2);
    Z = Astruct.data.*repmat(x_full',7987,1);
    Z = bigEXIOconc'*Z*bigEXIOconc;
    ytemp = bigEXIOconc'*Ystruct.data;
    for a = 1:49
        Z(a*161-161+20,a*161-161+20)=0;
        Z(a*161-161+21,a*161-161+21)=0;
        Z(a*161-161+22,a*161-161+22)=0;
        Z(a*161-161+23,a*161-161+23)=0;
    end
    x = sum(Z,2)+sum(ytemp,2);
    x(x==0) = 0.000000001;
    A = Z./repmat(x',7889,1);
    L = inv(eye(7889)-A);    
        for nation = 1:49            
            Y = sum(ytemp(:,nation*7-6:nation*7),2);
            F = NRG_PRIM_EiE(1,:,year-1994);
            e = F./(x'); % energy intensity coefficient vector 
            Foot = diag(e)*L*diag(Y);
            EROI_EiE_all = EROIcalc2(Z,e,Y,x,Foot,year,mask,nation); 
            for fuelno = 1:4 %4 
                temp3 = 0;
                for nation2 = 1:49
                    temp2 = sum(sum(EROI_EiE_all((nation2*161)-161+fuellookup(1,fuelno):(nation2*161)-161+fuellookup(2,fuelno),:)));     
                    temp3 = temp3+temp2;    
                end
                EiE(nation,year-1994,fuelno) = EiE(nation,year-1994,fuelno) + temp3;
                ET(nation,year-1994,fuelno) = sum(NRG_PRIM(fuelno,nation*161-160:nation*161,year-1994));
                EdE(nation,year-1994,fuelno) = -1*sum(EIOU_PRIM(fuelno,nation*161-160:nation*161,year-1994),2);
                E_out = ET(nation,year-1994,fuelno) - EdE(nation,year-1994,fuelno);
                E_in = EdE(nation,year-1994,fuelno) + EiE(nation,year-1994,fuelno);
                EROI_PRIM_result(nation,year-1994,fuelno) = E_out/E_in;               
            end
        end   
end

disp(['  all done=' num2str(toc(tStart)/60) 'm'])

save('EROI_PRIM_result.mat','EROI_PRIM_result');
save('ET.mat','ET');
save('EdE.mat','EdE');
save('EiE.mat','EiE');
