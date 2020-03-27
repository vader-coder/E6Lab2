%*************************************************************************
%   Script:        remove_dups for PVC
%   DESCRIPTION:   This script removes lines with duplicated value of 
%                  position. Replaces duplicates with median 
%                 
%   COURSE:        ENGR 6 - Mechanics
%   AUTHOR:        Allan R. Moser    
%   DATE CREATED:  14-Feb-2020
%   LAST CHANGED:  14-Feb-2020
%**************************************************************************
clear

% Substitute the filename you wish to read in the following line
[data,text] = xlsread('PVC_Mon1_Late.xlsx'); 
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
%why is it only saving Time, Load, Position, ControlOut, & Stress??
% Eliminate: TransverseStrain and Auxiliary (since these are NaN
pdata = outdata(:,[1:4,7:8]);
savefile = 'PVC_wodups.csv';
save(savefile,'-ascii','pdata')
% You can read the data into Matlab using the statement:
% pdata = load('Alum2011_Feb_14_2020_nodups.csv');
% Or, you can open the file in Excel