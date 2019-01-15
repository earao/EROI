% Anne Owen and Lina Brand Correa 2018
% Run this code first to make the Final energy extension vector

%% Stage 1 - load the IEA data
tStart = tic;

tempTFCdata = xlsread('1_FIN_170_countries_TFCdata_25_10_17','1.0_IEA_TFC_data','E6:X11395');
conc = xlsread('1_FIN_170_countries_TFCdata_25_10_17.xlsx','1.2_Conc_TFC_COG_Total','C2:BR162');
elect_share = xlsread('1_FIN_170_countries_TFCdata_25_10_17.xlsx','1.3_FF share of elect gen','D5:W174');
c_conc = xlsread('2_FIN_147IEA_to_49EXIOBASE_countries_25_10_17.xlsx','2.2_CountryConcordance','C2:FP50');
EIOUdata = xlsread('3_FIN_1995-2014_EIOU_COG_25_10_17.xlsx','3.1_IEA_EIOU data','E6:X3235');
EIOUconc = xlsread('3_FIN_1995-2014_EIOU_COG_25_10_17.xlsx','3.2_IEA mapping','C20:U20');
elect_share2 = xlsread('3_FIN_1995-2014_EIOU_COG_25_10_17.xlsx','3.3_FF share of elect gen','D5:W174');

disp(['  Step 1. Elapsed=' num2str(toc(tStart)/60) 'm'])  
%% Stage 3 expand the TFC for two elec
EXIO_reg = 49;
IEA_reg = 170;
expandconc_big = zeros(IEA_reg*68,IEA_reg*67);
expandconc = zeros(68,67);
expandconc(1:64,1:64) = eye(64);
expandconc(65:65,65:64) = 1;
expandconc(66:68,65:67) = eye(3);
elect_share(isnan(elect_share)) = 0;
tempTFCdata(isnan(tempTFCdata)) = 0;
for year = 1995:2014 
    for i = 1:IEA_reg
        expandconc_big(i*68-67:i*68,i*67-66:i*67)=expandconc;
        expandconc_big(i*68-4,i*67-3) = elect_share(i,year-1994);
        expandconc_big(i*68-3,i*67-3) = 1-elect_share(i,year-1994);
    end
    TFCdata(:,year-1994) = expandconc_big*tempTFCdata(:,year-1994);
end
disp(['  Step 3. Elapsed=' num2str(toc(tStart)/60) 'm']) 
%% Stage 4 - make the big concordances

conc_big = zeros(170*68,161*49);
for i = 1:IEA_reg
     for e = 1:EXIO_reg
         if c_conc(e,i) == 1
             conc_big(i*68-67:i*68,e*161-160:e*161) = conc';
             else
         end
     end
end
disp(['  Step 4. Elapsed=' num2str(toc(tStart)/60) 'm'])
%% Step 5: make the energy extension vector
NRG_FIN = zeros(1,7889,20);
for a = 1:20
    NRG_FIN(1,:,a) = TFCdata(:,a)'*conc_big;      
end
disp(['  Step 5. Elapsed=' num2str(toc(tStart)/60) 'm']) 
%% Stage 6 - make the EIOU concordance
EIOUdata(isnan(EIOUdata)) = 0;
elect_share(isnan(elect_share)) = 0;
EIOU_conc_big = zeros(170*19,49,20);

for year = 1995:2014
    for i = 1:IEA_reg
         for e = 1:EXIO_reg
             if c_conc(e,i) == 1
                 EIOU_conc_big(i*19-18:i*19,e,year-1994) = EIOUconc;
                 EIOU_conc_big(i*19-5,e,year-1994) = elect_share(i,year-1994);
             else
             end
         end
    end
end
disp(['  Step 6. Elapsed=' num2str(toc(tStart)/60) 'm'])
%% Stage 7 - make the EIOU data
EIOU_FIN = zeros(49,20);

for a = 1:20
    EIOU_FIN(:,a) = EIOU_conc_big(:,:,a)'*EIOUdata(:,a);
end
disp(['  Step 7. Elapsed=' num2str(toc(tStart)/60) 'm'])

 %% Stage 8 - save the data
 save('EIOU_FIN.mat','EIOU_FIN')
 save('NRG_FIN.mat','NRG_FIN')