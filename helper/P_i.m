% Roman Ramirez, rr8rk@virginia.edu
% BME 3636, Homework 12
% P.m, a black-box function for finding the probability of a given pixel
% being on for a given position

function value = P_i(matrix)
    value = sum(matrix, 2)' / size(matrix, 2);
end