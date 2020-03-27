%calculates stats and makes plot for Al2011T3,
%then puts them in an excel file.

data = load('Al2011T3_wodups.csv');%aluminum
%disp(pdata(1,1:6));
%0.1350 1.9553 0 NaN 0.0787 9.7619
%savefile = 'PVC_wodups2.csv';%.xlsx vs .csv
%save(savefile,'-ascii','pdata');

%disp(adata(1,1:6));
%0.8950 0 0 -0.0000 1.8995 0
%plot(adata(:,3),adata(:,2));%position vs load
%plot(adata(:,2));%plots load vs sample #
%x = 106, 1203, 1663, 5765
%1785 instead of 1663 chops off the peak.
% (I sometimes exclude 1 pt just to be sure..)  
indx1 = [106:1203];
indx2 = [1785:5765];
indx = [indx1,indx2];
good_data = data(indx,:);
%plot(good_adata(:,3),good_adata(:,2));

d = 0.505; %diameter of sample, had better be in inches.
r = d/2;
strain = good_data(:,3)-good_data(1,3);%ends w/ 0.4356
stress = good_data(:,2)/(pi*(r^2));%ends w/ 4.3666
strain2 = strain(:,1);%for 0.002
strain2 = strain2(:,1)+0.002;
%strain2 is inputs for 0.2% yield strength.

Mod_rupture = trapz(strain,stress)
%integral under curve: 2.0517e+04
%modulus of rupture=area beneath curve up to pt of rupture
UTS = max(stress);%5.4503e+04

fit = polyfit(strain(400:620,1),stress(400:620,1),1);
fit2 = polyfit(strain2(400:620,1),stress(400:620,1),1);

% makes a line of best fit w/ x_line & y_line
y_line2 = polyval(fit2, strain);                     
x_int = interp1((y_line2-stress), strain, 0); 
y_int = polyval(fit2,x_int);
%(x_int & y_int are yield strength coordinates)
yield_strength = y_int;

[row, col] = find(stress == UTS);
[row2, col2] = find(strain >= x_int,1);%why isn't it found?
[row3, col3] = find(stress >= y_int,1);%why isn't it found?
%(x_int,y_int) is between strain(676) & strain(677) 

est1 = trapz(strain(1:676,1),stress(1:676,1));%1.0852e+03
est2 = trapz(strain(1:677,1),stress(1:677,1));%1.0887e+03
Mod_resilience = (est1+est2)/2;%1.0870e+03
disp([est1,est2,Mod_resilience])
%1.0e+03 * [1.0852, 1.0887,1.0870]
%for Modulus of resilence, we average
% the areas under the curves using the points
%to the left & right of the yield strength.

plot(strain,stress);%aluminum stress vs strain
hold on
title("Al2011T3 Engineering Stress/Strain Curve");
xlabel("Strain in./in.");
ylabel("Stress lbf/in^2");
%plot(strain(400),stress(400),'r*');
%plot(strain(620),stress(620),'r*');
%653 vs 677
%plot(strain(677),stress(677),'r*');
%plot(strain(676),stress(676),'r*');

t1 = linspace(strain(400),strain(620));
%plot(t1, polyval(fit, t1)); 
t2 = linspace(strain2(1),strain2(800));
plot(t2, polyval(fit2,t2));

plot(strain(row),UTS,'r*');
plot(x_int,y_int,'r+')
legend({'Stress-Strain Curve','0.2% Line with Slope as Elastic Modulus','Ultimate Tensile Strength','Yield Strength'},'Location','southeast')

hold off
disp(fit)%y = 1.0e+05 * (9.4935x-0.0888)
elastic_mod = fit(1);
%he took 3-4 for the linear region. ours is abt 2.5-4
%1.0e+05*9.4935 is the Young's Modulus for our sample
%he said you can use polyfit to find how good our estimation is.

pie = 3.1416;
initL = 2.076;%length
finL = 2.42;
pchange = abs(initL-finL)/initL*100
%elongation at failure
%reduction in area is cross sectional area

initA = pie*(r^2)%3.6942
fr = 0.38/2;%final radius
finA = pie*(fr^2)%3.1158
redA = (1-finA/initA)*100%43.3781
%book value makes no sense to me.
%redA = abs(initA-finA)/initA*100%43.3781

%disp(row2)
%disp(row3)
%disp(x_int);%0.0563
%disp([est1,est2,Mod_resilience])
%1.0e+03 * [1.0852, 1.0887,1.0870]
disp(elastic_mod)%9.4935e+05
disp(y_int);%4.2670e+04

table = ["Names","Elastic Modulus","Modulus of Rupture","Modulus of Resilience",...
    "0.2% Offset Yield Strength","Ultimate Tensile Strength",...
    "Percent Elongation at Failure", "Percent Reduction in Cross-Sectional Area";...
    "Numbers",elastic_mod,Mod_rupture,Mod_resilience,yield_strength,...
    UTS,pchange,redA;"Units","lbf/in^2","psi","psi","lbf/in^2","lbf/in^2","N/A","N/A"];
writematrix(table,'Al2011T3_table.xlsx');


