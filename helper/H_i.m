% Roman Ramirez, rr8rk@virginia.edu
% BME 3636, Homework 12
% H_i.m, a black-box function for determining the entropy for every given
% pixel.

function value = H_i(Q_i, P_i)

    value = P_i .* log2(Q_i ./ P_i);
    value(isnan(value)) = 0;

end