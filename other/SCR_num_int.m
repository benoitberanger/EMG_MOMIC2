%% Generate data

%=== Sine curve
dx = 0.1;  % Step size
x = 0:dx:2*pi;
y = sin(x);

%=== Add noise (Gaussian)
noise_level = 0.2;
y_noisy = y + noise_level*randn(size(y));


%=== Smooth data
% --> you can change the degree of smoothing
smoothing_degree = 3;
y_smooth = smooth(y_noisy,smoothing_degree);

%=== Integrate data
q_raw    = trapz(x,y);
q_noisy  = trapz(x,y_noisy);
q_smooth = trapz(x,y_smooth);

q_all = [q_raw q_noisy q_smooth];

%=== Plot raw vs noisy data
figure
set(gcf,'color','w')
set(gcf,'Position',[100 100 800 400])
subplot(1,3,1)
hold on
plot(x,y,'b')
plot(x,y_noisy,'r')
hold off
title('raw vs noisy data')

subplot(1,3,2)
hold on
plot(x,y_noisy,'b')
plot(x,y_smooth,'r')
hold off
title('noisy vs smooth data')

subplot(1,3,3)
bar(q_all)
set(gca,'xticklabel',{'raw','noisy','smooth'})
title('Comparision of integrated intensity')
