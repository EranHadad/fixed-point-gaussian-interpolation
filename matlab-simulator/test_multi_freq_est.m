clear; close; clc;

DEBUG_PRINT = false;

% Script parameters:
% ------------------
N = 1024;
wintype = 'hamming'; % 'hamming' % 'rectwin'
log_func = @log; % @log2 % @log
bin_offset_vec = -0.5:0.01:0.5;
bin_offset_vec = bin_offset_vec(:); % convert to column vector
k_target_vec = 20 + bin_offset_vec;
% -----------------------------------------------

switch wintype
    case 'rectwin'
        win = rectwin(N);
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
    
    
    % parabolic interpolation
    bin_update_par = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
    k_parabolic_est(n) = k_raw_est + bin_update_par;
    
    % gaussian interpolation
    amp_center = log_func(amp_center);
    amp_left = log_func(amp_left);
    amp_right = log_func(amp_right);
    bin_update_gau = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
    k_gaussian_est(n) = k_raw_est + bin_update_gau;
    
    if DEBUG_PRINT == true
        fprintf('true bin index: %f\n', k_target);
        fprintf('bin index estimation without interplolation: %f\n', k_raw_est);
        fprintf('bin index estimation using parabolic interplolation: %f\n', k_parabolic_est(n));
        fprintf('bin index estimation using gaussian interplolation: %f\n\n', k_gaussian_est(n));
    end
end

% compute error terms
k_parabolic_err = k_parabolic_est - k_target_vec;
k_gaussian_err = k_gaussian_est - k_target_vec;

figure('name','error for bin index estimation');
plot(bin_offset_vec, [k_parabolic_err, k_gaussian_err]);
ylabel('error');
xlabel('bin offset from FFT grid');
legend('parabolic error', 'gaussian error');
grid on;






