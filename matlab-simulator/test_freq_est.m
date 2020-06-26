clear; close; clc;

% Script parameters:
% ------------------
N = 1024;
wintype = 'hamming'; % 'hamming' % 'rectwin'
imitate_hw_dynamic_range = true;
log_func = @log; % @log2 % @log
k_target = 20.35;
% -----------------------------------------------

% generate signal
nfft = N;
w = 2*pi*k_target/nfft;
nn = 0:(N-1);
nn = nn(:); % convert to column vector
x = sin(w .* nn);

% apply window
switch wintype
    case 'hamming'
        x = x .* hamming(N);
    otherwise
        x = x .* rectwin(N);
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
amp_center = log_func(amp_center);
amp_left = log_func(amp_left);
amp_right = log_func(amp_right);
bin_update_gau = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
k_gaussian_est = k_raw_est + bin_update_gau;
fprintf('bin index estimation using gaussian interplolation: %f\n', k_gaussian_est);
