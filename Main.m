clear all
close all
clc
%% RICERCA ONDA P

% Position contiene il numero del campione in cui è presente il picco della curva
% segnata in PositionType (N = QRS, p = onde P)

[Position, PositionType] = textread('sel33.q1c','%d %c');

N_position = find(PositionType=='N'); % posizioni in cui c'è N nel vettore char
x_og = load('sel33.dat','-ascii')';
x_og = x_og(1,:);

l = length(x_og); 
fs = 250;

t = (0:l-1)/fs;
f = ((0:l-1)-floor(l/2))*fs/l;
X_og = fftshift(abs(fft(x_og)))/l;

figure(1)
subplot(2,1,1)
plot(t, x_og);
xlabel('t [s]')
title('primo canale')
subplot(2,1,2)
plot(f,X_og)
xlabel('f [Hz]')
title('spettro primo canale')

QRS_position = Position(N_position); % trova numero del campione in cui c'è il picco QRS

%% QRS REMOVAL
% ogni campione in QRS è il centro di un intervallo di 110 ms, in cui il
% segnale deve essere sostituito da una retta che congiunga gli estremi di
% questo intervallo

half_interval_size = round(55*fs/(1000)); % 55ms in campioni

x_noQRS = x_og;

for k = 1:1:length(QRS_position)

    QRS_interval = QRS_position(k)-half_interval_size:QRS_position(k)+half_interval_size-1; 
    x_noQRS(QRS_interval) = linspace(x_og(QRS_position(k)-half_interval_size),x_og(QRS_position(k)+half_interval_size),2*half_interval_size);
end

X_noQRS = fftshift(abs(fft(x_noQRS)))/l;

figure(2)
subplot(2,1,1)
plot(t, x_noQRS);
xlabel('t [s]')
title('primo canale, tolto QRS')
subplot(2,1,2)
plot(f,X_noQRS)
xlabel('f [Hz]')
title('spettro primo canale')

%% FILTRO PASSA BANDA LINEARE [3 11]Hz E RIALLINEAMENTO 
% allinea il risultato al segnale originale, rimuovendo i primi campioni
% ritardati del segnale filtrato
% salva i coefficienti su un file.mat e importati per il processing

b = load('Cardia66349_coeff.mat', '-mat').Coeff;
delay = round((length(b)-1)/2);

x_noQRS_filtered = filter(b,1,x_noQRS);
X_noQRS_filtered = fftshift(abs(fft(x_noQRS_filtered)))/l;

x_noQRS_filtered_realigned = x_noQRS_filtered(delay:end); % segnale filtrato e riallineato
x_noQRS_filtered_realigned = [x_noQRS_filtered_realigned zeros(1,length(x_noQRS)-length(x_noQRS_filtered_realigned))];

figure(3)
subplot(2,1,1)
plot(t,x_noQRS);
hold on
plot(t, x_noQRS_filtered_realigned, 'm')
xlabel('t [s]')
title('primo canale, tolto QRS e filtrato a banda passante')
legend('Segnale senza QRS','Segnale senza QRS filtrato e riallineato')
subplot(2,1,2)
plot(f,X_noQRS_filtered,'m')
xlabel('f [Hz]')
title('spettro primo canale filtrato - [3 11] Hz')

%% RICERCA ONDE P

% Preallocazione
R_position = zeros(1,length(N_position)); 
RR_specific= zeros(size(R_position)-1);

% trova posizione specifica di R con un for in cui si cerca il max in QRS
for k=1:1:length(R_position)

    QRS_interval = QRS_position(k)-half_interval_size:QRS_position(k)+half_interval_size-1;
    R_position(k) = max(x_og(QRS_interval)); 
    R_position(k) = find(x_og(QRS_interval) == R_position(k),1); %vede le posizioni dei picchi R riferite all'intervallo
    R_position(k) = R_position(k) + (QRS_position(k)-half_interval_size-1); % vede le posizioni riferite al segnale
end

for k=2:length(R_position)

    RR_specific(k-1) = R_position(k)-R_position(k-1);
end

RR = round(mean(RR_specific));

findp_beforeQRS = round(2*RR/9 + 250/1000* fs); % quanti campioni prima di QRS dobbiamo andare per trovare P

% estrarre dal segnale tutte le porzioni di segnale che rientrano nella
% finestra findp alla sx di ogni annotazione QRS
    % i pezzi estratti sono da mettere in una matrice, per righe, ogni
    % pezzo una riga nuova

P = zeros(length(QRS_position), findp_beforeQRS); 
x_ondeP = zeros(size(x_og));

for k = 1:length(QRS_position)

    interval_findp = (QRS_position(k)-findp_beforeQRS):QRS_position(k)-1;
    P(k,:) = x_noQRS_filtered_realigned(interval_findp);
    x_ondeP(interval_findp) = x_noQRS_filtered_realigned(interval_findp);
end



figure (4)
plot(t,x_noQRS_filtered_realigned,t,x_ondeP,'.')
xlim([QRS_position(1)/fs QRS_position(end)/fs]);
ylim([-20 20])
xlabel('t [s]')
legend('Segnale senza QRS filtrato e riallineato','Segmenti di ricerca Onde P')
title('Evidenziazione Onde P nel segnale senza QRS filtrato e riallineato')

t_ondeP =(0:size(P,2)-1)/fs; % P,2 to get the number of columns

figure (5)

for k=1:length(QRS_position)
   
    hold on
    plot(t_ondeP,P(k,:),'LineWidth',0.2)
end

MediaOndeP=zeros(1,size(P,2));
MediaOndeP=sum(P(1:end,:))/size(P,1);

hold on
plot(t_ondeP,MediaOndeP,'k*-','LineWidth',0.75)

xlabel('t [s]')
ylim([-20 20])
xlim([t_ondeP(1) t_ondeP(end)])
title('Segmenti Onde P + Media Onde P (in nero)')


%% RECAP PLOT
figure (6)
plot(t,x_og,t,x_noQRS,t,x_noQRS_filtered,'g',t,x_noQRS_filtered_realigned,'k',t,x_ondeP,'m.')
xlim([QRS_position(1)/fs-4 QRS_position(end)/fs+4]);
xlabel('t [s]')
legend('Segnale Originale','Segnale Senza complessi QRS','Segnale Senza complessi QRS filtrato','Segnale Senza complessi QRS filtrato e riallineato','Evidenziazione dei complessi QRS nel segnale filtrato e riallineato')

