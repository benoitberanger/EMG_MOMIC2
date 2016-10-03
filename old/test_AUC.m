close all
clear all
clc

X = 2*pi:0.01:4*pi;
Y = (sawtooth(X,0.5)+1)/2;
X = X/(2*pi);

figure
plot(X,Y) % check if the curved we build is correct

AUC = trapz(X,Y) % area under the curve
