% Script parameters:
% ------------------
func_name = 'fxlog_mod'; % 'fxlog' % 'fxlog_mod'
n_fraction_bits = 7; % 7 % 16
xx = logspace(-6, 6, 100);
% -----------------------------------------------

% Load the library.
if ~libisloaded('FixedPointLib')
    dll_path = [pwd '\FixedPointLib\x64\Debug\FixedPointLib.dll'];
    h_path = [pwd '\FixedPointLib\FixedPointLib\FixedPointLib.h'];
    loadlibrary(dll_path, h_path);
end

% Display function signature.
% libfunctionsview('FixedPointLib')

%% Call the function.
yy = nan(size(xx));
for n = 1:length(xx)
    float_in = xx(n);
    if calllib('FixedPointLib', 'is_positive_representable', float_in, n_fraction_bits)
        fxp_in = calllib('FixedPointLib', 'float_to_q', float_in, n_fraction_bits);
        fxp_out = calllib('FixedPointLib', func_name, fxp_in);
        float_out = calllib('FixedPointLib', 'q_to_float', fxp_out, n_fraction_bits);
        yy(n) = float_out;
    end
end

%% Display results
matlab_log = log(xx);
error = yy - matlab_log;
relative_error = 100 * abs(error)./matlab_log;

titlestr = sprintf('log(x) implemented for Q%d', n_fraction_bits);

figure('name','fixed-point log(x)');
ax1 = subplot(2,1,1);
semilogx(xx, yy, 'color', 'b');
hold on; semilogx(xx, yy, '.', 'color', 'b');
hold on; semilogx(xx, matlab_log, '--'); hold off;
title(titlestr);
xlabel('x', 'fontsize', 16);
ylabel('log(x)', 'fontsize', 16);
grid on;

ax2 = subplot(2,1,2);
semilogx(xx, error, 'color', 'b');
hold on; semilogx(xx, error, '.', 'color', 'b');
xlabel('x', 'fontsize', 16);
ylabel('error(x)', 'fontsize', 16);
grid on;

linkaxes([ax1, ax2],'x');

figure('name','fixed-point log(x)');
ax1 = subplot(2,1,1);
semilogx(xx, yy, 'color', 'b');
hold on; semilogx(xx, yy, '.', 'color', 'b');
hold on; semilogx(xx, matlab_log, '--'); hold off;
title(titlestr);
xlabel('x', 'fontsize', 16);
ylabel('log(x)', 'fontsize', 16);
grid on;

ax2 = subplot(2,1,2);
semilogx(xx, relative_error, 'color', 'b');
hold on; semilogx(xx, relative_error, '.', 'color', 'b');
xlabel('x', 'fontsize', 16);
ylabel('relative error(x) (%)', 'fontsize', 16);
grid on;

linkaxes([ax1, ax2],'x');

%% Cleanup.
unloadlibrary('FixedPointLib');
