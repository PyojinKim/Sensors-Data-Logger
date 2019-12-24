function [y] = HuberFunction(x, k)

if (abs(x) <= k)
    y = 1;
else
    y = (k / (abs(x)));
end

end

