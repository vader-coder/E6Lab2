%*************************************************************************
%   Script:        remove_dups for Al2011T3
%   DESCRIPTION:   This script removes lines with duplicated value of 
%                  position. Replaces duplicates with median 
%                 
%   COURSE:        ENGR 6 - Mechanics
%   AUTHOR:        Allan R. Moser    
%   DATE CREATED:  14-Feb-2020
%   LAST CHANGED:  14-Feb-2020
%**************************************************************************
clear
%original file columns are:
%Time Load(lb) Position(in) AxialStrain Transverse Auxiliary Control Stress
%new .csv file columns correspond to:
%0 Time Load(lb) Position(in) AxialStrain Control Stress
%what is the unit of time? seconds?
% Substitute the filename you wish to read in the following line
[data,text] = xlsread('Al2011T3_Mon1_Late.xlsx'); 
[nrows,ncols] = size(data);
ixpos = 3;
itemp = 1;                     % Initialize temporary array index
temp(itemp,:) = data(1,:);     % Load line into temporary array
indx = 0;                      % Initialize output index
oldx = data(1,ixpos);          % Record last value of x
for i = 2:nrows
    if (data(i,ixpos) ~= oldx);  % x-value changed
        indx = indx + 1;         % increment output record counter
        % Output the record for entrys before x changed
        for j = 1:ncols % must loop in case there is only 1 row in temp
            outdata(indx,j) = median(temp(:,j));
%           outdata(indx,j) = mean(temp(:,j));
        end
        temp = [];                  % Make temp array zero length
        itemp = 1;                  % Initialize temporary array index      
        temp(itemp,:) = data(i,:);  % Load line into temporary array
        oldx = data(i,ixpos);       % Store the new value
    else                  % x-value unchanged
        itemp = itemp+1;  % increment temporary array counter
        temp(itemp,:) = data(i,:);
    end
end
% Process the last line
indx = indx + 1;
for j = 1:ncols  
    outdata(indx,j) = median(temp(:,j));
%   outdata(indx,j) = mean(temp(:,j));
end

% Save columns: Time,Load,Position,AxialStrain,ControlOut,Stress
% Eliminate: TransverseStrain and Auxiliary (since these are NaN
pdata = outdata(:,[1:4,7:8]);
savefile = 'Al2011T3_wodups.csv';%.xlsx vs .csv
save(savefile,'-ascii','pdata');
pdata = load('Al2011T3_wodups.csv');
% You can read the data into Matlab using the statement:
% pdata = load('Alum2011_Feb_14_2020_nodups.csv');
% Or, you can open the file in Excel