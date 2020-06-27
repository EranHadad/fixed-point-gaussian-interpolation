clear; close; clc;

% background for the problem in hand, estimate frequency by detecting the peak of the FFT and 
% perform parabolic or Gaussian interpolation.

% Script parameters:
% ------------------
N = 1024;
wintype = 'hamming'; % 'hamming' % 'blackman-harris-nuttall'
imitate_hw_dynamic_range = true;
bin_offset_vec = -0.5:0.01:0.5;
bin_offset_vec = bin_offset_vec(:); % convert to column vector
k_target_vec = 20 + bin_offset_vec;
% -----------------------------------------------

switch wintype
    case 'rectwin'
        win = rectwin(N);
    case 'blackman-harris-nuttall'
        win = BlackmanHarrisNuttall(N);
    otherwise
        win = hamming(N);
end

% vector to store the results
k_parabolic_est = nan(size(k_target_vec));
k_gaussian_est  = nan(size(k_target_vec));

nfft = N;
nn = 0:(N-1);
nn = nn(:); % convert to column vector
for n = 1:length(k_target_vec)
    
    % generate signal
    k_target = k_target_vec(n);
    w = 2*pi*k_target/nfft;
    x = sin(w .* nn);
    
    % apply window
    x = x .* win;
    
    % fourier transform (FFT)
    xfft = fft(x, nfft);
    xfft = abs(xfft(1:(nfft/2+1)));
    
    % get peak info
    [max_val, max_ind] = max(xfft);
    amp_center = max_val;
    amp_left = xfft(max_ind - 1);
    amp_right = xfft(max_ind + 1);
    k_raw_est = max_ind - 1;
    
    if imitate_hw_dynamic_range == true
        % imitate HW behaviour (u16 dynamic range)
        amp_center = round(amp_center * 2^7);
        amp_left = round(amp_left * 2^7);
        amp_right = round(amp_right * 2^7);
    end
    
    % parabolic interpolation
    bin_update_par = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
    k_parabolic_est(n) = k_raw_est + bin_update_par;
    
    % gaussian interpolation
    amp_center = log(amp_center);
    amp_left = log(amp_left);
    amp_right = log(amp_right);
    bin_update_gau = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
    k_gaussian_est(n) = k_raw_est + bin_update_gau;
end

% compute error terms
k_parabolic_err = k_parabolic_est - k_target_vec;
k_gaussian_err = k_gaussian_est - k_target_vec;

figure('name','error for bin index estimation');
plot(bin_offset_vec, [k_parabolic_err, k_gaussian_err]);
title(sprintf('window type: %s', wintype), 'fontsize', 16);
ylabel('error', 'fontsize', 16);
xlabel('bin offset from FFT grid', 'fontsize', 16);
legend('parabolic error', 'gaussian error');
grid on; grid minor;






