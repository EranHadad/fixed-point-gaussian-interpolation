clear; close; clc;

DEBUG_PRINT = false;

% Script parameters:
% ------------------
n_fraction_bits = 7;
N = 1024;
wintype = 'hamming'; % 'hamming' % 'rectwin'
log_func = @log; % @log2 % @log
bin_offset_vec = -0.5:0.01:0.5;
bin_offset_vec = bin_offset_vec(:); % convert to column vector
k_target_vec = 20 + bin_offset_vec;
% -----------------------------------------------

% Load the library.
if ~libisloaded('FixedPointLib')
    dll_path = [pwd '\FixedPointLib\x64\Debug\FixedPointLib.dll'];
    h_path = [pwd '\FixedPointLib\FixedPointLib\FixedPointLib.h'];
    [notfound, warnings] = loadlibrary(dll_path, h_path);
end

% Display function signature.
% libfunctionsview('FixedPointLib')

switch wintype
    case 'rectwin'
        win = rectwin(N);
    otherwise
        win = hamming(N);
end

% vector to store the results
k_parabolic_est = nan(size(k_target_vec));
%k_gaussian_est  = nan(size(k_target_vec));
k_c_parabolic   = nan(size(k_target_vec));

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
    
    % imitate HW behaviour (u16 dynamic range)
    amp_center = round(amp_center * 2^7);
    amp_left = round(amp_left * 2^7);
    amp_right = round(amp_right * 2^7);
    
    % C-parabolic interpolation
    fxp_out = calllib('FixedPointLib', 'calculateParabolicPeak', k_raw_est, amp_center, amp_left, amp_right);
    float_out = calllib('FixedPointLib', 'q_to_float', fxp_out, n_fraction_bits);
    k_c_parabolic(n) = float_out;
    
    % parabolic interpolation
    bin_update_par = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
    k_parabolic_est(n) = k_raw_est + bin_update_par;
    
    % gaussian interpolation
    %amp_center = log_func(amp_center);
    %amp_left = log_func(amp_left);
    %amp_right = log_func(amp_right);
    %bin_update_gau = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
    %k_gaussian_est(n) = k_raw_est + bin_update_gau;
    
    if DEBUG_PRINT == true
        fprintf('true bin index: %f\n', k_target);
        fprintf('bin index estimation without interplolation: %f\n', k_raw_est);
        %fprintf('bin index estimation using parabolic interplolation: %f\n', k_parabolic_est(n));
        %fprintf('bin index estimation using gaussian interplolation: %f\n\n', k_gaussian_est(n));
    end
end

% compute error terms
k_parabolic_err = k_parabolic_est - k_target_vec;
%k_gaussian_err = k_gaussian_est - k_target_vec;
k_c_parabolic_err = k_c_parabolic - k_target_vec;

figure('name','error for bin index estimation');
plot(bin_offset_vec, [k_parabolic_err, k_c_parabolic_err]);
ylabel('error');
xlabel('bin offset from FFT grid');
legend('parabolic error (matlab)', 'parabolic error (C-code)');
grid on;

%% Cleanup.
unloadlibrary('FixedPointLib');





