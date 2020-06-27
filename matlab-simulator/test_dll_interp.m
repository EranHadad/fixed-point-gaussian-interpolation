% clear; close; clc;

% Script parameters:
% ------------------
n_fraction_bits = 7; % new real value bin index will be stored in Q7 format
N = 1024;
wintype = 'hamming'; % 'hamming' % 'blackman-harris-nuttall'
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
    case 'blackman-harris-nuttall'
        win = BlackmanHarrisNuttall(N);
    otherwise
        win = hamming(N);
end

% vector to store the results
k_parabolic   = nan(size(k_target_vec));
k_gaussian    = nan(size(k_target_vec));
k_c_parabolic = nan(size(k_target_vec));
k_c_gaussian  = nan(size(k_target_vec));

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
    % Max FFT amplitute with rectangular window is 2^9=512, complement this
    % to max of unsigned 16-bit we need to multiply by 2^7.
    amp_center = round(amp_center * 2^7);
    amp_left = round(amp_left * 2^7);
    amp_right = round(amp_right * 2^7);
    
    % C-parabolic interpolation
    fxp_out = calllib('FixedPointLib', 'calculateParabolicPeak', k_raw_est, amp_center, amp_left, amp_right);
    float_out = calllib('FixedPointLib', 'FixedToDouble', fxp_out, n_fraction_bits);
    k_c_parabolic(n) = float_out;
    
    % C-Gaussian interpolation
    fxp_out = calllib('FixedPointLib', 'calculateGaussianPeak', k_raw_est, amp_center, amp_left, amp_right);
    float_out = calllib('FixedPointLib', 'FixedToDouble', fxp_out, n_fraction_bits);
    k_c_gaussian(n) = float_out;
    
    % parabolic interpolation
    bin_update_par = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
    k_parabolic(n) = k_raw_est + bin_update_par;
    
    % gaussian interpolation
    amp_center = log(amp_center);
    amp_left = log(amp_left);
    amp_right = log(amp_right);
    bin_update_gau = 0.5 * (amp_right - amp_left) / (2*amp_center - amp_right - amp_left);
    k_gaussian(n) = k_raw_est + bin_update_gau;
end

% compute error terms
k_parabolic_err = k_parabolic - k_target_vec;
k_gaussian_err = k_gaussian - k_target_vec;
k_c_parabolic_err = k_c_parabolic - k_target_vec;
k_c_gaussian_err = k_c_gaussian - k_target_vec;

%% Display the results
figure('name','error for bin index estimation');
plot(bin_offset_vec, k_parabolic_err, 'color', 'r');
title(sprintf('window type: %s', wintype), 'fontsize', 16);
hold on;
plot(bin_offset_vec, k_c_parabolic_err, 'color', 'b');
plot(bin_offset_vec, k_gaussian_err, 'color', 'r');
plot(bin_offset_vec, k_c_gaussian_err, 'color', 'b');
hold off;
ylabel('error', 'fontsize', 16);
xlabel('bin offset from FFT grid', 'fontsize', 16);
legend('parabolic error (MATLAB)', 'parabolic error (C-code)', 'Gaussian error (MATLAB)', 'Gaussian error (C-code)');
grid on;
ylim([-0.1 0.1])

%% Cleanup.
unloadlibrary('FixedPointLib');





