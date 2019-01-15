% Anne Owen and Lina Brand Correa 2018
% Run this code first to make the Primary energy extension vector

%% Stage 1 - load the IEA data
tStart = tic;

proddata = xlsread('1_PRIM_169_countries_1995-2013 prod energy_25_10_17','1.0_IEA_prod_data','E6:W11328');
total_conc = xlsread('1_PRIM_169_countries_1995-2013 prod energy_25_10_17.xlsx','1.1_Conc_Prod_COG_Total','C2:BQ162');
coal_conc = xlsread('1_PRIM_169_countries_1995-2013 prod energy_25_10_17.xlsx','1.2_ConcCoal','C2:BQ162');
oil_conc = xlsread('1_PRIM_169_countries_1995-2013 prod energy_25_10_17.xlsx','1.3_ConcOil','C2:BQ162');
gas_conc = xlsread('1_PRIM_169_countries_1995-2013 prod energy_25_10_17.xlsx','1.4_ConcGas','C2:BQ162');
c_conc = xlsread('2_PRIM_146IEA_to_49EXIOBASE_countries_25_10_17.xlsx','2.2_CountryConcordance','C2:FO50');
EIOUdata = xlsread('3_PRIM_1995-2013_EIOU_COG_25_10_17.xlsx','3.1 IEA EIOU data','E6:W3216');
EIOUconc = xlsread('3_PRIM_1995-2013_EIOU_COG_25_10_17.xlsx','3.2 IEA_ mapping','C8:U168');
gaspercent = xlsread('3_PRIM_1995-2013_EIOU_COG_02_08_18.xlsx','3.3 %gas splits by country','B6:R174');
NGLpercent = xlsread('3_PRIM_1995-2013_EIOU_COG_02_08_18.xlsx','3.3 %NGL splits by country','B6:R174');
OILpercent = ones(169,17)-gaspercent-NGLpercent;
disp(['  Step 1. Elapsed=' num2str(toc(tStart)/60) 'm'])  

%% Stage 3 - make the big concordances
EXIO_reg = 49;
IEA_reg = 169;
proddata(isnan(proddata)) = 0;
total_conc_big = zeros(169*67,161*49);
coal_conc_big = zeros(169*67,161*49);
oil_conc_big = zeros(169*67,161*49);
gas_conc_big = zeros(169*67,161*49);
for i = 1:IEA_reg
     for e = 1:EXIO_reg
         if c_conc(e,i) == 1
             total_conc_big(i*67-66:i*67,e*161-160:e*161) = total_conc';
             coal_conc_big(i*67-66:i*67,e*161-160:e*161) = coal_conc';
             oil_conc_big(i*67-66:i*67,e*161-160:e*161) = oil_conc';
             gas_conc_big(i*67-66:i*67,e*161-160:e*161) = gas_conc';
             else
         end
     end
end
disp(['  Step 3. Elapsed=' num2str(toc(tStart)/60) 'm'])
%% Step 4: make the energy extension vector
NRG_PRIM = zeros(4,7889,19);
for a = 1:19
    NRG_PRIM(1,:,a) = proddata(:,a)'*total_conc_big;
    NRG_PRIM(2,:,a) = proddata(:,a)'*coal_conc_big;
    NRG_PRIM(3,:,a) = proddata(:,a)'*oil_conc_big;
    NRG_PRIM(4,:,a) = proddata(:,a)'*gas_conc_big;      
end
disp(['  Step 4. Elapsed=' num2str(toc(tStart)/60) 'm']) 
%% Stage 5 - make the EIOU concordance
EIOUdata(isnan(EIOUdata)) = 0;
EIOUtotal_conc_big = zeros(169*19,49*161,17);
EIOUcoal_conc_big = zeros(169*19,49*161);
EIOUoil_conc_big = zeros(169*19,49*161);
EIOUgas_conc_big = zeros(169*19,49*161);

for a = 1:17
    for i = 1:IEA_reg
        for e = 1:EXIO_reg
            if c_conc(e,i) == 1
                 EIOUweightconc = EIOUconc;
                 EIOUweightconc(21,3) = OILpercent(i,a);
                 EIOUweightconc(22,3) = gaspercent(i,a);
                 EIOUweightconc(23,3) = NGLpercent(i,a);
                 EIOUtotal_conc_big(i*19-18:i*19,e*161-160:e*161,a) = EIOUweightconc';   
            else
            end
        end
     end
end
disp(['  Step 5. Elapsed=' num2str(toc(tStart)/60) 'm'])
%% Stage 6 - make the EIOU data
EIOU_PRIM = zeros(4,7889,17);
for a = 1:17
    EIOU_PRIM(1,:,a) = EIOUdata(:,a)'*EIOUtotal_conc_big(:,:,a);
end
for a = 1:17
    for b = 1:49
        EIOU_PRIM(2,b*161-161+20,a) = EIOU_PRIM(1,b*161-161+20,a);
        EIOU_PRIM(3,b*161-161+21,a) = EIOU_PRIM(1,b*161-161+21,a);
        EIOU_PRIM(4,b*161-161+22:b*161-161+23,a) = EIOU_PRIM(1,b*161-161+22:b*161-161+23,a);
    end
end
disp(['  Step 6. Elapsed=' num2str(toc(tStart)/60) 'm'])

 %% Stage 7 - save the data
 save('EIOU_PRIM.mat','EIOU_PRIM')
 save('NRG_PRIM.mat','NRG_PRIM')