% Load the library.
if ~libisloaded('FixedPointLib')
    dll_path = [pwd '\FixedPointLib\x64\Debug\FixedPointLib.dll'];
    h_path = [pwd '\FixedPointLib\FixedPointLib\FixedPointLib.h'];
    loadlibrary(dll_path, h_path);
end

% Display function signature.
libfunctionsview('FixedPointLib')

%% Call the function.
float_in = exp(5);
n_fraction_bits = 16; % 16 % 7
if calllib('FixedPointLib', 'is_positive_representable', float_in, n_fraction_bits)
    fxp_in = calllib('FixedPointLib', 'float_to_q', float_in, n_fraction_bits)
    fxp_out = calllib('FixedPointLib', 'fxlog', fxp_in) % fxlog % fxlog_mod
    float_out = calllib('FixedPointLib', 'q_to_float', fxp_out, n_fraction_bits)
else
    fprintf('x = %.4f can NOT be represent by Q%d fixed-point number', x, n_fraction_bits);
    x = nan;
end


%% Cleanup.
unloadlibrary('FixedPointLib');
