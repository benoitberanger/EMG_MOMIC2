function EMGmomic(e,c)

% function EMGmomic(e,c)
% e= num�ro d'essai, c= la taille du curseur
% to process force data relative to EMG data (intr+extr) from labview program
% Le curseur ne change pas de taille pendant le run, donc pas de gel d'�cran. Il apparait 
% dans la d�nomination du fichier. Les perturbations TMS sont � retirer du traitement. 
% Elles apparaissent en moyenne toutes les 4 secondes (intervalle non fixe) et sont indiqu�es par un 1.
% Il n'y a qu'un seul pattern de courbe. Les erreurs ne sont � traiter que par rapport � c.

% f�vrier 2004


%%%% 1. PREPARATION FICHIER

% 350 (d�calage position curseur au centre de l'�cran/enregistrement
% courbe � la fin de l'�cran) = 7000
decal=0;
d=0; % first point interesting in Pattern

Err1T=[]; % tableau pour stocker les erreurs, ligne=taille curseur
Err2T=[]; % colonnes = pattern number
FMoyT=[];


% structure du fichier
keyword='P';
subjectnb=c; % 
essainumb={'mainD' 'mainG' 'mains'};

ext='.mat';

filedata=[keyword char(c) char(essainumb(e)) ext];  % nom du fichier ou sont stockees les donnees d'un sujet pour l'essai e
data=load(filedata);

% attention �chantillonnage � 5000 Hz. On enl�ve 20s � la fin pour �viter les chutes de signal en fin de tache.
FDIdt=data.values(:,1);
ECRdt=data.values(:,2);
FCRdt=data.values(:,3);
FDIgc=data.values(:,4);
ECRgc=data.values(:,5);
FCRgc=data.values(:,6);

% FDS=data(decal+1:end,6); ne sont pas dans les fichiers
% ED=data(decal+1:end,7);

% colonne des stimulations calqu�e sur la force du sujet. D�s que le sujet atteint
% la valeur 5 N, le cateley d�clenche la stimulation.
temps=[1:length(data)]; % �chelle temporelle en cons�quence.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pretraitements signal
% ----------------------

% PAs besoin du d�coupage pour enlever 500 ms puisqu'on trvaille sur la cor�lation signal de force/EMG qui tous les deux
% sont influenc�s par la perturbation TMS
%%%% 2. DECOUPAGE : enlever 500ms apr�s la stimulation (donc 1000 points).

% Notre fa�on. Attention pour cet �chantillonnage, pour les stims, il peut y avoir plusieurs 1 de suite.
% ------------
% cutting=1000;
% ValStim=find(data(:,1)==1); % toutes les valeurs des indices o� il y a eu stim
% nbreStim=length(ValStim);
% datacut=[];
% datacut=[Stim,FConsigne,FSujet,OP,FDI];
% size(datacut)
% for i=nbreStim:-1:1
%     datacut(ValStim(i):ValStim(i)+cutting-1,:)=[];
% end
% 
% who% 

% Fa�on Fred Chavane
% ------------------
% cutting=1000;
% datacut=[];
% datacut=[Stim,FConsigne,FSujet,OP,FDI];
% ValStim=find(datacut(:,1)==[0 1]); % toutes les valeurs des indices o� il y a eu stim
% 
% ValStim2(1)=ValStim(1);
% ii=1;
% for i=2:length(ValStim)
%     buffer=ValStim(i);
%     if buffer<>ValStim2(i-1)-1
%         ii=ii+1;
%         ValStim2(ii)=ValStim(i);
%     end
% end
% 
% nbreStim=length(ValStim);
% size(datacut)
% for i=nbreStim:-1:1
%     datacut(ValStim(i):ValStim(i)+cutting-1,:)=zeros(cutting,5);
% end
% ValStim2(1)=ValStim(1);
% ii=1;
% for i=2:length(ValStim)
%     buffer=ValStim(i);
%     if buffer<>ValStim2(i-1)-1
%         ii=ii+1;
%         ValStim2(ii)=ValStim(i);
%     end
% end



%%%% 2.BIS : DECOUPAGE : ne prendre en compte que l'�chantillon de 2s avant la perturbation et apr�s pour voir
% A. L'�tat de la corr�lation muscles/production de force juste avant la perturbation et les MEP
% B. L'�tat de la corr�lation muscles/production de force juste apr�s la perturbation. 
% Pas fait.

%%%% VERIFICATION DERIVE

DriftFDIdt=mean(FDIdt);
DriftFDIgc=mean(FDIgc);

DriftFCRdt=mean(FCRdt);
DriftFCRgc=mean(FCRgc);

DriftECRdt=mean(ECRdt);
DriftECRgc=mean(ECRgc);

% Correction du biais : 

FDIdt_c=FDIdt-DriftFDIdt;
FDIgc_c=FDIgc-DriftFDIgc;

FCRdt_c=FCRdt-DriftFCRdt;
FCRgc_c=FCRgc-DriftFCRgc;

ECRdt_c=ECRdt-DriftECRdt;
ECRgc_c=ECRgc-DriftECRgc;

%%%% RECTIFICATION EMG 

FDIdt_cr=abs(FDIdt_c);
FDIgc_cr=abs(FDIgc_c);

FCRdt_cr=abs(FCRdt_c);
FCRgc_cr=abs(FCRgc_c);

ECRdt_cr=abs(ECRdt_c);
ECRgc_cr=abs(ECRgc_c);

%%%% FILTRAGE 

% on utilise un low pass filter � 6Hz de cutt off et de second ordre

% la frequence de coupure du filtre butterworth Matlab est normalis�e par rapport � la fr�quence max
% des donn�es (par rapport � la fr�quence d'�chantillonnage des donn�es brutes, on prend la fr�quence 
% de Nynquist (1/2*freq ech). Ici, freq ech=2000Hz. Donc freq max = 1000Hz.) et doit se situer entre
% 0 et 1 (On vaut avoir une cuttoff � 6 Hz. Donc ici, cuttoff = 0.006).

[b1,a1]=butter(2,0.006); % on prend un ordre 2 et une fr�quence de coupure � 6Hz.

yFDIdt_cr=filtfilt(b1,a1,FDIdt_cr);
yFDIgc_cr=filtfilt(b1,a1,FDIgc_cr);

yFCRdt_cr=filtfilt(b1,a1,FCRdt_cr);
yFCRgc_cr=filtfilt(b1,a1,FCRgc_cr);

yECRdt_cr=filtfilt(b1,a1,ECRdt_cr);
yECRgc_cr=filtfilt(b1,a1,ECRgc_cr);

% filtre production force sujet 10 Hz (ordre 1)


% [b2,a2]=butter(1,10/1000);
% yFSujet=filtfilt(b2,a2,FSujet);

%%%% NORMALISATION : Calcul de la correction du gain pour "normaliser" les deux EMG. 


size(yFDIdt_cr);
size(FDIdt_cr);
yFDIdt_moy=mean(yFDIdt_cr);
yFDIgc_moy=mean(yFDIgc_cr);
F1_FDI=yFDIgc_moy/yFDIdt_moy;
F2_FDI=yFDIdt_moy/yFDIgc_moy;

size(yFCRdt_cr);
size(FCRdt_cr);
yFCRdt_moy=mean(yFCRdt_cr);
yFCRgc_moy=mean(yFCRgc_cr);
F1_FCR=yFCRgc_moy/yFCRdt_moy;
F2_FCR=yFCRdt_moy/yFCRgc_moy;

size(yECRdt_cr);
size(ECRdt_cr);
yECRdt_moy=mean(yECRdt_cr);
yECRgc_moy=mean(yECRgc_cr);
F1_ECR=yECRgc_moy/yECRdt_moy;
F2_ECR=yECRdt_moy/yECRgc_moy;


% Normalisation pour analyse FFT (sans les enveloppes filtr�es mais avec signal rec, cor)

% FDIdt_n=[];
% FDIgc_n=[];
% 
% if yFDIdt_moy<yFDIgc_moy
%    FDIdt_n=FDIdt_cr*F1;
%    FDIgc_n=FDIgc_cr;
% end
% 
% if yFDIdt_moy>yFDIdt_moy
%      FDIgc_n=FDIgc_cr*F2;
%      FDIdt_n=FDIdt_cr;
% end
% 
% 
% 
% size(FDIdt_n);
% size(FDIgc_n);

% Normalisation pour analyse REG (avec les enveloppes filtr�es)

FDIdt_nReg=[];
FDIgc_nReg=[];

if yFDIdt_moy<yFDIgc_moy
   FDIdt_nReg=yFDIdt_cr*F1_FDI;
   FDIgc_nReg=yFDIgc_cr;
end

if yFDIdt_moy>yFDIgc_moy
     FDIgc_nReg=yFDIgc_cr*F2_FDI;
     FDIdt_nReg=yFDIdt_cr;
end

ECRdt_nReg=[];
ECRgc_nReg=[];

if yECRdt_moy<yECRgc_moy
   ECRdt_nReg=yECRdt_cr*F1_ECR;
   ECRgc_nReg=yECRgc_cr;
end

if yECRdt_moy>yECRgc_moy
     ECRgc_nReg=yECRgc_cr*F2_ECR;
     ECRdt_nReg=yECRdt_cr;
end

FCRdt_nReg=[];
FCRgc_nReg=[];

if yFCRdt_moy<yFCRgc_moy
   FCRdt_nReg=yFCRdt_cr*F1_FCR;
   FCRgc_nReg=yFCRgc_cr;
end

if yFCRdt_moy>yFCRgc_moy
     FCRgc_nReg=yFCRgc_cr*F2_FCR;
     FCRdt_nReg=yFCRdt_cr;
end

temps = [1:length(yFDIdt_cr)];

figure(1)

hold on
plot(temps,yFCRdt_cr,'r')
plot(temps,yFCRgc_cr,'b')
hold off



figure(2)

hold on
plot(temps,FCRdt_nReg,'r')
plot(temps,FCRgc_nReg,'b')
hold off



% figure(2)
% 
% hold on
% plot(temps,OPcr,'r')
% plot(temps,FDIcr,'b')
% plot(temps,FSujet,'m')
% hold off
% 
% figure(3)
% 
% hold on
% plot(temps,yOPcr,'r')
% plot(temps,yFDIcr,'b')
% plot(temps,FSujet,'g')
% plot(temps,yFSujet,'m')
% hold off

%%%% 6. STATISTIQUES
% On veut calculer les corr�lations entre les deux signaux EMG et la force du sujet. 

% [C_FDI,LAGS_FDI]=xcorr(yFDIdt_cr,yFDIgc_cr,'coeff');
% [C_ECR,LAGS_ECR]=xcorr(yECRdt_cr,yECRgc_cr,'coeff');
% [C_FCR, LAGS_FCR]=xcorr(yFCRdt_cr,yFCRgc_cr,'coeff');

[C_FDI,LAGS_FDI]=xcorr(FDIdt_nReg,FDIgc_nReg,'coeff');
[C_ECR,LAGS_ECR]=xcorr(ECRdt_nReg,ECRgc_nReg,'coeff');
[C_FCR, LAGS_FCR]=xcorr(FCRdt_nReg,FCRgc_nReg,'coeff');

 
% % A. Free : tout le signal sans restriction d'intervalle pour le LAG (possibilit� de d�calage de phase pour avoir la meilleure corr�lation
% FreeCorrMaxOP_Force=max(C_OP);
% FreeCorrMaxFDI_Force=max(C_FDI);
% FreeCorrMax2m=max(C_2m);
% 
% 
% [mOP1,iOP1]=max(C_OP);
% [mFDI1,iFDI1]=max(C_FDI);
% [m2m1,i2m1]=max(C_2m);
% 
% mOP1
% mFDI1
% m2m1
% 
% FreeLOP=LAGS_OP(iOP1)
% FreeLFDI=LAGS_FDI(iFDI1)
% FreeL2m=LAGS_2m(i2m1)

% % B. Res : tout le signal restreint pour le LAG afin d'avoir la meilleure corr�lation sans d�calage de phase
% On prend le Lag0 et on regarde la meilleure corr�lation avant et apr�s sur 200 points (100 ms de chaque cot�)

for i=1:length(LAGS_FDI)
    if LAGS_FDI(i)==0
        corrFDI0=C_FDI(i);
        TableCor_FDI=C_FDI(i-200:i+200);
        TableLag_FDI=LAGS_FDI(i-200:i+200);
        ResCorrMaxFDI=max(TableCor_FDI);
    end
end

for i=1:length(LAGS_FCR)
    if LAGS_FCR(i)==0
        corrFCR0=C_FCR(i);
        TableCor_FCR=C_FCR(i-200:i+200);
        TableLag_FCR=LAGS_FCR(i-200:i+200);
        ResCorrMaxFCR=max(TableCor_FCR);
    end
end

for i=1:length(LAGS_ECR)
    if LAGS_ECR(i)==0
        corrECR0=C_ECR(i);
        TableCor_ECR=C_ECR(i-200:i+200);
        TableLag_ECR=LAGS_ECR(i-200:i+200);
        ResCorrMaxECR=max(TableCor_ECR);
    end
end

ResCorrMaxECR
ResCorrMaxFDI
ResCorrMaxFCR

[mECR2,iECR2]=max(TableCor_ECR);
[mFDI2,iFDI2]=max(TableCor_FDI);
[mFCR2,iFCR2]=max(TableCor_FCR);

ResLAGECR=TableLag_ECR(iECR2)
ResLAGFDI=TableLag_FDI(iFDI2)
ResLAGFCR=TableLag_FCR(iFCR2)



% % % C. Int : le signal de pr�cision sans les perturbations (on enl�ve 2s apr�s chaque stim)
% % Etapes pour atteindre ce but : 1. Rep�rer les Stims. 2. Prendre les 4000 points avant (peut etre plus)
% % et regarder
% 
% intervalle=4000
% datacut=[];
% datacut=[Stim,yFSujet,yOPcr,yFDIcr,OPn,FDIn,OPnReg,FDInReg,OPc,FDIc,OPcr,FDIcr];
% 
% ValStim=find(diff(datacut(:,1))== 1)+1;  % toutes les valeurs des indices o� il y a eu stim (on prend seulement en compte le
%                                          % premier 1 quand il y en a deux d'affil�e). Il fait la diff entre la valeur i+1 et i
%                                          % Quand il y a deux 1 d'affil�e, �a lui fait 0. il ne prend en compte que les 1 (1-0)
%                                          % (0-1=-1) et on ajoute +1 car il est mont� d'un indice en soustrayant.
% nbreStim=length(ValStim)
% datacut2{1}= datacut(1:ValStim(1)-1000,:);
% 
% for i=1:nbreStim-1
%     datacut2{i+1} = datacut(ValStim(i)+4000:ValStim(i+1)-1000,:); % on enl�ve 500 ms avant stim
%                                                                   % et 1500ms apr�s
% end
% 
% dataNoStim=[];
% 
% for i=1:nbreStim
%     x=datacut2{i};
% %     [cint_OP,lagsint_OP]=xcorr(x(:,2),x(:,3),'coeff');
% %     [cint_FDI,lagsint_FDI]=xcorr(x(:,2),x(:,4),'coeff');
% %     [cint_2m,lagsint_2m]=xcorr(x(:,3),x(:,4),'coeff');
% %     IntCorrMaxOP=max(cint_OP);
% %     IntCorrMaxFDI=max(cint_FDI);
% %     IntCorrMax2m=max(cint_2m);
% %     [mint_OP1,iint_OP1]=max(cint_OP);
% %     [mint_FDI1,iint_FDI1]=max(cint_FDI);
% %     [mint_2m1,iint_2m1]=max(cint_2m);
% %     IntLOP=lagsint_OP(iint_OP1);
% %     IntLFDI=lagsint_FDI(iint_FDI1);
% %     IntL2m=lagsint_2m(iint_2m1);
% %     Y(i,:)= [IntCorrMaxOP IntCorrMaxFDI IntCorrMax2m IntLOP IntLFDI IntL2m] ;
%       dataNoStim=[dataNoStim;x];
% end
% 
% % bidouille2=size(dataNoStim)
% 
% % size(Y)=15 6
% 
% % figure(4)
% % 
% % hold on
% % plot(LAGS_OP,C_OP,'r')
% % plot(LAGS_FDI,C_FDI,'b')
% % hold off
% 
% %%%% 7. FFT des 2 muscles par rapport � la force
% %%%% 7a. FFT sur le signal brut
% 
% % a. Muscle OP
% 
%     NbEchOPc        =   length(OPc);                              %   give the number of Ech
%     TOPcinitial      =   0;                                        %   P�riode initiale 
%     TOPcfinal		=	((NbEchOPc)/2000);					      %   D�termination de la date finale
%     FechOPc          =   2000;                                     %   Fr�quence d'�chantillonnage des donn�es
%     tOPc			    = 	TOPcinitial : FechOPc : TOPcfinal;
% 
%     yOPc 			= 	fft(OPc);
%     AzeroOPc 		= 	yOPc(1)/NbEchOPc;						
%     yOPc(1) 		= 	[];
%     powerOPc 		= 	abs (yOPc(1:NbEchOPc/2)).^2;			% 	Calcul du power = amplitude au carr�
%     nyquistOPc	    = 	FechOPc/2;
%     freqOPc 		= 	(1:NbEchOPc/2)/(NbEchOPc/2)*nyquistOPc;	% 	Cr�ation du vecteur fr�quence pour plotter la FFT    
% 													            % 	Calcul dla partie r�elle et de la partie complexe 
%                                                                 
% % b. Muscle FDI                                                               
% 
%    NbEchFDIc        =   length(FDIc);                             % give the number of Ech
%    TFDIcinitial      =   0;                                        % P�riode initiale 
%    TFDIcfinal		=   ((NbEchFDIc)/2000);					      % D�termination de la date finale
%    FechFDIc          =   2000;                                     % Fr�quence d'�chantillonnage des donn�es
%    tFDIc			    =   TFDIcinitial : FechFDIc : TFDIcfinal;
% 
%    yFDIc 			= 	fft(FDIc);
%    AzeroFDIc 		= 	yFDIc(1)/NbEchFDIc;						
%    yFDIc(1) 		= 	[];
%    powerFDIc 		= 	abs (yFDIc(1:NbEchFDIc/2)).^2;			  %	Calcul du power = amplitude au carr�
%    nyquistFDIc	    = 	FechFDIc/2;
%    freqFDIc 		= 	(1:NbEchFDIc/2)/(NbEchFDIc/2)*nyquistFDIc; % Cr�ation du vecteur fr�quence pour plotter la FFT    
% 
% %%%% 7B. FFT sur signal rectifi� et corrig�
% 
% % a. Muscle OP
% 
%     NbEchOPcr        =   length(OPcr);                              %   give the number of Ech
%     TOPcrinitial      =   0;                                        %   P�riode initiale 
%     TOPcrfinal		=	((NbEchOPcr)/2000);					      %   D�termination de la date finale
%     FechOPcr          =   2000;                                     %   Fr�quence d'�chantillonnage des donn�es
%     tOPcr			    = 	TOPcrinitial : FechOPcr : TOPcrfinal;
% 
%     yOPcr 			= 	fft(OPcr);
%     AzeroOPcr 		= 	yOPcr(1)/NbEchOPcr;						
%     yOPcr(1) 		= 	[];
%     powerOPcr 		= 	abs (yOPcr(1:NbEchOPcr/2)).^2;			% 	Calcul du power = amplitude au carr�
%     nyquistOPcr	    = 	FechOPcr/2;
%     freqOPcr 		= 	(1:NbEchOPcr/2)/(NbEchOPcr/2)*nyquistOPcr;	% 	Cr�ation du vecteur fr�quence pour plotter la FFT    
% 													            % 	Calcul dla partie r�elle et de la partie complexe 
%                                                                 
% % b. Muscle FDI                                                               
% 
%    NbEchFDIcr        =   length(FDIcr);                             % give the number of Ech
%    TFDIcrinitial      =   0;                                        % P�riode initiale 
%    TFDIcrfinal		=   ((NbEchFDIcr)/2000);					      % D�termination de la date finale
%    FechFDIcr          =   2000;                                     % Fr�quence d'�chantillonnage des donn�es
%    tFDIcr			    =   TFDIcrinitial : FechFDIcr : TFDIcrfinal;
% 
%    yFDIcr 			= 	fft(FDIcr);
%    AzeroFDIcr 		= 	yFDIcr(1)/NbEchFDIcr;						
%    yFDIcr(1) 		= 	[];
%    powerFDIcr 		= 	abs (yFDIcr(1:NbEchFDIcr/2)).^2;			  %	Calcul du power = amplitude au carr�
%    nyquistFDIcr	    = 	FechFDIcr/2;
%    freqFDIcr 		= 	(1:NbEchFDIcr/2)/(NbEchFDIcr/2)*nyquistFDIcr; % Cr�ation du vecteur fr�quence pour plotter la FFT    
% 
% 
% % a. Muscle OP
% 
%     NbEchOPn        =   length(OPn);                              %   give the number of Ech
%     TOPinitial      =   0;                                        %   P�riode initiale 
%     TOPfinal		=	((NbEchOPn)/2000);					      %   D�termination de la date finale
%     FechOP          =   2000;                                     %   Fr�quence d'�chantillonnage des donn�es
%     tOP			    = 	TOPinitial : FechOP : TOPfinal;
% 
%     yOPn 			= 	fft(OPn);
%     AzeroOPn 		= 	yOPn(1)/NbEchOPn;						
%     yOPn(1) 		= 	[];
%     powerOPn 		= 	abs (yOPn(1:NbEchOPn/2)).^2;			% 	Calcul du power = amplitude au carr�
%     nyquistOP	    = 	FechOP/2;
%     freqOPn 		= 	(1:NbEchOPn/2)/(NbEchOPn/2)*nyquistOP;	% 	Cr�ation du vecteur fr�quence pour plotter la FFT    
% 													            % 	Calcul dla partie r�elle et de la partie complexe 
%                                                                 
% % b. Muscle FDI                                                               
% 
%    NbEchFDIn        =   length(FDIn);                             % give the number of Ech
%    TFDIninitial      =   0;                                        % P�riode initiale 
%    TFDInfinal		=   ((NbEchFDIn)/2000);					      % D�termination de la date finale
%    FechFDIn          =   2000;                                     % Fr�quence d'�chantillonnage des donn�es
%    tFDIn			    =   TFDIninitial : FechFDIn : TFDInfinal;
% 
%    yFDIn 			= 	fft(FDIn);
%    AzeroFDIn 		= 	yFDIn(1)/NbEchFDIn;						
%    yFDIn(1) 		= 	[];
%    powerFDIn 		= 	abs (yFDIn(1:NbEchFDIn/2)).^2;			  %	Calcul du power = amplitude au carr�
%    nyquistFDIn	    = 	FechFDIn/2;
%    freqFDIn 		= 	(1:NbEchFDIn/2)/(NbEchFDIn/2)*nyquistFDIn; % Cr�ation du vecteur fr�quence pour plotter la FFT    
% 
% % c. Force produite par le sujet.
% 													            % 	Calcul dla partie r�elle et de la partie complexe 
%    NbEchFS         =    length(FSujet);                       % give the number of Ech
%    TFSinitial      =    0;                                      %   P�riode initiale 
%    TFSfinal		   =    ((NbEchFS)/2000);					    % 	D�termination de la date finale
%    FechFS          =    2000;                                    %   Fr�quence d'�chantillonnage des donn�es
%    tFS 			   = 	TFSinitial : FechFS : TFSfinal;
% 
%    yFS 			    = 	fft(FSujet);
%    AzeroFS 		    = 	yFS(1)/NbEchFS;						
%    yFS(1) 		    = 	[];
%    powerFS 		    = 	abs (yFS(1:NbEchFS/2)).^2;				% 	Calcul du power = amplitude au carr�
%    nyquistFS	    = 	FechFS/2;
%    freqFS 		    = 	(1:NbEchFS/2)/(NbEchFS/2)*nyquistFS;	% 	Cr�ation du vecteur fr�quence pour plotter la FFT    
% 			
%    %%%% Analyse du contenu frequentiel des intervalles de fr�quence pour 3 types de FFT
%    % effectu�es
%    
%    % Truc=freqOPc/sum(powerOPc)*100
%    
%    figure(1)
%    
%    subplot(4,1,1)
%    plot(freqOPc(1:160),powerOPc(1:160)/sum(powerOPc)*100)
%    
%    subplot(4,1,2)
%    plot(freqOPcr(1:160),powerOPcr(1:160)/sum(powerOPcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqOPn(1:160),powerOPn(1:160)/sum(powerOPn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(1:160),powerFS(1:160)/sum(powerFS)*100)
%    
%    figure(2)
%    
%    subplot(4,1,1)
%    plot(freqOPc(161:639)/sum(powerOPc)*100,powerOPc(161:639))
%    
%    subplot(4,1,2)
%    plot(freqOPcr(161:639),powerOPcr(161:639)/sum(powerOPcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqOPn(161:639),powerOPn(161:639)/sum(powerOPn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(161:639),powerFS(161:639)/sum(powerFS)*100) 
%    
%    figure(3)
%    
%    subplot(4,1,1)
%    plot(freqOPc(640:1278),powerOPc(640:1278)/sum(powerOPc)*100)
%    
%    subplot(4,1,2)
%    plot(freqOPcr(640:1278),powerOPcr(640:1278)/sum(powerOPcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqOPn(640:1278),powerOPn(640:1278)/sum(powerOPn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(640:1278),powerFS(640:1278)/sum(powerFS)*100) 
%    
%    figure(4)
%    
%    subplot(4,1,1)
%    plot(freqOPc(1279:2130),powerOPc(1279:2130)/sum(powerOPc)*100)
%    
%    subplot(4,1,2)
%    plot(freqOPcr(1279:2130),powerOPcr(1279:2130)/sum(powerOPcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqOPn(1279:2130),powerOPn(1279:2130)/sum(powerOPn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(1279:2130),powerFS(1279:2130)/sum(powerFS)*100) 
%    
%    figure(5)
%    
%    subplot(4,1,1)
%    plot(freqOPc(2131:4260),powerOPc(2131:4260)/sum(powerOPc)*100)
%    
%    subplot(4,1,2)
%    plot(freqOPcr(2131:4260),powerOPcr(2131:4260)/sum(powerOPcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqOPn(2131:4260),powerOPn(2131:4260)/sum(powerOPn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(2131:4260),powerFS(2131:4260)/sum(powerFS)*100) 
%    
%    figure(6)
%    
%    subplot(4,1,1)
%    plot(freqOPc(4261:10650),powerOPc(4261:10650)/sum(powerOPc)*100)
%    
%    subplot(4,1,2)
%    plot(freqOPcr(4261:10650),powerOPcr(4261:10650)/sum(powerOPcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqOPn(4261:10650),powerOPn(4261:10650)/sum(powerOPn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(4261:10650),powerFS(4261:10650)/sum(powerFS)*100)
%    
%    figure(7)
%    
%    subplot(4,1,1)
%    plot(freqOPc(10651:end),powerOPc(10651:end)/sum(powerOPc)*100)
%    
%    subplot(4,1,2)
%    plot(freqOPcr(10651:end),powerOPcr(10651:end)/sum(powerOPcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqOPn(10651:end),powerOPn(10651:end)/sum(powerOPn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(10651:end),powerFS(10651:end)/sum(powerFS)*100)
%    
%    figure(8)
%    
%    subplot(4,1,1)
%    plot(freqFDIc(1:160),powerFDIc(1:160)/sum(powerFDIc)*100)
%    
%    subplot(4,1,2)
%    plot(freqFDIcr(1:160),powerFDIcr(1:160)/sum(powerFDIcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqFDIn(1:160),powerFDIn(1:160)/sum(powerFDIn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(1:160),powerFS(1:160)/sum(powerFS)*100)
%    
%    figure(9)
%    
%    subplot(4,1,1)
%    plot(freqFDIc(161:639),powerFDIc(161:639)/sum(powerFDIc)*100)
%    
%    subplot(4,1,2)
%    plot(freqFDIcr(161:639),powerFDIcr(161:639)/sum(powerFDIcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqFDIn(161:639),powerFDIn(161:639)/sum(powerFDIn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(161:639),powerFS(161:639)/sum(powerFS)*100) 
%    
%    figure(10)
%    
%    subplot(4,1,1)
%    plot(freqFDIc(640:1278),powerFDIc(640:1278)/sum(powerFDIc)*100)
%    
%    subplot(4,1,2)
%    plot(freqFDIcr(640:1278),powerFDIcr(640:1278)/sum(powerFDIcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqFDIn(640:1278),powerFDIn(640:1278)/sum(powerFDIn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(640:1278),powerFS(640:1278)/sum(powerFS)*100) 
%    
%    figure(11)
%    
%    subplot(4,1,1)
%    plot(freqFDIc(1279:2130),powerFDIc(1279:2130)/sum(powerFDIc)*100)
%    
%    subplot(4,1,2)
%    plot(freqFDIcr(1279:2130),powerFDIcr(1279:2130)/sum(powerFDIcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqFDIn(1279:2130),powerFDIn(1279:2130)/sum(powerFDIn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(1279:2130),powerFS(1279:2130)/sum(powerFS)*100) 
%    
%    figure(12)
%    
%    subplot(4,1,1)
%    plot(freqFDIc(2131:4260),powerFDIc(2131:4260)/sum(powerFDIc)*100)
%    
%    subplot(4,1,2)
%    plot(freqFDIcr(2131:4260),powerFDIcr(2131:4260)/sum(powerFDIcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqFDIn(2131:4260),powerFDIn(2131:4260)/sum(powerFDIn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(2131:4260),powerFS(2131:4260)/sum(powerFS)*100) 
%    
%    figure(13)
%    
%    subplot(4,1,1)
%    plot(freqFDIc(4261:10650),powerFDIc(4261:10650)/sum(powerFDIc)*100)
%    
%    subplot(4,1,2)
%    plot(freqFDIcr(4261:10650),powerFDIcr(4261:10650)/sum(powerFDIcr)*100)
%    
%    subplot(4,1,3)
%    plot(freqFDIn(4261:10650),powerFDIn(4261:10650)/sum(powerFDIn)*100)
%    
%    subplot(4,1,4)
%    plot(freqFS(4261:10650),powerFS(4261:10650)/sum(powerFS)*100)
%    
%    figure(14)
%    
%    subplot(4,1,1)
%    plot(freqFDIc(10651:end),powerFDIc(10651:end)/sum(powerFDIc)*100)
%       
%    subplot(4,1,2)
%    plot(freqFDIcr(10651:end),powerFDIcr(10651:end)/sum(powerFDIcr)*100)
%       
%    subplot(4,1,3)
%    plot(freqFDIn(10651:end),powerFDIn(10651:end)/sum(powerFDIn)*100)
%       
%    subplot(4,1,4)
%    plot(freqFS(10651:end),powerFS(10651:end)/sum(powerFS)*100)
%    
%  % Int�grales sous la courbe pour comparer les FFT entre les deux muscles et la force
%  % pour les deux gammes de fr�quence
%     
% % length(freqFDIn):106500 pour 1000 hz
% % i1=0-1.5  i2=1.5-6 i3=6-12 i4=12-20 i5=20-40 i6=40-100 i7=100-end
% 
% % signal brut
%  FFT1FreqOPi1=sum(powerOPc(1:160));
%  FFT1FreqFDIi1=sum(powerFDIc(1:160));
%  
%  FFT1FreqOPi2=sum(powerOPc(161:639));
%  FFT1FreqFDIi2=sum(powerFDIc(161:639));
%  
%  FFT1FreqOPi3=sum(powerOPc(640:1278));
%  FFT1FreqFDIi3=sum(powerFDIc(640:1278));
%  
%  FFT1FreqOPi4=sum(powerOPc(1279:2130));
%  FFT1FreqFDIi4=sum(powerFDIc(1279:2130));
%  
%  FFT1FreqOPi5=sum(powerOPc(2131:4260));
%  FFT1FreqFDIi5=sum(powerFDIc(2131:4260));
%  
%  FFT1FreqOPi6=sum(powerOPc(4261:10650));
%  FFT1FreqFDIi6=sum(powerFDIc(4261:10650));
%  
%  FFT1FreqOPi7=sum(powerOPc(10651:end));
%  FFT1FreqFDIi7=sum(powerFDIc(10651:end));
% 
%  % signal corrig� rectifi�
%  FFT2FreqOPi1=sum(powerOPcr(1:160));
%  FFT2FreqFDIi1=sum(powerFDIcr(1:160));
%  
%  FFT2FreqOPi2=sum(powerOPcr(161:639));
%  FFT2FreqFDIi2=sum(powerFDIcr(161:639));
%  
%  FFT2FreqOPi3=sum(powerOPcr(640:1278));
%  FFT2FreqFDIi3=sum(powerFDIcr(640:1278));
%  
%  FFT2FreqOPi4=sum(powerOPcr(1279:2130));
%  FFT2FreqFDIi4=sum(powerFDIcr(1279:2130));
%  
%  FFT2FreqOPi5=sum(powerOPcr(2131:4260));
%  FFT2FreqFDIi5=sum(powerFDIcr(2131:4260));
%  
%  FFT2FreqOPi6=sum(powerOPcr(4261:10650));
%  FFT2FreqFDIi6=sum(powerFDIcr(4261:10650));
%  
%  FFT2FreqOPi7=sum(powerOPcr(10651:end));
%  FFT2FreqFDIi7=sum(powerFDIcr(10651:end));
%  
% % signal normalis�
%  FFT3FreqOPi1=sum(powerOPn(1:160));
%  FFT3FreqFDIi1=sum(powerFDIn(1:160));
%  FreqForcei1=sum(powerFS(1:160));
%  
%  FFT3FreqOPi2=sum(powerOPn(161:639));
%  FFT3FreqFDIi2=sum(powerFDIn(161:639));
%  FreqForcei2=sum(powerFS(161:639));
%  
%  FFT3FreqOPi3=sum(powerOPn(640:1278));
%  FFT3FreqFDIi3=sum(powerFDIn(640:1278));
%  FreqForcei3=sum(powerFS(640:1278));
%  
%  FFT3FreqOPi4=sum(powerOPn(1279:2130));
%  FFT3FreqFDIi4=sum(powerFDIn(1279:2130));
%  FreqForcei4=sum(powerFS(1279:2130));
%  
%  FFT3FreqOPi5=sum(powerOPn(2131:4260));
%  FFT3FreqFDIi5=sum(powerFDIn(2131:4260));
%  FreqForcei5=sum(powerFS(2131:4260));
%  
%  FFT3FreqOPi6=sum(powerOPn(4261:10650));
%  FFT3FreqFDIi6=sum(powerFDIn(4261:10650));
%  FreqForcei6=sum(powerFS(4261:10650));
%  
%  FFT3FreqOPi7=sum(powerOPn(10651:end));
%  FFT3FreqFDIi7=sum(powerFDIn(10651:end));
%  FreqForcei7=sum(powerFS(10651:end));
%  
%  GlobFFT=[FFT1FreqOPi1 FFT2FreqOPi1 FFT3FreqOPi1 FFT1FreqFDIi1 FFT2FreqFDIi1 FFT3FreqFDIi1 FreqForcei1;  FFT1FreqOPi2 FFT2FreqOPi2 FFT3FreqOPi2 FFT1FreqFDIi2 FFT2FreqFDIi2 FFT3FreqFDIi2 FreqForcei2; FFT1FreqOPi3 FFT2FreqOPi3 FFT3FreqOPi3 FFT1FreqFDIi3 FFT2FreqFDIi3 FFT3FreqFDIi3 FreqForcei3; FFT1FreqOPi4 FFT2FreqOPi4 FFT3FreqOPi4 FFT1FreqFDIi4 FFT2FreqFDIi4 FFT3FreqFDIi4 FreqForcei4; FFT1FreqOPi5 FFT2FreqOPi5 FFT3FreqOPi5 FFT1FreqFDIi5 FFT2FreqFDIi5 FFT3FreqFDIi5 FreqForcei5; FFT1FreqOPi6 FFT2FreqOPi6 FFT3FreqOPi6 FFT1FreqFDIi6 FFT2FreqFDIi6 FFT3FreqFDIi6 FreqForcei6; FFT1FreqOPi7 FFT2FreqOPi7 FFT3FreqOPi7 FFT1FreqFDIi7 FFT2FreqFDIi7 FFT3FreqFDIi7 FreqForcei7];
%  
% abscisse=[1:length(OPcr)];
% 
% % figure(6)
% % 
% % subplot(3,1,1)
% % hold on
% % plot(abscisse, OPcr,'r')
% % plot(abscisse,OPn,'b')
% % hold off
% % 
% % subplot(3,1,2)
% % hold on
% % plot(abscisse,FDIcr,'r')
% % plot(abscisse,FDIn,'b')
% % hold off
% % 
% % subplot(3,1,3)
% % hold on
% % plot(abscisse,OPn,'r')
% % plot(abscisse,FDIn,'b')
% % hold off
% % 
% % % 8. Calcul de la r�gression sur chaque signal EMG normalis� (par rapport au gain) par rapport 
% % % au signal de force
% % 
% % % On fait une r�gression lin�aire avec linreg2 de fr�do
% % 
% % dataOPreg=dataNoStim(:,7);
% % dataFDIreg=dataNoStim(:,8);
% % dataForce=dataNoStim(:,2);
% % 
% % [aOPF,bOPF,statsOPF,corrOPF] = linreg2(dataForce,dataOPreg);
% % [aFDIF,bFDIF,statsFDIF,corrFDIF] = linreg2(dataForce,dataFDIreg);
% % 
% % aOPF
% % bOPF 
% % statsOPF(1)
% % statsOPF(2)
% % statsOPF(3)
% % statsOPF(4)
% % statsOPF(5)
% % corrOPF
% % 
% % aFDIF
% % bFDIF 
% % statsFDIF(1)
% % statsFDIF(2)
% % statsFDIF(3)
% % statsFDIF(4)
% % statsFDIF(5)
% % corrFDIF
% % 
% % % reconstruction des donn�es avec la r�gression
% % yOPreg=aOPF*dataForce+bOPF;
% % yFDIreg=aFDIF*dataForce+bFDIF;
% % 
% % figure(7)
% % 
% % subplot(2,1,1)
% % hold on
% % plot(dataForce,dataOPreg,'r')
% % plot(dataForce,yOPreg)
% % hold off
% % 
% % subplot(2,1,2)
% % hold on
% % plot(dataForce,dataFDIreg,'r')
% % plot(dataForce,yFDIreg)
% % hold off
% % 
% % % % % Tableau r�capitulatif de sauvegarde.
% % % % 
% % % DataStat=[FreeCorrMaxOP_Force FreeCorrMaxFDI_Force FreeCorrMax2m FreeLOP FreeLFDI FreeL2m; ResCorrMaxOP ResCorrMaxFDI ResCorrMax2m ResLOP ResLFDI ResL2m];
% % % 
% save('FFT_VS1.txt', 'GlobFFT','-ASCII');
% % % % save('DataStatYc_VL2.txt', 'Y', '-ASCII');
% % % % 
% % % % 
% % % 
% % % 
% % % % end
% % % % 
% % % % %
