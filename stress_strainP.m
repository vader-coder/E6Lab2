%calculates stats and makes plot for PVC,
%then puts them in an excel file.

clear
clc
close all
data = load('PVC_wodups.csv');%plastic

%plot(data(:,3),data(:,2));%position vs load
%plot(data(:,2));%plots load vs sample #

good_data = data(1:9350,:);
%plot(good_data(:,3),good_data(:,2));
%hold on
%plot(good_data(9350,3),good_data(9350,2),'r*');
%hold off
%data looks good to me; I'm not sure how to tell if it's clean enough or
%not.
d = 0.5100; %diameter of sample, had better be in inches.
r = d/2;
strain = good_data(:,3)-good_data(1,3);
stress = good_data(:,2)/(pi*(r^2));
strain2 = strain(:,1);%for 0.002
strain2 = strain2(:,1)+0.002;
%strain2 is inputs for 0.2% yield strength.

Mod_rupture = trapz(strain,stress)
%integral under curve: 5.8404e+03
%when we stop at 9350: 5.6948e+03
UTS = max(stress);%5.4503e+04

%modulus of rupture=area beneath curve up to pt of rupture
fit = polyfit(strain(200:400,1),stress(200:400,1),1);
fit2 = polyfit(strain(400:620,1),stress(400:620,1),1);
fit3 = polyfit(strain(200:500,1),stress(200:500,1),1);
fit4 = polyfit(strain(200:620,1),stress(200:620,1),1);
elastic_mod = fit3(1);

fit5 = polyfit(strain2(200:500,1),stress(200:500,1),1);
fit6 = polyfit(strain(590:591,1),stress(590:591,1),1);
% makes a line of best fit w/ x_line & y_line
y_line2 = polyval(fit5, strain);                     
x_int = interp1((y_line2-stress), strain, 0); 
y_int = polyval(fit5,x_int);%looks wrong.
%(x_int & y_int are yield strength coordinates)
yield_strength = y_int;
y_line2 = polyval(fit6, strain);                     
%x_int = interp1((y_line2-stress), strain, 0); 
%y_int = polyval(fit6,x_int);%looks wrong

[row, column] = find(stress == UTS);
[row2, col2] = find(strain >= x_int,1);
[row3, col3] = find(stress >= y_int,1);

%disp(fit)%1.0e+05*[1.0388 -0.0028]
%disp(fit2)%1.0e+04*[9.0031 0.0303]
disp(fit3)%1.0e+05*[1.0182 -0.0022]
%disp(fit4)%1.0e+04*[9.7546 -0.0088]
%fit3 should be most accurate, since it
%avoids the curvier 500-620 range and uses
%more data then fit1

est1 = trapz(strain(1:590,1),stress(1:590,1));%1.0852e+03
est2 = trapz(strain(1:591,1),stress(1:591,1));%1.0887e+03
Mod_resilience = (est1+est2)/2;%1.0870e+03

plot(strain,stress);%plastic stress vs strain
hold on
title("PVC Engineering Stress/Strain Curve");
xlabel("Strain in./in.");
ylabel("Stress lbf/in^2");
%plot(strain(200),stress(200),'r*');
%plot(strain(400),stress(400),'r*');
%plot(strain(500),stress(500),'r*');
%plot(strain(620),stress(620),'r*');
%plot(strain(9350),stress(9350),'r*');
t1 = linspace(strain(200),strain(500));
%plot(t1, polyval(fit3, t1)); 
t2 = linspace(strain2(1),strain2(800));
plot(t2, polyval(fit5,t2));
%true crossover point ends up being between
%0.06018152 & 0.0618153 on x-axis
%5704.00814 & 5704.00812 on the y axis
%can say yield strength = 5704.0081 lbf/in^2

plot(strain(row),UTS,'r*');
plot(x_int,y_int,'r+');%5.7366e+03 = y_int
%yield strength ends up as 5.704e+03
legend({'Stress-Strain Curve','0.2% Line with Slope as Elastic Modulus','Ultimate Tensile Strength','Yield Strength'},'Location','southeast')
yield_strength = 5704.0081;%greatest degree of precision?
%plot(strain(row2),stress(row2),'r*');
%plot(strain(row2-1),stress(row2-1),'r*');
%plot(strain(590),stress(590),'r*');
%plot(strain(591),stress(591),'r*');
%plot(strain(585),stress(585),'r*');
%plot(strain(586),stress(586),'r*');

hold off
disp(row);
disp(UTS);
disp(stress(926));

pie = 3.1416;
initL = 2.037;
finL = 2.892;
pchange = abs(initL-finL)/initL*100
%reduction in area is cross sectional area
initA = pie*(r^2);%3.6942
fr = 0.38/2;%final radius
finA = pie*(fr^2);%3.1158
redA = (1-finA/initA)*100%43.3781
%book value makes no sense to me.
redA = abs(initA-finA)/initA*100%43.3781

disp([row2,row3])
disp([strain(590),stress(591)])
%1.0e+03 *[0.0001    5.7060]

disp([est1,est2,Mod_resilience])

table = ["Names","Elastic Modulus","Modulus of Rupture","Modulus of Resilience",...
    "0.2% Offset Yield Strength","Ultimate Tensile Strength",...
    "Percent Elongation at Failure", "Percent Reduction in Cross-Sectional Area";...
    "Numbers",elastic_mod,Mod_rupture,Mod_resilience,yield_strength,...
    UTS,pchange,redA;"Units","lbf/in^2","psi","psi","lbf/in^2","lbf/in^2","N/A","N/A"];
writematrix(table,'PVC_table.xlsx');