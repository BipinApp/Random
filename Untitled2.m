load('S2A-SDSUNiger11310172018129.mat')
original = transpose(refdata);
original(61,:) = [];

load('S2A-Niger11310172018050.mat')
new = transpose(refdata);
new(61,:) = [];

[x,y,z] = ranksum(new(:,3),original(:,3))

% calculating the difference between the two ROI
per = ((original(:,1:13) - new(:,1:13))./original(:,1:13)) *100;

figure 
plot(original(:,21),original(:,5),'LineStyle','None','Marker','o');
hold on
plot(new(:,21),new(:,5),'LineStyle','None','Marker','*');

figure 
plot(original(:,21),per(:,2),'LineStyle','None','Marker','o')
