    
clc
close all


PLOT_FIGURES=1;


%% DATA SOURCE

data_stream=round(rand(1,8));
data_stream_save = data_stream;

data_stream2 = [];

for i=1: 1:length(data_stream)
    if data_stream(i)== 0
        data_stream2=[data_stream2,0,0,0];
    end
    if data_stream(i)== 1
        data_stream2=[data_stream2,1,1,1];
    end
end

data_stream = data_stream2;

% Define start and stop bits
start_bit = 1;
stop_bit = 0;

% Add the start and stop bits to the data stream
data_stream = [start_bit data_stream stop_bit];

%-------------------------------
N=length(data_stream);

Rb=80;
Tb=1/Rb;

%% MODULATION
f=20*Rb; % Hz 
Ts=1/f;
ph=0;

A1=0; % 0
A2=1; % 1

%-------------------------------
fsamp = 50;
% Time for one bit
t = 0: Tb/fsamp : (Tb-Tb/fsamp);

% This time variable is just for plot
time = [];
mod = [];
%-------------------------------

Digital_signal = [];
signal = [];

for ii = 1: 1: N
    Digital_signal = [Digital_signal (data_stream(ii)==0)*...
        zeros(1,length(t)) + (data_stream(ii)==1)*ones(1,length(t))];
    
    signal = [signal (data_stream(ii)==0)*A1*cos(2*pi*f*t)+...
        (data_stream(ii)==1)*A2*cos(2*pi*f*t)];

    time = [time t];
    t =  t + Tb ;   
end


%--------------------------------------
% Plot
if PLOT_FIGURES
    figure(1);
    subplot(2,1,1);
    plot(time,Digital_signal,'k','LineWidth',2); hold all;
    xlabel('Time (bit period)');
    ylabel('Amplitude');
    title('');
    axis([0 time(end) -0.5 1.5]);
    grid on;
    xticks(0:N)
    
    subplot(2,1,2);
    plot(time,signal,'LineWidth',2);
    xlabel('Time (bit period)');
    ylabel('Amplitude');
    title('');
    %axis([0 time(end) 1.5 1.5]);
    xlim([0, N*Tb])
    grid  on;
    xticks(0:N)
end



%% TX
signalTX = signal;
powerTX = (norm(signalTX)^2)/length(signalTX);

%--------------------------------------
% Plot
if PLOT_FIGURES
    figure(2)
    subplot(2,1,1);
    plot(time,Digital_signal, 'k'); hold all;
    plot(time,signalTX, 'b'); hold all;
    xlabel('Time');
    ylabel('Amplitude');
    
    subplot(2,1,2);
    [psd1,F]=pspectrum(Digital_signal,1024,'power'); hold all;
    plot(F, 10*(log10(psd1)) , 'k'); % Plot the PSD
    
    [psd1,F]=pspectrum(signalTX,1024,'power');
    plot(F,10*(log10(psd1))); hold all;% Plot the PSD
    
end




%% CHANNEL

% % Channe
Pnoise=0.3;
signalRX = signalTX + wgn(size(signalTX, 1), size(signalTX, 2), Pnoise, 'linear');

%-----------------
% Plot
if PLOT_FIGURES
    figure(3)
    subplot(2,1,1);
    %plot(time,signalTX, 'b'); hold all;
    plot(time,signalRX, 'r'); hold all;
    %plot(time,Digital_signal,'k','LineWidth',2); hold all;
    xlabel('Time (bit period)');
    ylabel('Amplitude');
    
    subplot(2,1,2);
    [psd1,F]=pspectrum(signalTX,1024,'power'); hold all;
    plot(F, 10*(log10(psd1)) , 'k'); % Plot the PSD
    
    [psd1,F]=pspectrum(signalRX,1024,'power'); hold all;
    plot(F, 10*(log10(psd1)), 'r'); % Plot the PSD
end

%% DEMODULATION
rectSignal=signalRX.*cos(2*pi*f*time);

M2=100;
n=0:M2;

wc=2*pi*(4*Rb)/fsamp;

hr=sin(wc.*(n-M2/2))./(pi.*(n-M2/2));
hr(isnan(hr))=wc/pi;

wn=0.42- 0.5*cos(2*pi.*n / M2) + 0.08*cos(4*pi.*n / M2);

h=hr.*wn;

filtSignal = conv(rectSignal, h); 
filtSignal=filtSignal(M2/2:(end-M2/2-1));


% Power
powerDataSignal = (norm(Digital_signal)^2)/length(Digital_signal);
powerFiltSignal = (norm(filtSignal)^2)/length(filtSignal);


CorrectionFactor=sqrt(powerDataSignal)/sqrt(powerFiltSignal);
filtSignal=CorrectionFactor.*filtSignal;

%--------------------------------------------
% Plot 
if PLOT_FIGURES
    figure(4)
    subplot(5,1,1);
    plot(time,Digital_signal, 'k'); hold all;
    subplot(5,1,2);
    plot(time,signalTX, 'b'); hold all;
    subplot(5,1,3);
    plot(time,signalRX, 'r'); hold all;
    subplot(5,1,4);
    plot(time,rectSignal, 'm'); hold all;
    subplot(5,1,5);
    plot(time, filtSignal, 'g'); hold all;
    
    xlabel('Time (bit period)');
    ylabel('Amplitude');
    
    figure(5)
    [psd1,F]=pspectrum(Digital_signal,1024,'power'); hold all;
    subplot(4,1,1);
    plot(F, 10*(log10(psd1)) , 'k'); % Plot the PSD
    
    [psd1,F]=pspectrum(signalRX,1024,'power'); hold all;
    subplot(4,1,2);
    plot(F, 10*(log10(psd1)) , 'b'); % Plot the PSD

    [psd1,F]=pspectrum(rectSignal,1024,'power'); hold all;
    subplot(4,1,3);
    plot(F, 10*(log10(psd1)) , 'r'); % Plot the PSD
    
    [psd1,F]=pspectrum(filtSignal,1024,'power'); hold all;
    subplot(4,1,4);
    plot(F, 10*(log10(psd1)) , 'g'); % Plot the PSD
end


%-------------------------------------------------------
decoded_data_stream=[];

for ii = 1: 1: N
    indexBit=time>=(ii-1)*Tb & time<(ii)*Tb;   
    integratedValue=sum(filtSignal(indexBit))./sum(indexBit);
    decoded_data_stream=[decoded_data_stream integratedValue >( (A2+A1)/2)]; 
end

if decoded_data_stream(1) == start_bit
    disp('Start bit is correct');
    start_bit_val = 1;
    decoded_data_stream = decoded_data_stream(2:end);

    decode_part=[];

    for i=1: 3:length(decoded_data_stream)-1
        if i+3 == length(decoded_data_stream) && decoded_data_stream(end) == stop_bit
            disp('Stop bit is correct');
            stop_bit_val = 1;
            decoded_data_stream = decoded_data_stream(1:end-1);
        end
        frame = [decoded_data_stream(i), decoded_data_stream(i+1), decoded_data_stream(i+2)];
    
        equal_bits = mode(frame);
        
        equal_bits = equal_bits(:)';
        
        decode_part = [decode_part, equal_bits];
        
    end
    if stop_bit_val == 0
        decode_part = [];
    end
else
    disp('Start bit is incorrect');
end

%----------------------------------
% Calculate BER  
numErrorBits = sum(data_stream_save ~= decode_part); 
BER = numErrorBits / length(data_stream_save);

disp(data_stream_save)
disp(decode_part)
disp(BER)
