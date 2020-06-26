function [rho_s] = lossFunction(s, lossClass)

%
if (strcmp(lossClass, 'Cauchy'))
    rho_s = log(1 + s);
elseif (strcmp(lossClass, 'SoftLOne'))
    rho_s = 2 * (sqrt(1 + s) - 1);
elseif (strcmp(lossClass, 'Arctan'))
    rho_s = atan(s);
else
    rho_s = s;
end


end

