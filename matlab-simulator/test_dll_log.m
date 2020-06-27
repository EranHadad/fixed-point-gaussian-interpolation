% Script parameters:
% ------------------
func_name = {'fxlog', 'fxlog_mod'};
xx = logspace(-6, 6, 100);
xx = xx(:); % convert to column vector
% -----------------------------------------------

COLORS = {'r','b','g','c'};

% Load the library.
if ~libisloaded('FixedPointLib')
    dll_path = [pwd '\FixedPointLib\x64\Debug\FixedPointLib.dll'];
    h_path = [pwd '\FixedPointLib\FixedPointLib\FixedPointLib.h'];
    [notfound, warnings] = loadlibrary(dll_path, h_path);
end

% Display function signature.
% libfunctionsview('FixedPointLib')

%% Call MATLAB function.
matlab_log = log(xx);

%% Call the functions.
n_func = length(func_name);
n_inputs = length(xx);
yy = nan(n_inputs, n_func);
error = nan(n_inputs, n_func);
relative_error = nan(n_inputs, n_func);
for ifunc = 1:n_func
    % get current function name
    curr_func = func_name{ifunc};
    
    % set input and output formats
    switch curr_func
        case 'fxlog'
            % reference implementation
            n_fraction_in = 16;
            n_fraction_out = 16;
        case 'fxlog_mod'
            % optimized for optical algorithm
            n_fraction_in = 15;
            n_fraction_out = 24;
    end
    
    % Call the function.
    for n = 1:length(xx)
        float_in = xx(n);
        if calllib('FixedPointLib', 'is_positive_representable', float_in, n_fraction_in)
            fxp_in = calllib('FixedPointLib', 'DoubleToFixed', float_in, n_fraction_in);
            fxp_out = calllib('FixedPointLib', curr_func, fxp_in);
            float_out = calllib('FixedPointLib', 'FixedToDouble', fxp_out, n_fraction_out);
            yy(n, ifunc) = float_out;
        end
    end
    
    % Compute errors.
    error(:, ifunc) = yy(:, ifunc) - matlab_log;
    relative_error(:, ifunc) = 100 * abs(error(:, ifunc))./matlab_log;
end


%% Display results
FONT_SIZE = 20;

% values
figure('name','fixed-point log(x): values');
semilogx(xx, yy(:,1), 'color', COLORS{1});
for ifunc = 2:n_func
    hold on; semilogx(xx, yy(:,ifunc), 'color', COLORS{ifunc}); hold off;
end
for ifunc = 1:n_func
    hold on; semilogx(xx, yy(:,ifunc), '.', 'color', COLORS{ifunc}); hold off;
end
hold on; semilogx(xx, matlab_log, 'k--'); hold off;
xlabel('x', 'fontsize', FONT_SIZE);
title('log(x)', 'fontsize', FONT_SIZE);
grid on;
legend(func_name, 'interpreter', 'none', 'location', 'northwest', 'fontsize', FONT_SIZE);

% error
figure('name','fixed-point log(x): error');
semilogx(xx, error(:,1), 'color', COLORS{1});
for ifunc = 2:n_func
    hold on; semilogx(xx, error(:,ifunc), 'color', COLORS{ifunc}); hold off;
end
for ifunc = 1:n_func
    hold on; semilogx(xx, error(:,ifunc), '.', 'color', COLORS{ifunc}); hold off;
end
xlabel('x', 'fontsize', FONT_SIZE);
title('error(x)', 'fontsize', FONT_SIZE);
grid on;
legend(func_name, 'interpreter', 'none', 'location', 'northwest', 'fontsize', FONT_SIZE);

% relative error
figure('name','fixed-point log(x): relative error');
semilogx(xx, relative_error(:,1), 'color', COLORS{1});
for ifunc = 2:n_func
    hold on; semilogx(xx, relative_error(:,ifunc), 'color', COLORS{ifunc}); hold off;
end
for ifunc = 1:n_func
    hold on; semilogx(xx, relative_error(:,ifunc), '.', 'color', COLORS{ifunc}); hold off;
end
xlabel('x', 'fontsize', FONT_SIZE);
title('relative error(x) (%)', 'fontsize', FONT_SIZE);
grid on;
legend(func_name, 'interpreter', 'none', 'location', 'northwest', 'fontsize', FONT_SIZE);

%% Cleanup.
unloadlibrary('FixedPointLib');
