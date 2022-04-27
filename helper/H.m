% Roman Ramirez, rr8rk@virginia.edu
% BME 3636, Homework 12
% H.m, a black-box function for Shannon's Discrete Entropy

function [value] = H(matrix)

    P_xi = P_i(matrix);
    H_xi = H_i(1, P_xi);

    value = sum(H_xi);

end

