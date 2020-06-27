function [ h ] = BlackmanHarrisNuttall( L )
%BlackmanHarrisNuttall Summary of this function goes here
%   L = window length
    coeffs = [0.355768, -0.487396, 0.144232, -0.012604];
    nn = 0:(L-1);
    nn = nn(:);
    h = coeffs(1) + coeffs(2) * cos(2*pi*nn/L) + coeffs(3) * cos(4*pi*nn/L) + coeffs(4) * cos(6*pi*nn/L);
end

