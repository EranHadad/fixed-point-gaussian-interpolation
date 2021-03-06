clear; close; clc;

% background for the problem in hand, estimate frequency by detecting the peak of the FFT and 
% perform parabolic or Gaussian interpolation.

% Script parameters:
% ------------------
N = 1024;
wintype = 'blackman-harris-nuttall'; % 'hamming' % 'rectwin' % 'blackman-harris-nuttall'
imitate_hw_dynamic_range = true;
log_func = @log; % @log2 % @log
k_target = 20.2;
% -----------------------------------------------

% generate signal
nfft = N;
w = 2*pi*k_target/nfft;
nn = 0:(N-1);
nn = nn(:); % convert to column vector
x = sin(w .* nn);

switch wintype
    case 'rectwin'
        win = rectwin(N);
    case 'blackman-harris-nuttall'
        win = BlackmanHarrisNuttall(N);
    otherwise
        win = hamming(N);
end

% fourier transform (FFT)
xfft = fft(x, nfft);
xfft = abs(xfft(1:(nfft/2+1)));

% display fourier transform
figure;
ax1 = subplot(2,1,1);
plot(x);
title('signal in time domain');
xlabel('sample index');
ax2 = subplot(2,1,2);
plot(xfft);
title('signal in frequency domain');
xlabel('bin index');

% get peak info
[max_val, max_ind] = max(xfft);
amp_center = max_val;
amp_left = xfft(max_ind - 1);
amp_right = xfft(max_ind + 1);

if imitate_hw_dynamic_range == true
    % imitate HW behaviour (u16 dynamic range)
    amp_center = round(amp_center * 2^7);
    amp_left = round(amp_left * 2^7);
    amp_right = round(amp_right * 2^7);
end

k_raw_est = max_ind - 1;
fprintf('true bin index: %f\n', k_target);
fprintf('bin index estimation without interplolation: %f\n', k_raw_est);

% parabolic interpolation
bin_update_par = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
k_parabolic_est = k_raw_est + bin_update_par;
fprintf('bin index estimation using parabolic interplolation: %f\n', k_parabolic_est);

% gaussian interpolation
log_amp_center = log_func(amp_center);
log_amp_left = log_func(amp_left);
log_amp_right = log_func(amp_right);
bin_update_gau = 0.5 * (log_amp_right - log_amp_left) / (2*log_amp_center - log_amp_right - log_amp_left);
k_gaussian_est = k_raw_est + bin_update_gau;
fprintf('bin index estimation using gaussian interplolation: %f\n', k_gaussian_est);
