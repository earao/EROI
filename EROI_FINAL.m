% Anne Owen and Lina Brand Correa 2018
% Run this code second to calculate Final Energy EROI

%% Step 1 make the masks
load EIOU_FIN.mat
load NRG_FIN.mat

tStart = tic;
col = 20; % position of coal sector
oil = 21; % position of oil sector
gas1 = 22; gas2 = 23; % position of gas sector
cok = 56; % position of coke sector
pet = 57; % position of petroleum sector
ele = 96; % position of electricity sector
all = {col,oil,gas1,gas2,cok,ele};
mask = ones(7889,161);

for a = 1:49
    for b = 1:6
        for c = 1:6
            mask(:,all{c}) = zeros(7889,1); %all fuels
        end
    end
end

%% Step 2 make Ei by calling function
datapath = 'O:/UKERC/EXIOBASE V3.4'; 
EXIOconc = xlsread('1_FIN_170_countries_TFCdata_25_10_17','1.4_EXIO_elec_squash','C3:FG165');
bigEXIOconc = zeros(49*163,49*161);
for a = 1:49
     bigEXIOconc(a*163-162:a*163,a*161-160:a*161) = EXIOconc;
end
EiE_f = zeros(49,19);
ET_f = zeros(49,19);
EdE_f = zeros(49,19);
EROI_EiE_f_all = zeros(7889,7889);
EROI_FIN_result = zeros(49,19);
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
        Z(a*161-161+56,a*161-161+56)=0;
        Z(a*161-161+57,a*161-161+57)=0;
        Z(a*161-161+96,a*161-161+96)=0;
    end
    x = sum(Z,2)+sum(ytemp,2);
    x(x==0) = 0.000000001;
    A = Z./repmat(x',7889,1);
    L = inv(eye(7889)-A); 
    for nation = 1:49            
        Y = sum(ytemp(:,nation*7-6:nation*7),2);
        F = NRG_FIN(1,:,year-1994);
        e = F./(x'); % energy intensity coefficient vector 
        Foot = diag(e)*L*diag(Y);
        EROI_EiE_f_all = EROIcalc2(Z,e,Y,x,Foot,year,mask,nation);
        temp3 = 0;
        for fuelno = 1:6
            for nation2 = 1:49
                temp2 = sum(sum(EROI_EiE_f_all((nation2*161)-161+all{fuelno},:)));     
                temp3 = temp3+temp2;
            end
            EiE_f(nation,year-1994) = EiE_f(nation,year-1994) + temp3;
            temp3=0;
        end
        ET_f(nation,year-1994) = sum(F(:,nation*161-160:nation*161));
        EdE_f(nation,year-1994) = -1*EIOU_FIN(nation,year-1994);
        E_out = ET_f(nation,year-1994);
        E_in = EdE_f(nation,year-1994) + EiE_f(nation,year-1994);
        EROI_FIN_result(nation,year-1994) = E_out/E_in;
    end
end

save('EROI_FIN_result.mat','EROI_FIN_result');
save('ET_f.mat','ET_f');
save('EdE_f.mat','EdE_f');
save('EiE_f.mat','EiE_f');

disp(['  all done=' num2str(toc(tStart)/60) 'm'])
